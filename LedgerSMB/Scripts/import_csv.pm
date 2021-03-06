=pod

=head1 NAME 

LedgerSMB::Scripts::import_trans

=head1 SYNPOSIS

This is a module that demonstrates how to set up scripts for importing bulk 
data.

=cut

package LedgerSMB::Scripts::import_csv;
use Moose;
use LedgerSMB::Template;
use LedgerSMB::Form;
use strict;

my $default_currency = 'USD';
our $cols = {
   gl       =>  ['accno', 'debit', 'credit', 'source', 'memo'],
   ap_multi =>  ['vendor', 'amount', 'account', 'ap', 'description', 
                 'invnumber', 'transdate'],
   ar_multi =>  ['customer', 'amount', 'account', 'ar', 'description', 
                 'invnumber', 'transdate'],
   timecard =>  ['employee', 'projectnumber', 'transdate', 'partnumber',
                 'description', 'qty', 'noncharge', 'sellprice', 'allocated',
                'notes'],
   inventory => ['partnumber', 'description', 'expected', 'onhand', 
                 'purchase_price'],
};

our $ap_accno_for_inventory = '2100';
our $ar_accno_for_inventory = '1200';
our $ap_eca_for_inventory = '00000'; # Built in inventory adjustment accounts
our $ar_eca_for_inventory = '00000';
our $preprocess = {};
our $postprocess = {};

