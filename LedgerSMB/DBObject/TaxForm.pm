#! /usr/bin/perl

package LedgerSMB::DBObject::TaxForm;

use base qw(LedgerSMB::DBObject);

use strict;

sub save 
{
  
    my ($self) = shift @_;
    my ($ref) = $self->exec_method(funcname => 'tax_form__save');
    $self->{taxform_id} = $ref->{'tax_form__save'};
  
    $self->{dbh}->commit();
}

sub get_forms
{
    my ($self) = @_;
    
    @{$self->{forms}} = $self->exec_method(
                funcname => 'list_taxforms',
                args => ['1'] # lx: Inquire as to the use of this argument in this sp; currently doesn't add up in the SQL for the SP.
    );
}

sub get_metadata
{
    my ($self) = @_;

    @{$self->{countries}} = $self->exec_method(
                funcname => 'location_list_country'
    );

    my ($ref) = $self->call_procedure(procname => 'setting_get', args => ['default_country']);
    $self->{default_country} = $ref->{setting_get};
}

1;
