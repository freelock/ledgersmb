
package LedgerSMB::DBObject::Asset_Report;

=head1 NAME

LedgerSMB::DBObject::Asset_Report.pm, LedgerSMB Base Class for Asset Reports

=head1 SYNOPSIS

This library contains the base utility functions for creating, saving, and
retrieving depreciation categories of asset depreciation and disposal reports.

=head1 STANDARD PROPERTIES

=over

=item id int

Integer id of asset report

=item report_date date

Effective date of report

=item gl_id bigint

ID of GL transaction if applicable and approved.

=item asset_class bigint 

ID of asset class for the report the assets are 

=item report_class int

Integer of the report class desired.

=item entered_by bigint

Integer id of the individual who entered the report

=item approved_by bigint

Integer id of the individual who approved the report

=item entered_at timestamp

Timestamp the report was created

=item approved_at timestamp

Timestamp the report was approved

=item depreciated_qty 

Number of units (production or time) depreciated

=item dont_approve bool

If true, do not approve, ever.

=item submitted bool

If true, submitted for approval


=back

=head1 METHODS

=over

=cut

use base qw(LedgerSMB::DBObject);
use strict;

=item save

Uses standard properties

Saves report to the database.  Sets ID.

=cut

sub save {
    my ($self) = @_;
    if ($self->{depreciation}){
        my ($ref) = $self->exec_method(funcname => 'asset_report__save');
        $self->{report_id} = $ref->{id};
        $self->{asset_ids} = $self->_db_array_scalars(@{$self->{asset_ids}});
        my ($dep) = $self->exec_method(funcname => 'asset_class__get_dep_method');
        $self->exec_method(funcname => $dep->{sproc});
    } else {
       my ($ref) = $self->exec_method(funcname => 'asset_report__begin_disposal');
       for my $i (0 .. $self->{rowcount}){
           if ($self->{"asset_$i"} == 1){
              my $id = $self->{"id_$i"};
              $self->call_procedure(procname => 'asset_report__dispose',
                               args => [$ref->{id}, 
                                        $id, 
                                        $self->{"amount_$id"},
                                        $self->{"dm_$id"},
                                        $self->{"percent_$id"}]);
          }
       }
    }
    $self->{dbh}->commit;
}

=item get

Gets report from the database.

=cut

sub get {
    my ($self) = @_;
    my ($ref) = $self->exec_method(funcname => 'asset_report__get');
    $self->merge($ref);
    $self->{report_lines} = [];
    if ($self->{report_class} == 1){
        @{$self->{report_lines}} = $self->exec_method(
                                  funcname => 'asset_report__get_lines'
        );
    } elsif ($self->{report_class} == 2) {
        @{$self->{report_lines}} = $self->exec_method(
                                  funcname => 'asset_report__get_disposal'
        );
    } elsif ($self->{report_class} == 4) {
       @{$self->{report_lines}} = $self->exec_method(
                                   funcname => 'asset_report_partial_disposal_details'
       );
    }
    return;
}

sub get_nbv {
    my ($self) = @_;
    return $self->exec_method(funcname => 'asset_nbv_report');
}


sub generate {
    my ($self) = @_;
    @{$self->{assets}} = $self->exec_method(
                   funcname => 'asset_report__generate'
    );
    for my $asset (@{$self->{assets}}){
        if ($self->{depreciation}){
           $asset->{checked} = "CHECKED";
        }
    }
}

sub approve {
    my ($self) = @_;
    $self->exec_method(funcname => 'asset_report__approve');
    $self->{dbh}->commit;
}

sub search {
    my ($self) = @_;
    return $self->exec_method(funcname => 'asset_report__search');
}

sub get_metadata {
    my ($self) = @_;
    @{$self->{asset_classes}} = $self->exec_method(
                   funcname => 'asset_class__list'
    );
    @{$self->{exp_accounts}} = $self->exec_method(
                   funcname => 'asset_report__get_expense_accts'
    );
    @{$self->{gain_accounts}} = $self->exec_method(
                   funcname => 'asset_report__get_gain_accts'
    );
    @{$self->{disp_methods}} = $self->exec_method(
                   funcname => 'asset_report__get_disposal_methods'
    );
    @{$self->{loss_accounts}} = $self->exec_method(
                   funcname => 'asset_report__get_loss_accts'
    );
    for my $atype (qw(exp_accounts gain_accounts loss_accounts)){
        for my $acct (@{$self->{$atype}}){
            $acct->{text} = $acct->{accno}. '--'. $acct->{description};
        }
    }
}

=back

=head1 Copyright (C) 2010, The LedgerSMB core team.

This file is licensed under the Gnu General Public License version 2, or at your
option any later version.  A copy of the license should have been included with
your software.

=cut


1;
