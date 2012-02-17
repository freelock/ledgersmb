=pod

=head1 NAME 

LedgerSMB::Scripts::import_trans

=head1 SYNPOSIS

This is a module that demonstrates how to set up scripts for importing bulk 
data.

=cut

package LedgerSMB::Scripts::import_trans;
use LedgerSMB::Template;
use LedgerSMB::Form;
use strict;

my $default_currency = 'USD';
our $cols = {
   gl       =>  ['accno', 'debit', 'credit', 'source', 'memo'],
   ap_multi =>  ['vendor', 'amount', 'account', 'ap', 'description', 
                 'invnumber', 'transdate'],
};
our $preprocess = {};
our $postprocess = {};
our $process = {
   gl       => sub {
                   use LedgerSMB::GL;
                   my ($request, $entries) = @_;
                   my $form = Form->new();
                   $form->{reference} = $request->{reference};
                   $form->{description} = $request->{description};
                   $form->{transdate} = $request->{transdate};
                   $form->{rowcount} = 0;
                   $form->{approved} = '0';
                   $form->{dbh} = $request->{dbh};
                   for my $ref (@$entries){
                       if ($ref->[1] !~ /\d/){
                          delete $ref->[1];
                       } else {
                          print STDERR "debits $ref->[1]\n";
                          $ref->[1] = $form->parse_amount(
                                         $request->{_user}, $ref->[1]
                          );
                       }
                       if ($ref->[2] !~ /\d/){
                          delete $ref->[2];
                       } else {
                          print STDERR "credits $ref->[2]\n";
                          $ref->[2] = $form->parse_amount(
                                         $request->{_user}, $ref->[2]
                          );
                       }
                       next if !$ref->[1] and !$ref->[2];
                       for my $col (@{$cols->{$request->{type}}}){
                           $form->{"${col}_$form->{rowcount}"} = shift @$ref;
                       }
                       ++$form->{rowcount};
                   }
                   GL->post_transaction($request->{_user}, $form);
                },
   ap_multi => sub {
                   use LedgerSMB::AA;
                   use LedgerSMB::Batch;
                   my ($request, $entries) = @_;
                   my $batch = LedgerSMB::Batch->new({base => $request});
                   $batch->{batch_number} = $request->{reference};
                   $batch->{batch_date} = $request->{transdate};
                   $batch->{batch_class} = 'ap';
                   $batch->create(); 
                   # Necessary to test things are found before starting to 
                   # import! -- CT
                   my $acst = $request->{dbh}->prepare(
                        "select count(*) from account where accno = ?"
                   );
                   my $vcst = $request->{dbh}->prepare(
                        "select count(*) from entity_credit_account where meta_number = ?"
                   );
                   for my $ref (@$entries){
                       my $pass;
                       next if $ref->[1] !~ /\d/;
                       my ($acct) = split /--/, $ref->[2];
                       $acst->execute($acct);
                       ($pass) = $acst->fetchrow_array;
                       $request->error("Account $acct not found") if !$pass;
                       ($acct) = split /--/, $ref->[3];
                       $acst->execute($acct);
                       ($pass) = $acst->fetchrow_array;
                       $request->error("Account $acct not found") if !$pass;
                       $vcst->execute(uc($ref->[0]));
                       ($pass) = $vcst->fetchrow_array;
                       $request->error("Vendor $ref->[0] not found") if !$pass;
                   }
                   for my $ref (@$entries){
                       my $form = Form->new();
                       $form->{dbh} = $request->{dbh};
                       $form->{rowcount} = 1;
                       $form->{batch_id} = $batch->{id};
                       $form->{vendornumber} = shift @$ref;
                       $form->{amount_1} = shift @$ref;
                       next if $form->{amount_1} !~ /\d/;
                       $form->{amount_1} = $form->parse_amount(
                              $request->{_user}, $form->{amount_1}); 
                       $form->{AP_amount_1} = shift @$ref;
                       $form->{ARAP} = 'AP';
                       $form->{vc} = "vendor";
                       $form->{arap} = 'ap';
                       $form->{AP} = shift @$ref;
                       $form->{description_1} = shift @$ref;
                       $form->{invnumber} = shift @$ref;
                       $form->{transdate} = shift @$ref;
                       $form->{currency} = $default_currency;
                       $form->{approved} = '0';
                       $form->{defaultcurrency} = $default_currency;
                       my $sth = $form->{dbh}->prepare(
                            "SELECT id FROM entity_credit_account
                              WHERE entity_class = 1 and meta_number = ?"
                       );
                       $sth->execute(uc($form->{vendornumber}));
                       ($form->{vendor_id}) = $sth->fetchrow_array;
                      
                       AA->post_transaction($request->{_user}, $form);
                   }
               },
};

sub parse_file {
    my $self = shift @_;

    my $handle = $self->{_request}->upload('import_file');
    my $contents = join("\n", <$handle>);

    $self->{import_entries} = [];
    for my $line (split /(\r\n|\r|\n)/, $contents){
        next if ($line !~ /,/);
        my @fields;
        $line =~ s/[^"]"",/"/g;
        while ($line ne '') {
            if ($line =~ /^"/){
                $line =~ s/"(.*?)"(,|$)//;
                my $field = $1;
                $field =~ s/\s*$//;
                push @fields, $field;
            } else {
                $line =~ s/([^,]*),?//;
                my $field = $1;
                $field =~ s/\s*$//;
                push @fields, $field;
            }
        }
        push @{$self->{import_entries}}, \@fields;
    }     
    unshift @{$self->{import_entries}}; # get rid of header line
    return @{$self->{import_entries}};
}

sub begin_import {
    my ($request) = @_;
    my $template = LedgerSMB::Template->new(
        user =>$request->{_user}, 
        locale => $request->{_locale},
        path => 'UI/import_trans',
        template => 'import_trans',
        format => 'HTML'
    );
    $template->render($request);
}

sub run_import {
    my ($request) = @_;
    my @entries = parse_file($request);
    if (ref($preprocess->{$request->{type}}) eq 'CODE'){
        $preprocess->{$request->{type}}($request, \@entries);
    }
    $process->{$request->{type}}($request, \@entries) || begin_import($request);
    if (ref($postprocess->{$request->{type}}) eq 'CODE'){
        $postprocess->{$request->{type}}($request, \@entries);
    }
    begin_import($request);
}

eval { do 'scripts/custom/import_trans.pl'; };
