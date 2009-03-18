#!/usr/bin/perl
=pod

=head1 NAME

LedgerSMB::Scripts::Reconciliation - LedgerSMB class defining the Controller
functions, template instantiation and rendering.

=head1 SYOPSIS

This module acts as the UI controller class for Reconciliation. It controls
interfacing with the Core Logic and database layers.

=head1 METHODS

=cut

# NOTE:  This is a first draft modification to use the current parameter type.
# It will certainly need some fine tuning on my part.  Chris

package LedgerSMB::Scripts::recon;

use LedgerSMB::Template;
use LedgerSMB::DBObject::Reconciliation;

use Data::Dumper;

=pod

=over

=item display_report($self, $request, $user)

Renders out the selected report given by the incoming variable report_id.
Returns HTML, or raises an error from being unable to find the selected
report_id.

=back

=cut

sub display_report {
    my ($request) = @_;
    my $recon = LedgerSMB::DBObject::Reconciliation->new(base => $request, copy => 'all'); 
    _display_report($recon);
}

=pod

=over

=item search($self, $request, $user)

Renders out a list of meta-reports based on the search criteria passed to the
search function.
Meta-reports are report_id, date_range, and likely errors.
Search criteria accepted are 
date_begin
date_end
account
status

=back

=cut

sub update_recon_set {
    my ($request) = shift;
    my $recon = LedgerSMB::DBObject::Reconciliation->new(base => $request);
    $recon->add_entries($recon->import_file()) if !$recon->{submitted};
    $recon->{their_total} = $recon->parse_amount(amount => $recon->{their_total}) if defined $recon->{their_total}; 
    $recon->{dbh}->commit;
    if ($recon->{line_order}){
       $recon->set_ordering(
		{method => 'reconciliation__report_details', 
		column  => $recon->{line_order}}
       );
    }
    $recon->update();
    _display_report($recon);
}

sub submit_recon_set {
    my ($request) = shift;
    my $recon = LedgerSMB::DBObject::Reconciliation->new(base => $request);
    $recon->submit();
    my $template = LedgerSMB::Template->new( 
            user => $user, 
    	    template => 'reconciliation/submitted', 
    	    language => $user->{language}, 
            format => 'HTML',
            path=>"UI");
    return $template->render($recon);
    
}
sub save_recon_set {
    my ($request) = shift;
    my $recon = LedgerSMB::DBObject::Reconciliation->new(base => $request);
    $recon->save();
    my $template = LedgerSMB::Template->new( 
            user => $user, 
    	    template => 'reconciliation/search', 
    	    language => $user->{language}, 
            format => 'HTML',
            path=>"UI");
    return $template->render($recon);
    
}

sub get_results {
    my ($request) = @_;
        if ($request->{approved} ne '1' and $request->{approved} ne '0'){
		$request->{approved} = undef;
        }
        if ($request->{submitted} ne '1' and $request->{submitted} ne '0'){
		$request->{submitted} = undef;
        }
        my $search = LedgerSMB::DBObject::Reconciliation->new(base => $request, copy => 'all');
        if ($search->{order_by}){
            $search->set_ordering({
			method => 'reconciliation__search', 
			column => $search->{order_by},
            });
        }
        my @results = $search->search();
        my @accounts = $search->get_accounts();
        my $act_hash = {};
        for my $act (@accounts){
            $act_hash->{"$act->{id}"} = $act->{account};
        }
        for my $row (@results){
            $row->{account} = $act_hash->{"$row->{chart_id}"};
        }
        my $base_url = "recon.pl?action=display_report";
        my $search_url = "recon.pl?action=get_results".
            "&date_from=$search->{date_from}&date_to=$search->{date_to}".
             "&amount_from=$search->{amount_from}&".
             "amount_to=$search->{amount_to}&chart_id=$search->{chart_id}".
             "&approved=$search->{approved}&submitted=$search->{submitted}";
        $columns = {
            "select"         => $request->{_locale}->text('Select'),	
            account          => {
		text => $request->{_locale}->text('Account'),	
		href => $search_url,
	    },
            their_total      => {
                text => $request->{_locale}->text('Balance'),
                href => "$search_url&order_by=their_total",
            },
            end_date         => {
                text => $request->{_locale}->text('Statement Date'),
                href => "$search_url&order_by=end_date",
            },
            submitted        => {
		text => $request->{_locale}->text('Submitted'),
                href => "$search_url&order_by=submitted",
            },
            approved         => {
		text => $request->{_locale}->text('Approved'), 
		href => "$search_url&order_by=approved",
            },
            updated          => {
		text => $request->{_locale}->text('Last Updated'), 
		href => "$search_url&order_by=updated",
            },
            entered_username => {
		text => $request->{_locale}->text('Username'), 
		href => "$search_url&order_by=entered_username",
            },
        };
	my $cols = [];
	my @acts = $search->get_accounts;
	@$cols = qw(select account end_date their_total approved submitted updated entered_username);
	my $recon =$search;
	for my $row(@results){
            my $act = undef;
            for (@acts){
                if ($_->{id} == $row->{chart_id}){
                    $act = $_->{name};
                }
                last if $act;
            }
            $row->{account} = $act;
            $row->{their_total} = $recon->format_amount(
		{amount => $row->{their_total}, money => 1}); 
            $row->{end_date} = {
                text => $row->{end_date}, 
                href => "$base_url&report_id=$row->{id}"
            };
        }
	$recon->{_results} = \@results;
        $recon->debug({file => '/tmp/recon'});
        $recon->{title} = $request->{_locale}->text('Reconciliation Sets');
        my $template = LedgerSMB::Template->new( 
            user => $user, 
    	    template => 'form-dynatable', 
    	    language => $user->{language}, 
            format => 'HTML',
            path=>"UI");
        return $template->render({
		form     => $recon,
		heading  => $columns,
        	hiddens  => $recon,
		columns  => $cols,
		rows     => \@results
	});
        
}
sub search {
    my ($request,$type) = @_;
    

        
        my $recon = LedgerSMB::DBObject::Reconciliation->new(base=>$request, copy=>'all');
	if (!$recon->{hide_status}){
            $recon->{show_approved} = 1;        
            $recon->{show_submitted} = 1;        
        }
        @{$recon->{account_list}} = $recon->get_accounts();
	unshift @{$recon->{account_list}}, {id => '', name => '' };
        my $template = LedgerSMB::Template->new(
            user => $user,
            template=>'search',
            language=>$user->{language},
            format=>'HTML',
            path=>"UI/reconciliation",
        );
        return $template->render($recon);
}

