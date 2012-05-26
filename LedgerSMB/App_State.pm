=head1 NAME

LedgerSMB::App_State

=cut
package LedgerSMB::App_State;
use strict;
use warnings;
use LedgerSMB::Sysconfig;
use LedgerSMB::SODA;
use LedgerSMB::User;
use LedgerSMB::Locale;

=head1 SYNPOSIS

This is a generic container class for non-web-application related state
information.  It provides a central place to track such things as localization,
user, and other application state objects.

=head1 OBJECTS FOR STORAGE

The following are objects that are expected to be stored in this namespace:

=over

=cut

our $Locale;

=item Locale

Stores a LedgerSMB::Locale object for the specific user.

=cut

our $User;

=item User

Stores a LedgerSMB::User object for the currently logged in user.

=cut

our $SODA;

=item SODA

Stores the SODA database access handle.

=cut

our $Company_Settings;

=item Company_Settings

Hashref for storing connection-specific settings for the application.

=item DBH

Database handle for current connection

=cut

our $DBH;


=item Roles

This is a list (array) of role names for the current user.

=cut

our @Roles;

=item Role_Prefix

String of the beginning of the role.

=cut

our $Role_Prefix;

=back

=head1 METHODS 

=over

=item init(string $username, string $credential, string $company)

=cut

sub init {
    my ($username, $credential, $company) = @_;
    $SODA   = LedgerSMB::SODA->new({db => $company, 
                              username => $username,
                                  cred => $credential});
    $User   = LedgerSMB::User->fetch_config($SODA);
    $Locale = LedgerSMB::Locale->get_handle($User->{language});
}

=item zero()

zeroes out all majro parts.

=cut

sub zero() {
    $SODA = undef;
    $User = undef;
    $Locale = undef;
    $DBH = undef;
    @Roles = ();
    $Role_Prefix = undef;
}

=item cleanup

Deletes all objects attached here.

=cut

sub cleanup {

    if ($DBH){
        $DBH->commit;
        $DBH->disconnect;
    }
    $Locale           = LedgerSMB::Locale->get_handle(
                            $LedgerSMB::Sysconfig::language
                        );
    $User             = {};
    $SODA             = {};
    $Company_Settings = {};
    $DBH = undef;
    @Roles = ();
    $Role_Prefix = undef;
}

1;

=item get_url

Returns URL of get request or undef

=cut

sub get_url {
    if ($ENV{REQUEST_METHOD} ne 'GET') {
       return undef;
    }
    return "$ENV{SCRIPT_NAME}?$ENV{QUERY_STRING}";
}

=back

=head1 COPYRIGHT

Copyright (C) 2009 LedgerSMB Core Team.  This file is licensed under the GNU 
General Public License version 2, or at your option any later version.  Please
see the included License.txt for details.

