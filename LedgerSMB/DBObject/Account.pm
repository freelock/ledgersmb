=head1 NAME

LedgerSMB::DBObject::Account: Base class for chart of accounts entries

=head1 SYNOPSYS

This class contains methods for managing chart of accounts entries (headings 
and accounts).

=head1 METHODS

=cut

use strict;
package LedgerSMB::DBObject::Account;
use base qw(LedgerSMB::DBObject);

=over

=item save()

This method saves the chart of accounts entry.

=cut

sub save {
    my $self = shift @_;
    if (!defined $self->{contra}){
        $self->{contra} = '0';
    }
    $self->generate_links;
    $self->exec_method(funcname => 'account_save');
    $self->{dbh}->commit;
}

=item get()

This method gets a chart of accounts entry.  It requires that the $account->{id}
value must be properly set.

=cut

sub get {
    my $self = shift @_;
    my @accounts =  $self->exec_method(funcname => 'account_get');
    $self->{account_list} = [];
    for my $ref (@accounts){
        if ($self->{charttype} and $self->{charttype} ne $ref->{charttype}){
             next;
        }
        bless $ref, 'LedgerSMB::DBObject::Account';
        $ref->merge($self, keys => ['_user', '_locale', 'stylesheet', 'dbh', '_roles', '_request']);
        push (@{$self->{account_list}}, $ref);
    }
    return @accounts;
}

=item check_transactions()

Returns true if the account has transactions, false if not.  Also sets the
$account->{has_transactions} value to the return value.

$account->{id} must be set.

=cut

sub check_transactions {
    my $self = shift @_;
    my ($ref) = $self->exec_method(funcname => 'account_has_transactions');
    $self->{has_transactions} = $ref->{'account_has_transactions'};
} 

=item delete()

Attemps to delete the account.  This will NOT succeed if the account is 
referenced in any way by any transactions, credit accounts, etc.

$account->{id} must be set.

=cut

sub delete {
    my $self = shift @_;
    $self->exec_method(funcname => 'account__delete');
    $self->{dbh}->commit;
}

=item list()

Returns a list of all accounts.

=cut

sub list {
    my $self = shift @_;
    @{$self->{account_list}} =  $self->exec_method(funcname => 'chart__list_all');
    return @{$self->{account_list}};
}

=item generate_links()

A mostly-private method for generating and checking whether link data is valid.

This is usually done (automatically) in preparation for saving the information 
to the database.

=cut

sub generate_links {
    my $self= shift @_;
    my @sum =  qw(AR AP IC);
    my $is_summary = 0;
    my @links;
    my @others = qw(AR_amount AR_tax AR_paid AR_overpayment AR_discount
                    AP_amount AP_tax AP_paid AP_overpayment AP_discount
                    IC_sale IC_cogs IC_taxpart IC_taxservice IC_income
                    IC_expense);

   for my $l (@sum){
       if ($self->{$l}){
           if ($is_summary){
               $self->error($self->{_locale}->text('Too many links on summary account!'));
           }
           push (@links, $l);
           $is_summary = 1;
       }
   }
   for my $l (@others){
       if ($self->{$l}){
           if ($is_summary){
               $self->error($self->{_locale}->text('Too many links on summary account!'));
           }
           push (@links, $l);
       }
    }
    $self->{link} = $self->_db_array_scalars(@links);
}

=back

=head1 SEE ALSO

LedgerSMB::DBObject, LedgerSMB

=head1 COPYRIGHT

Copyright (c) 2009, the LedgerSMB Core Team.  This is licensed under the GNU 
General Public License, version 2, or at your option any later version.  Please 
see the accompanying License.txt for more information.

=cut

1;