=pod

=over

=item correct ($self, $request, $user)

Requires report_id, entry_id.

Correct is a strange one. Based on the type of transaction listed in the
report, it will run one of several correction functions in the database.
This is to prevent arbitrary editing of the database by unscrupulous users.

=back

=cut

sub correct {
    my ($request) = @_;
    
    if ($request->type() eq "POST") {
        
        my $recon = LedgerSMB::DBObject::Reconciliation->new(base => $request, copy => 'all');

        $recon->correct_entry();
        
        #  Are we getting data?
        if ($recon->{corrected_id}) {

            my $template = LedgerSMB::Template->new( user => $user, 
        	template => 'reconciliation/report', language => $user->{language}, 
                format => 'HTML',
                path=>"UI");

            $template->render( { 
                corrected=> $recon->{corrected_id}, 
                report=> $recon->get_report(),
                total=> $recon->get_total()
            } );
        } 
        else {

            # indicate we were unable to correct this entry, with the error code 
            # spat back to us by the DB.
            my $template = LedgerSMB::Template->new( user => $user, 
        	template => 'reconciliation/report', language => $user->{language}, 
                format => 'HTML',
                path=>"UI");

            $template->render( { 
                recon   => $recon,
                report  => $recon->get_report(),
                total   => $recon->get_total()
            } );
        }
    }
    else {
        
        # We are not getting data sent
        # ergo, we render out stuff.
        
        if ($request->{report_id} && $request->{entry_id}) {
            
            # draw the editor interface.
            
            my $template = LedgerSMB::Template->new(
                user=>$user,
                template=>"reconciliation/correct",
                language=> $user->{language},
                format=>'HTML',
                path=>"UI"
            );
            my $recon = LedgerSMB::DBObject::Reconciliation->new(base=>$request, copy=>'all');
            
            $template->render($recon->details($request->{report_id}));
        }
        elsif ($request->{report_id}) {
            
            my $template = LedgerSMB::Template->new(
                user=>$user,
                template=>"reconciliation/correct",
                language=> $user->{language},
                format=>'HTML',
                path=>"UI"
            );
            $class->display_report();
        }
    }
    
}

=pod

=over

=item new_report ($self, $request, $user)

Creates a new report, from a selectable set of bank statements that have been
received (or can be received from, depending on implementation)

Allows for an optional selection key, which will return the new report after
it has been created.

=back

=cut

