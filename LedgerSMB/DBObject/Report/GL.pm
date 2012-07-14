=head1 NAME

LedgerSMB::DBObject::Report::GL - GL Reports for LedgerSMB

=head1 SYNPOSIS

  my $glreport = LedgerSMB::DBObject::Report::GL->new(%$request);
  $glreport->run;
  $glreport->render($request, $format);

=head1 DESCRIPTION

This module provides GL reports for LedgerSMB.  GL reports are useful for 
searching for and reporting financial transactions.

=head1 INHERITS

=over

=item LedgerSMB::DBObject::Report;

=back

=cut

package LedgerSMB::DBObject::Report::GL;
use Moose;
extends 'LedgerSMB::DBObject::Report';

use LedgerSMB::DBObject::Business_Unit_Class;
use LedgerSMB::DBObject::Business_Unit;
use LedgerSMB::App_State;

my $locale = $LedgerSMB::App_State::Locale;

=head1 PROPERTIES

=over

=item columns

Read-only accessor, returns a list of columns.

=over

=item id

=item reference

=item description

=item transdate

=item source

=item memo

=item debits

=item credits

=item entry_id

=item cleared

=item chart_id

=item accno

=item gifi_accno

=item running_balance

=item one for each business unit class returned

=back

=cut

our @COLUMNS = (
    {col_id => 'id',
       name => $locale->text('ID'),
       type => 'text',
     pwidth => 1, },

    {col_id => 'transdate',
       name => $locale->text('Date'),
       type => 'text',
     pwidth => '4', },

    {col_id => 'reference',
       name => $locale->text('Reference'),
       type => 'href',
  href_base => '',
     pwidth => '3', },

    {col_id => 'description',
       name => $locale->text('Description'),
       type => 'text',
     pwidth => '6', },

    {col_id => 'entry_id',
       name => $locale->text('Entry ID'),
       type => 'text',
     pwidth => '1', },

    {col_id => 'debits',
       name => $locale->text('Debits'),
       type => 'text',
     pwidth => '2', },

    {col_id => 'credits',
       name => $locale->text('Credits'),
       type => 'text',
     pwidth => '2', },

    {col_id => 'source',
       name => $locale->text('Source'),
       type => 'text',
     pwidth => '3', },

    {col_id => 'memo',
       name => $locale->text('Memo'),
       type => 'text',
     pwidth => '3', },

    {col_id => 'cleared',
       name => $locale->text('Cleared'),
       type => 'text',
     pwidth => '3', },

    {col_id => 'till',
       name => $locale->text('Till'),
       type => 'text',
     pwidth => '1', },

    {col_id => 'chart_id',
       name => $locale->text('Chart ID'),
       type => 'text',
     pwidth => '1', },

    {col_id => 'accno',
       name => $locale->text('Account No.'),
       type => 'text',
     pwidth => '3', },

    {col_id => 'accname',
       name => $locale->text('Account Name'),
       type => 'text',
     pwidth => '3', },

    {col_id => 'gifi_accno',
       name => $locale->text('GIFI'),
       type => 'text',
     pwidth => '3', },

    {col_id => 'running_balance',
       name => $locale->text('Balance'),
       type => 'text',
     pwidth => '3', },
);

sub columns {
    my @bclasses = LedgerSMB::DBObject::Business_Unit_Class->list('1', 'gl');
    my @COLS = @COLUMNS;
    for my $class (@bclasses){
        push @COLS, {col_id =>  "bc_" . $class->id,
                       name => $locale->text($class->label),
                       type => 'text',
                     pwidth => '2'};
    }
    return \@COLS;
}

=item filter_template

Returns the template name for the filter.

=cut

sub filter_template {
    return 'journal/search';
}

=item name

Returns the localized template name

=cut

sub name {
    return $locale->text('General Ledger Report');
}

=item header_lines

Returns the inputs to display on header.

=cut

sub header_lines {
    return [{name => 'from_date',
             text => $locale->text('Start Date')},
            {name => 'to_date',
             text => $locale->text('End Date')},
            {name => 'accno',
             text => $locale->text('Account Number')},
            {name => 'reference',
             text => $locale->text('Reference')},
            {name => 'source',
             text => $locale->text('Source')}];
}