our $aa_multi = sub {
                   use LedgerSMB::AA;
                   use LedgerSMB::Batch;
                   my ($request, $entries, $arap) = @_;
                   my $batch = LedgerSMB::Batch->new({base => $request});
                   $batch->{batch_number} = $request->{reference};
                   $batch->{batch_date} = $request->{transdate};
                   $batch->{batch_class} = $arap;
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
                       $form->{ARAP} = uc($arap);
                       $form->{batch_id} = $batch->{id};
                       $form->{vendornumber} = shift @$ref;
                       $form->{amount_1} = shift @$ref;
                       next if $form->{amount_1} !~ /\d/;
                       $form->{amount_1} = $form->parse_amount(
                              $request->{_user}, $form->{amount_1}); 
                       $form->{"$form->{ARAP}_amount_1"} = shift @$ref;
                       $form->{vc} = "vendor";
                       $form->{arap} = $arap;
                       $form->{uc($arap)} = shift @$ref;
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
               };
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
   ar_multi => sub { 
                   my  ($request, $entries) = @_;
                   return $aa_multi($request, $entries, 'ar');
               },
   ap_multi => sub { 
                   my  ($request, $entries) = @_;
                   return $aa_multi($request, $entries, 'ap');
               },
    chart => sub {
               use LedgerSMB::DBObject::Account;

               my ($request, $entries) = @_;

               foreach my $entry (@$entries){
                  my $account = LedgerSMB::DBObject::Account->new({base=>$request});
                  my $settings = {
                      accno => $entry->[0],
                      description => $entry->[1],
                      charttype => $entry->[2],
                      category => $entry->[3],
                      contra => $entry->[4],
                      tax => $entry->[5],
#                      heading => $entry->[7],
                      gifi_accno => $entry->[8],
                  };

                  if ($entry->[6] !~ /:/) {
                    $settings->{$entry->[6]} = 1
                      if ($entry->[6] ne "");
                  } else {
                    foreach my $link (split( /:/, $entry->[6])) {
                       $settings->{$link} = 1;
                    }
                  }

                  $account->merge($settings);
                  $account->save();
               }
             },
    gifi  => sub {
               my ($request, $entries) = @_;
               my $dbh = $request->{dbh};
               my $sth = $dbh->prepare('INSERT INTO gifi (accno, description) VALUES (?, ?)') || die $dbh->errstr;;

               foreach my $entry (@$entries) {
                 $sth->execute($entry->[0], $entry->[1]) || die $sth->errstr();
               }
               $dbh->commit;
             },
    sic   => sub {
               my ($request, $entries) = @_;
               my $dbh = $request->{dbh};
               my $sth = $dbh->prepare('INSERT INTO sic (code, sictype, description) VALUES (?, ?, ?)') || die $dbh->errstr;;

               foreach my $entry (@$entries) {
                 $sth->execute($entry->[0], $entry->[1], $entry->[2])
                    || die $sth->errstr();
               }
               $dbh->commit;
             },
 timecard => sub {
               use LedgerSMB::Timecard;
               my ($request, $entries) = @_;
               my $myconfig = {};
               my $jc = {};
               for my $entry (@$entries) {
                   my $counter = 0;
                   for my $col (@{$cols->{timecard}}){
                       $jc->{$col} = $entry->[$counter];
                       ++$counter;
                   }
                   LedgerSMB::Timecard->new(%$jc)->save;
               }
             },
   inventory => sub {
                my ($request, $entries) = @_;
                use LedgerSMB::IS;
                use LedgerSMB::IR;
                my $ar_form = Form->new();
                my $ap_form = Form->new();
                my $dbh = $request->{dbh};
                $ar_form->{dbh} = $dbh;
                $ap_form->{dbh} = $dbh;
                $ar_form->{rowcount} = 0;
                $ap_form->{rowcount} = 0;
                my $expected_sth = $dbh->prepare(
                    "SELECT sum(qty) * -1 FROM invoice 
                       JOIN (select id, approved from ar UNION ALL
                             SELECT id, approved from gl UNION ALL
                             SELECT id, approved from ap) gl 
                             ON gl.approved AND invoice.trans_id = gl.id
                      WHERE invoice.parts_id = ?"
                );
                my $p_info_sth = $dbh->prepare(
                    "SELECT * FROM parts WHERE partnumber = ?"
                );

                $dbh->do( # Not worth parameterizing for one input
                    "INSERT INTO inventory_report 
                            (transdate, source)
                     VALUES (".$dbh->quote($request->{transdate}).
                             ", 'CSV upload')"
                );

                my ($report_id) = $dbh->fetchall_array(
                    "SELECT curval('inventory_report_id_seq')"
                );
                for my $entry (@$entries){
                    my $line = {};
                    for my $col (@{$cols->{inventory}}) {
                      $line->{$col} = shift @$entry;
                    }
                    next if $line->{onhand} !~ /\d/;
                    $p_info_sth->execute($line->{partnumber});
                    my $part = $p_info_sth->fetchrow_hashref('NAME_lc');
                    $expected_sth->execute($part->{id});
                    my ($expected) = $expected_sth->fetchrow_array;
                    if ($line->{onhand} > $expected) { # Adjusting UP
                       my $rc = $ap_form->{rowcount};
                       $ap_form->{"parts_id_$rc"} = $part->{id};
                       $ap_form->{"description_$rc"} = $part->{description};
                       $ap_form->{"sellprice_$rc"} = $line->{purchase_price};
                       $ap_form->{"sellprice_$rc"} ||= $part->{lastcost};
                       $ap_form->{"qty_$rc"} = $line->{onhand} - $expected;
                       ++$ap_form->{rowcount};
                    } else { # Adjusting DOWN by 0 or more
                       my $rc = $ar_form->{rowcount};
                       $ar_form->{"parts_id_$rc"} = $part->{id};
                       $ar_form->{"description_$rc"} = $part->{description};
                       $ar_form->{"sellprice_$rc"} = $part->{sellprice};
                       $ar_form->{"qty_$rc"} = $expected - $line->{onhand};
                       $ar_form->{"discount_$rc"} = '100';
                       ++$ap_form->{rowcount};
                    }
                    my $dbready_oh = $dbh->quote($line->{onhand});
                    $dbh->do( # all values numbers from db but one and that 
                              # one is sanitized
                      "INSERT INTO inventory_report_line
                              (parts_id, counted, expected, report_id)
                       VALUES ($part->{id}, $dbready_oh, $expected, $report_id)"
                    );
                }
                $ar_form->{ARAP} = 'AR';
                $ar_form->{AR} = $ar_accno_for_inventory;
                $ap_form->{ARAP} = 'AP';
                $ap_form->{AP} = $ap_accno_for_inventory;

                # ECA
                $ar_form->get_name(undef, 'today', $ar_eca_for_inventory, 2);
                $ap_form->get_name(undef, 'today', $ap_eca_for_inventory, 1);
                my $ar_eca = shift @{$ar_form->{name_list}};
                my $ap_eca = shift @{$ap_form->{name_list}};
                $ar_form->{customer_id} = $ar_eca->{id}; 
                $ap_form->{customer_id} = $ap_eca->{id}; 

                # POST
                IS->post_invoice(undef, $ar_form) if $ar_form->{rowcount};
                IR->post_invoice(undef, $ap_form) if $ap_form->{rowcount};

                # Now, update the report record.
                $dbh->do( # These two params come from posting above, and from
                          # the db.
                   "UPDATE inventory_report
                       SET ar_trans_id = $ar_form->{id},
                           ap_trans_id = $ap_form->{id}
                     WHERE id = $report_id"
                );
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
                $line =~ s/"(.*?)"(,|$)// 
                    || $self->error($self->{_locale}->text('Invalid file'));
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
    shift @{$self->{import_entries}}; # get rid of header line
    return @{$self->{import_entries}};
}

sub begin_import {
    my ($request) = @_;
    my $template = LedgerSMB::Template->new(
        user =>$request->{_user}, 
        locale => $request->{_locale},
        path => 'UI/import_csv',
        template => 'import_csv',
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

1;