sub _display_report {
        my $recon = shift;
        $recon->get();
        $recon->{can_approve} = $recon->is_allowed_role({allowed_roles => ['recon_supervisor']});
        $template = LedgerSMB::Template->new( 
            user=> $user,
            template => 'reconciliation/report', 
            language => $user->{language},
            format=>'HTML',
            path=>"UI"
        );
        $recon->{sort_options} = [
		{id => 'clear_time', label => $recon->{_locale}->text('Clear date')},
		{id => 'scn', label => $recon->{_locale}->text('Source')},
		{id => 'post_date', label => $recon->{_locale}->text('Post Date')},
		{id => 'our_balance', label => $recon->{_locale}->text('Our Balance')},
		{id => 'their_balance', label => $recon->{_locale}->text('Their Balance')},
        ];
        if (!$recon->{line_order}){
           $recon->{line_order} = 'scn';
        }
        $recon->{total_cleared_credits} = $recon->parse_amount(amount => 0);
        $recon->{total_cleared_debits} = $recon->parse_amount(amount => 0);
        $recon->{total_uncleared_credits} = $recon->parse_amount(amount => 0);
        $recon->{total_uncleared_debits} = $recon->parse_amount(amount => 0);

        # Credit/Debit separation (useful for some)
        for my $l (@{$recon->{report_lines}}){
            if ($l->{their_balance} < 0){
               $l->{their_debits} = $recon->parse_amount(amount => 0);
               $l->{their_credits} = $l->{their_balance}->bneg;
            }
            else {
               $l->{their_credits} = $recon->parse_amount(amount => 0);
               $l->{their_debits} = $l->{their_balance};
            }
            if ($l->{our_balance} < 0){
               $l->{our_debits} = $recon->parse_amount(amount => 0);
               $l->{our_credits} = $l->{our_balance}->bneg;
            }
            else {
               $l->{our_credits} = $recon->parse_amount(amount => 0);
               $l->{our_debits} = $l->{our_balance};
            }

            if ($l->{our_balance} != 0 and 
                $l->{our_balance} == $l->{their_balance} or
                defined $recon->{"cleared_$l->{id}"}
            ){
                 $recon->{total_cleared_credits}->badd($l->{our_credits});
                 $recon->{total_cleared_debits}->badd($l->{our_debits});
            } else {
                 $recon->{total_uncleared_credits}->badd($l->{our_credits});
                 $recon->{total_uncleared_debits}->badd($l->{our_debits});
            }

            $l->{their_balance} = $recon->format_amount({amount => $l->{their_balance}, money => 1});
            $l->{our_balance} = $recon->format_amount({amount => $l->{our_balance}, money => 1});
            $l->{their_debits} = $recon->format_amount({amount => $l->{their_debits}, money => 1});
            $l->{their_credits} = $recon->format_amount({amount => $l->{their_credits}, money => 1});
            $l->{our_debits} = $recon->format_amount({amount => $l->{our_debits}, money => 1});
            $l->{our_credits} = $recon->format_amount({amount => $l->{our_credits}, money => 1});
        }
	$recon->{statement_gl_calc} = $recon->{their_total} 
		+ $recon->{outstanding_total};
	$recon->{out_of_balance} = $recon->{their_total} - $recon->{our_total};
        $recon->{cleared_total} = $recon->format_amount({amount => $recon->{cleared_total}, money => 1});
        $recon->{outstanding_total} = $recon->format_amount({amount => $recon->{outstanding_total}, money => 1});
        $recon->{statement_gl_calc} = $recon->format_amount({amount => $recon->{statement_gl_calc}, money => 1});
        $recon->{total_cleared_debits} = $recon->format_amount(
              {amount => $recon->{total_cleared_debits}, money => 1}
        );
        $recon->{total_cleared_credits} = $recon->format_amount(
               {amount => $recon->{total_cleared_credits}, money => 1}
        );
        $recon->{total_uncleared_debits} = $recon->format_amount(
              {amount => $recon->{total_uncleared_debits}, money => 1}
        );
        $recon->{total_uncleared_credits} = $recon->format_amount(
               {amount => $recon->{total_uncleared_credits}, money => 1}
        );
	$recon->{their_total} = $recon->format_amount(
		{amount => $recon->{their_total}, money => 1});
	$recon->{our_total} = $recon->format_amount(
		{amount => $recon->{our_total}, money => 1});
	$recon->{beginning_balance} = $recon->format_amount(
		{amount => $recon->{beginning_balance}, money => 1});
	$recon->{out_of_balance} = $recon->format_amount(
		{amount => $recon->{out_of_balance}, money => 1});

        return $template->render($recon);
}