=item subtotal_cols

Returns list of columns for subtotals

=cut

sub subtotal_cols {
    return ['debits', 'credits'];
}

=back

=head2 Criteria Properties

Note that in all cases, undef matches everything.

=over

=item reference (text)

Exact match on reference or invoice number.

=cut

has 'reference' => (is => 'rw', isa => 'Maybe[Str]');

=item accno

Exact match for the account number

=cut

has 'accno'  => (is => 'rw', isa => 'Maybe[Str]');


=item category

Is one of A (Asset), L (Liability), Q (Equity), I (Income), or E (Expense).

When set only matches lines attached to transactions of specfied type.

=cut

has 'category' => (is => 'rw', isa => 'Maybe[Str]');

=item source

Exact match of source field

=cut

has 'source' => (is => 'rw', isa => 'Maybe[Str]');

=item memo

Full text search of memo field

=cut

has 'memo' => (is => 'rw', isa => 'Maybe[Str]');

=item description

Full text search of description field of GL transaction

=cut

has 'description' => (is => 'rw', isa => 'Maybe[Str]');

=item from_date

Earliest date which matches the search

=cut

has 'from_date' => (is => 'rw', coerce => 1, isa => 'LedgerSMB::Moose::Date');

=item to_date

Last date that matches the search

=cut

has 'to_date' => (is => 'rw', coerce => 1, isa => 'LedgerSMB::Moose::Date');

=item approved

Unless false, only matches approved transactions.  When false, matches all 
transactions.  This is the one exception to the general rule that undef matches
all.

=cut

has 'approved' => (is => 'rw', isa => 'Maybe[Bool]');

=item amount_from

The lowest value that can match, amount-wise.

=item amount_to

The highest value that can match, amount-wise.

=cut

has 'amount_from' => (is => 'rw', coerce => 1, 
                     isa => 'LedgerSMB::Moose::Number');
has 'amount_to' => (is => 'rw', coerce => 1, 
                   isa => 'LedgerSMB::Moose::Number');

=item business_units

Array of business unit id's

=cut

has 'business_units' => (is => 'rw', isa => 'Maybe[ArrayRef[Int]]');

=back

=head1 METHODS

=over

=item run_report()

Runs the report, and assigns rows to $self->rows.

=cut

sub run_report{
    my ($self) = @_;
    my @rows = $self->exec_method({funcname => 'report__gl'});
    for my $ref(@rows){
        if ($ref->{amount} < 0){
            $ref->{debits} = $ref->{amount} * -1;
            $ref->{credits} = 0;
        } else {
            $ref->{credits} = $ref->{amount};
            $ref->{debits} = 0;
        }
        if ($ref->{type} eq 'gl'){
           $ref->{reference_href_suffix} = "gl.pl?action=edit&id=$ref->{id}";
        } elsif ($ref->{type} eq 'ar'){
           if ($ref->{invoice}){
                $ref->{reference_href_suffix} = 'is.pl';
           } else {
                $ref->{reference_href_suffix} = 'ar.pl';
           }
           $ref->{reference_href_suffix} .= "?action=edit&id=$ref->{id}";
        } elsif ($ref->{type} eq 'ap'){
           if ($ref->{invoice}){
                $ref->{reference_href_suffix} = 'ir.pl';
           } else {
                $ref->{reference_href_suffix} = 'ap.pl';
           }
           $ref->{reference_href_suffix} .= "?action=edit&id=$ref->{id}";
        }
        if ($ref->{cleared}){
            $ref->{cleared} = 'X';
        } else {
            $ref->{cleared} = '';
        }
        $self->process_bclasses($ref);
    }
    $self->rows(\@rows);
}

=back

=head1 COPYRIGHT

COPYRIGHT (C) 2012 The LedgerSMB Core Team.  This file may be re-used following
the terms of the GNU General Public License version 2 or at your option any
later version.  Please see included LICENSE.TXT for details.

=cut

__PACKAGE__->meta->make_immutable;
return 1;
