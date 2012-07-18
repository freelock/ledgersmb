=head1 NAME

LedgerSMB::DBObject::Entity -- Entity Management base classes for LedgerSMB

=cut

package LedgerSMB::DBObject::Entity;
use Moose;
with 'LedgerSMB::DBObject_Moose';

=head1 SYNOPSYS

This module anages basic entity management for persons and companies, both of which will
likely inherit this class.

=head1 INHERITS

=over

=item LedgerSMB::DBObject_Moose

=back

=cut


=head1 PROPERTIES

=over

=item id

This is the internal, system id, which is a surrogate key.  This will be undefined when
the entity has not yet been saved to the database and set once it has been saved or 
retrieved.

=cut

has 'id' => (is => 'rw', isa => 'Maybe[Str]', required => '0');

=item control_code

The control code is the internal handling number for the operator to use to pull up 
an entity,

=cut

has 'control_code' => (is => 'rw', isa => 'Str', required => 1);

=item name

The unofficial name of the entity.  This is usually copied in from company.legal_name
or prepared (using some sort of locale-specific logic) from person.first_name and
person.last_name.

=cut

has 'name' => (is => 'rw', isa => 'Maybe[Str]');

=item country_id

ID of country of entiy.

=cut

has 'country_id' => (is => 'rw', isa => 'Int');

=item country_name

Name of country (optional)

=cut

has 'country_name' => (is => 'rw', isa => 'Maybe[Str]');

=item entity_class

Primary class of entity.  This is mostly for reporting purposes.  See entity_class
table in database for list of valid values, but 1 is for vendors, 2 for customers, 
3 for employees, etc.

=back

=cut

has 'entity_class' => (is => 'rw', isa => 'Int');

=head1 METHODS

=over

=item get($id)

Returns an entity by id

=cut

sub get{
    my ($id) = @_;
    my @results =  __PACKAGE__->call_procedure(procname => 'entity__get', 
                                                   args => [$id]);
    return shift @results;
}

=back

=head1 COPYRIGHT

Copyright (C) 2012 The LedgerSMB Core Team.  This file may be reused under the
conditions of the GNU GPL v2 or at your option any later version.  Please see the
accompanying LICENSE.TXT for more information.

=cut

__PACKAGE__->meta->make_immutable;

return 1;