sub new_report {
    my ($request) = @_;
    # how are we going to allow this to be created? Grr.
    # probably select a list of statements that are available to build 
    # reconciliation reports with.
    
    # This should do some fun stuff.
    
    my $template;
    my $return;
    my $recon = LedgerSMB::DBObject::Reconciliation->new(base => $request, copy => 'all'); 
    if ($request->type() eq "POST") {
        
        # We can assume that we're doing something useful with new data.
        # We can also assume that we've got a file.
        
        # $self is expected to have both the file handling logic, as well as 
        # the logic to load the processing module.
        
        # Why isn't this testing for errors?
        my ($report_id, $entries) = $recon->new_report($recon->import_file());
        $recon->{dbh}->commit;
        if ($recon->{error}) {
            $recon->{error};
            
            $template = LedgerSMB::Template->new(
                user=>$user,
                template=> 'reconciliation/upload',
                language=>$user->{language},
                format=>'HTML',
                path=>"UI"
            );
            return $template->render($recon);
        }
        _display_report($recon);
    }
    else {
        
        # we can assume we're to generate the "Make a happy new report!" page.
        @{$recon->{accounts}} = $recon->get_accounts;
        $template = LedgerSMB::Template->new( 
            user => $user, 
            template => 'reconciliation/upload', 
            language => $user->{language}, 
            format => 'HTML',
            path=>"UI"
        );
        return $template->render($recon);
    }
    return undef;
    
}

=pod

=over

=item approve ($self, $request, $user)

Requires report_id

Approves the given report based on id. Generally, the roles should be 
configured so as to disallow the same user from approving, as created the report.

Returns a success page on success, returns a new report on failure, showing 
the uncorrected entries.

=back

=cut

sub approve {
    my ($request) = @_;
    
    # Approve will also display the report in a blurred/opaqued out version,
    # with the controls removed/disabled, so that we know that it has in fact
    # been cleared. This will also provide for return-home links, auditing, 
    # etc.
    
    if ($request->type() eq "POST") {
        
        # we need a report_id for this.
        
        my $recon = LedgerSMB::DBObject::Reconciliation->new(base => $request, copy=> 'all');

        my $template;
        my $code = $recon->approve($request->{report_id});
        if ($code == 0) {

            $template = LedgerSMB::Template->new( user => $user, 
        	template => 'reconciliation/approved', language => $user->{language}, 
                format => 'HTML',
                path=>"UI"
                );
                
            return $template->render($recon);
        }
        else {
            
            # failure case
            
            $template = LedgerSMB::Template->new( 
                user => $user, 
        	    template => 'reconciliation/report', 
        	    language => $user->{language}, 
                format => 'HTML',
                path=>"UI"
                );
            return $template->render($recon
            );
        }
    }
    else {
        return $class->display_report($request);
    }
}

=pod

=over

=item corrections ($self, $request, $user)

Requires report_id and entry_id.

Loads the selected entry id and all corrections associated with it. If there
aren't any corrections, it will display "no corrections found".
=back

=cut

sub corrections {
    my ($request) = @_;
    
    # Load the corrections for a given report & entry id.
    # possibly should use a "micro" popup window?
    
    my $recon = LedgerSMB::DBObject::Reconciliation->new(base => request, copy=> 'all');
    
    my $template;
        
    $template = LedgerSMB::Template->new( user => $user, 
	template => 'reconciliation/corrected', language => $user->{language}, 
        format => 'HTML', path=>"UI");
    
    return $template->render(
        {
            corrections=>$recon->get_corrections(), 
            entry=>$recon->entry($self->{report_id}, $self->{entry_id})
        }
    );
}

=pod

=over

=item pending ($self, $request, $user)

Requires {date} and {month}, to handle the month-to-month pending transactions
in the database. No mechanism is provided to grab ALL pending transactions 
from the acc_trans table.

=back

=cut


sub pending {
    
    my ($request) = @_;
    
    my $recon = LedgerSMB::DBObject::Reconciliation->new(base=>$request, copy=>'all');
    my $template;
    
    $template= LedgerSMB::Template->new(
        user => $user,
        template=>'reconciliation/pending',
        language=>$user->{language},
        format=>'HTML',
        path=>"UI"
    );
    if ($request->type() eq "POST") {
        return $template->render(
            {
                pending=>$recon->get_pending($request->{year}."-".$request->{month})
            }
        );
    } 
    else {
        
        return $template->render();
    }
}

sub __default {
    
    my ($request) = @_;
    
    $request->error(Dumper($request));
    
    my $recon = LedgerSMB::DBObject::Reconciliation->new(base=>$request, copy=>'all');
    my $template;
    
    $template = LedgerSMB::Template->new(
        user => $user,
        template => 'reconciliation/list',
        language => $user->{language},
        format=>'HTML',
        path=>"UI"
    );
    return $template->render(
        {
            reports=>$recon->get_report_list()
        }
    );
}

# eval { do "scripts/custom/Reconciliation.pl" };
1;

=pod

=head1 Copyright (C) 2007, The LedgerSMB core team.

This file is licensed under the Gnu General Public License version 2, or at your
option any later version.  A copy of the license should have been included with
your software.

=cut
