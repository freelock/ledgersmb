#=====================================================================
# LedgerSMB
# Small Medium Business Accounting software
# http://www.ledgersmb.org/
#
# Copyright (C) 2006
# This work contains copyrighted information from a number of sources all used
# with permission.
#
# This file contains source code included with or based on SQL-Ledger which
# is Copyright Dieter Simader and DWS Systems Inc. 2000-2005 and licensed
# under the GNU General Public License version 2 or, at your option, any later
# version.  For a full list including contact information of contributors,
# maintainers, and copyright holders, see the CONTRIBUTORS file.
#
# Original Copyright Notice from SQL-Ledger 2.6.17 (before the fork):
# Copyright (C) 2001
#
#  Author: DWS Systems Inc.
#     Web: http://www.sql-ledger.org
#
#  Contributors:
#
#======================================================================
#
# This file has undergone whitespace cleanup.
#
#======================================================================
#
# backend code for reports
#
#======================================================================

package RP;
use Log::Log4perl;
our $logger = Log::Log4perl->get_logger('LedgerSMB::Form');

sub balance_sheet {
    my ( $self, $myconfig, $form ) = @_;

    my $dbh = $form->{dbh};

    my $last_period = 0;
    my @categories  = qw(A L Q);

    my $null;

    if ( $form->{asofdate} ) {
        if ( $form->{asofyear} && $form->{asofmonth} ) {
            if ( $form->{asofdate} !~ /\W/ ) {
                $form->{asofdate} =
                  "$form->{asofyear}$form->{asofmonth}$form->{asofdate}";
            }
        }
    }
    else {
        if ( $form->{fromyear} && $form->{frommonth} ) {
            ( $null, $form->{asofdate} ) =
              $form->from_to( $form->{fromyear}, $form->{frommonth} );
        }
    }

    # if there are any dates construct a where
    if ( $form->{asofdate} ) {

        $form->{this_period} = "$form->{asofdate}";
        $form->{period}      = "$form->{asofdate}";

    }

    $form->{decimalplaces} *= 1;

    &get_accounts( $dbh, $last_period, "", $form->{asofdate}, $form,
        \@categories, 1 );

    if ( $form->{compareasofdate} ) {
        if ( $form->{compareasofyear} && $form->{compareasofmonth} ) {
            if ( $form->{compareasofdate} !~ /\W/ ) {
                $form->{compareasofdate} =
"$form->{compareasofyear}$form->{compareasofmonth}$form->{compareasofdate}";
            }
        }
    }
    else {
        if ( $form->{compareasofyear} && $form->{compareasofmonth} ) {
            ( $null, $form->{compareasofdate} ) =
              $form->from_to( $form->{compareasofyear},
                $form->{compareasofmonth} );
        }
    }

    # if there are any compare dates
    if ( $form->{compareasofdate} ) {

        $last_period = 1;
        &get_accounts( $dbh, $last_period, "", $form->{compareasofdate},
            $form, \@categories, 1 );

        $form->{last_period} = "$form->{compareasofdate}";

    }

    $dbh->commit;

    # now we got $form->{A}{accno}{ }    assets
    # and $form->{L}{accno}{ }           liabilities
    # and $form->{Q}{accno}{ }           equity
    # build asset accounts

    my $str;
    my $key;

    my %account = (
        'A' => {
            'label'  => 'asset',
            'labels' => 'assets',
            'ml'     => -1
        },
        'L' => {
            'label'  => 'liability',
            'labels' => 'liabilities',
            'ml'     => 1
        },
        'Q' => {
            'label'  => 'equity',
            'labels' => 'equity',
            'ml'     => 1
        }
    );

    foreach $category (@categories) {

        foreach $key ( sort keys %{ $form->{$category} } ) {

##            $str = ( $form->{l_heading} ) ? $form->{padding} : "";
            $str = "";

            if ( $form->{$category}{$key}{charttype} eq "A" ) {
                $str .=
                  ( $form->{l_accno} )
                  ? "$form->{$category}{$key}{accno} - $form->{$category}{$key}{description}"
                  : "$form->{$category}{$key}{description}";
                $str = {account => $form->{$category}{$key}{accno}, text => $str};
                $str->{gifi_account} = 1 if $form->{accounttype} eq 'gifi';
            }
            elsif ( $form->{$category}{$key}{charttype} eq "H" ) {
                if (   $account{$category}{subtotal}
                    && $form->{l_subtotal} )
                {

                    $dash = "- ";
                    push(
                        @{ $form->{"$account{$category}{label}_account"} },
                        {
                            text => "$account{$category}{subdescription}",
                            subtotal => 1
                            },
                    );
                    push(
                        @{ $form->{"$account{$category}{label}_this_period"} },
                        $form->format_amount(
                            $myconfig,
                            $account{$category}{subthis} *
                              $account{$category}{ml},
                            $form->{decimalplaces},
                            $dash
                        )
                    );

                    if ($last_period) {
                        push(
                            @{
                                $form->{
                                    "$account{$category}{label}_last_period"}
                              },
                            $form->format_amount(
                                $myconfig,
                                $account{$category}{sublast} *
                                  $account{$category}{ml},
                                $form->{decimalplaces},
                                $dash
                            )
                        );
                    }
                }

                $str = {
                    text => "$form->{$category}{$key}{description}",
                    heading => 1
                    };

                $account{$category}{subthis} = $form->{$category}{$key}{this};
                $account{$category}{sublast} = $form->{$category}{$key}{last};
                $account{$category}{subdescription} =
                  $form->{$category}{$key}{description};
                $account{$category}{subtotal} = 1;

                $form->{$category}{$key}{this} = 0;
                $form->{$category}{$key}{last} = 0;

                next unless $form->{l_heading};

                $dash = " ";
            }

            # push description onto array
            push( @{ $form->{"$account{$category}{label}_account"} }, $str );

            if ( $form->{$category}{$key}{charttype} eq 'A' ) {
                $form->{"total_$account{$category}{labels}_this_period"} +=
                  $form->{$category}{$key}{this} * $account{$category}{ml};
                $dash = "- ";
            }

            push(
                @{ $form->{"$account{$category}{label}_this_period"} },
                $form->format_amount(
                    $myconfig,
                    $form->{$category}{$key}{this} * $account{$category}{ml},
                    $form->{decimalplaces}, $dash
                )
            );

            if ($last_period) {
                $form->{"total_$account{$category}{labels}_last_period"} +=
                  $form->{$category}{$key}{last} * $account{$category}{ml};

                push(
                    @{ $form->{"$account{$category}{label}_last_period"} },
                    $form->format_amount(
                        $myconfig,
                        $form->{$category}{$key}{last} *
                          $account{$category}{ml},
                        $form->{decimalplaces},
                        $dash
                    )
                );
            }
        }

	#$str = ( $form->{l_heading} ) ? $form->{padding} : "";
        $str = "";
        if ( $account{$category}{subtotal} && $form->{l_subtotal} ) {
            push(
                @{ $form->{"$account{$category}{label}_account"} }, {
                    text => "$account{$category}{subdescription}",
                    subtotal => 1,
                    },
            );
            push(
                @{ $form->{"$account{$category}{label}_this_period"} },
                $form->format_amount(
                    $myconfig,
                    $account{$category}{subthis} * $account{$category}{ml},
                    $form->{decimalplaces}, $dash
                )
            );

            if ($last_period) {
                push(
                    @{ $form->{"$account{$category}{label}_last_period"} },
                    $form->format_amount(
                        $myconfig,
                        $account{$category}{sublast} * $account{$category}{ml},
                        $form->{decimalplaces},
                        $dash
                    )
                );
            }
        }

    }

    # totals for assets, liabilities
    $form->{total_assets_this_period} =
      $form->round_amount( $form->{total_assets_this_period},
        $form->{decimalplaces} );
    $form->{total_liabilities_this_period} =
      $form->round_amount( $form->{total_liabilities_this_period},
        $form->{decimalplaces} );
    $form->{total_equity_this_period} =
      $form->round_amount( $form->{total_equity_this_period},
        $form->{decimalplaces} );

    # calculate earnings
    $form->{earnings_this_period} =
      $form->{total_assets_this_period} -
      $form->{total_liabilities_this_period} -
      $form->{total_equity_this_period};

    push(
        @{ $form->{equity_this_period} },
        $form->format_amount(
            $myconfig,              $form->{earnings_this_period},
            $form->{decimalplaces}, "- "
        )
    );

    $form->{total_equity_this_period} =
      $form->round_amount(
        $form->{total_equity_this_period} + $form->{earnings_this_period},
        $form->{decimalplaces} );

    # add liability + equity
    $form->{total_this_period} = $form->format_amount(
        $myconfig,
        $form->{total_liabilities_this_period} +
          $form->{total_equity_this_period},
        $form->{decimalplaces},
        "- "
    );

    if ($last_period) {

        # totals for assets, liabilities
        $form->{total_assets_last_period} =
          $form->round_amount( $form->{total_assets_last_period},
            $form->{decimalplaces} );
        $form->{total_liabilities_last_period} =
          $form->round_amount( $form->{total_liabilities_last_period},
            $form->{decimalplaces} );
        $form->{total_equity_last_period} =
          $form->round_amount( $form->{total_equity_last_period},
            $form->{decimalplaces} );

        # calculate retained earnings
        $form->{earnings_last_period} =
          $form->{total_assets_last_period} -
          $form->{total_liabilities_last_period} -
          $form->{total_equity_last_period};

        push(
            @{ $form->{equity_last_period} },
            $form->format_amount(
                $myconfig,              $form->{earnings_last_period},
                $form->{decimalplaces}, "- "
            )
        );

        $form->{total_equity_last_period} =
          $form->round_amount(
            $form->{total_equity_last_period} + $form->{earnings_last_period},
            $form->{decimalplaces} );

        # add liability + equity
        $form->{total_last_period} = $form->format_amount(
            $myconfig,
            $form->{total_liabilities_last_period} +
              $form->{total_equity_last_period},
            $form->{decimalplaces},
            "- "
        );

    }

    $form->{total_liabilities_last_period} = $form->format_amount(
        $myconfig,
        $form->{total_liabilities_last_period},
        $form->{decimalplaces}, "- "
    ) if ( $form->{total_liabilities_last_period} );

    $form->{total_equity_last_period} = $form->format_amount(
        $myconfig,
        $form->{total_equity_last_period},
        $form->{decimalplaces}, "- "
    ) if ( $form->{total_equity_last_period} );

    $form->{total_assets_last_period} = $form->format_amount(
        $myconfig,
        $form->{total_assets_last_period},
        $form->{decimalplaces}, "- "
    ) if ( $form->{total_assets_last_period} );

    $form->{total_assets_this_period} = $form->format_amount(
        $myconfig,
        $form->{total_assets_this_period},
        $form->{decimalplaces}, "- "
    );

    $form->{total_liabilities_this_period} = $form->format_amount(
        $myconfig,
        $form->{total_liabilities_this_period},
        $form->{decimalplaces}, "- "
    );

    $form->{total_equity_this_period} = $form->format_amount(
        $myconfig,
        $form->{total_equity_this_period},
        $form->{decimalplaces}, "- "
    );

}

sub get_accounts {
    my ( $dbh, $last_period, $fromdate, $todate, $form, $categories,
        $excludeyearend )
      = @_;

    my $department_id;
    my $project_id;

    ( $null, $department_id ) = split /--/, $form->{department};
    ( $null, $project_id )    = split /--/, $form->{projectnumber};

    my $query;
    my $dpt_where;
    my $dpt_join;
    my $project;
    my $where        = "1 = 1";
    my $glwhere      = "";
    my $subwhere     = "";
    my $yearendwhere = "1 = 1";
    my $item;

    my $category = "AND (";
    foreach $item ( @{$categories} ) {
        $category .= qq|c.category = | . $dbh->quote($item) . qq| OR |;
    }
    $category =~ s/OR $/\)/;

    # get headings
    $query = qq|
		  SELECT accno, description, category
		    FROM chart c
		   WHERE c.charttype = 'H' $category
		ORDER BY c.accno|;

    if ( $form->{accounttype} eq 'gifi' ) {
        $query = qq|
		  SELECT g.accno, g.description, c.category
		    FROM gifi g
		    JOIN chart c ON (c.gifi_accno = g.accno)
		   WHERE c.charttype = 'H' $category
		ORDER BY g.accno|;
    }

    $sth = $dbh->prepare($query);
    $sth->execute || $form->dberror($query);

    my @headingaccounts = ();
    while ( $ref = $sth->fetchrow_hashref(NAME_lc) ) {
        $form->{ $ref->{category} }{ $ref->{accno} }{description} =
          "$ref->{description}";

        $form->{ $ref->{category} }{ $ref->{accno} }{charttype} = "H";
        $form->{ $ref->{category} }{ $ref->{accno} }{accno}     = $ref->{accno};

        push @headingaccounts, $ref->{accno};
    }

    $sth->finish;

    if ( $form->{method} eq 'cash' && !$todate ) {
        ($todate) = $dbh->selectrow_array(qq|SELECT current_date|);
    }

    if ($fromdate) {
        if ( $form->{method} eq 'cash' ) {
            $subwhere .= " AND transdate >= " . $dbh->quote($fromdate);
            $glwhere = " AND ac.transdate >= " . $dbh->quote($fromdate);
        }
        else {
            $where .= " AND ac.transdate >= " . $dbh->quote($fromdate);
        }
    }

    if ($todate) {
        $where    .= " AND ac.transdate <= " . $dbh->quote($todate);
        $subwhere .= " AND transdate <= " . $dbh->quote($todate);
        $yearendwhere = "ac.transdate < " . $dbh->quote($todate);
    }

    if ($excludeyearend) {
        $ywhere = "
			AND ac.trans_id NOT IN (SELECT trans_id FROM yearend)";

        if ($todate) {
            $ywhere = " 
				AND ac.trans_id NOT IN 
				(SELECT trans_id FROM yearend
				  WHERE transdate <= " . $dbh->quote($todate) . ")";
        }

        if ($fromdate) {
            $ywhere = "
				AND ac.trans_id NOT IN 
				(SELECT trans_id FROM yearend
				  WHERE transdate >= " . $dbh->quote($fromdate) . ")";
            if ($todate) {
                $ywhere = " 
					AND ac.trans_id NOT IN
					(SELECT trans_id FROM yearend
					WHERE transdate >= "
                  . $dbh->quote($fromdate) . "
					      AND transdate <= " . $dbh->quote($todate) . ")";
            }
        }
    }

    if ($department_id) {
        $dpt_join = qq|
			JOIN department t ON (a.department_id = t.id)|;
        $dpt_where = qq|
			AND t.id = $department_id|;
    }

    if ($project_id) {
        $project = qq|
			AND ac.project_id = $project_id|;
    }
    if (!defined $form->{approved}){
        $approved = 'true';
    } elsif ($form->{approved} eq 'all')  {
        $approved = 'NULL';
    } else {
        $approved = $dbh->quote($form->{approved});
    }

    if ( $form->{accounttype} eq 'gifi' ) {

        if ( $form->{method} eq 'cash' ) {

            $query = qq|
				  SELECT g.accno, sum(ac.amount) AS amount,
				         g.description, c.category
				    FROM acc_trans ac
				    JOIN chart c ON (c.id = ac.chart_id)
				    JOIN ar a ON (a.id = ac.trans_id)
				    JOIN gifi g ON (g.accno = c.gifi_accno)
				    $dpt_join
				   WHERE $where $ywhere $dpt_where $category
				         AND ac.trans_id IN (
				         SELECT trans_id
				           FROM acc_trans
					   JOIN chart ON (chart_id = id)
				          WHERE link LIKE '%AR_paid%'
				                $subwhere)
				$project
				GROUP BY g.accno, g.description, c.category
		 
				UNION ALL

				  SELECT '' AS accno, SUM(ac.amount) AS amount,
				         '' AS description, c.category
				    FROM acc_trans ac
				    JOIN chart c ON (c.id = ac.chart_id)
				    JOIN ar a ON (a.id = ac.trans_id)
				    $dpt_join
				   WHERE $where $ywhere $dpt_where $category
				         AND c.gifi_accno = '' AND 
				         ac.trans_id IN
				         (SELECT trans_id FROM acc_trans
				            JOIN chart ON (chart_id = id)
				           WHERE link LIKE '%AR_paid%'
				         $subwhere) $project
				GROUP BY c.category

				UNION ALL

				  SELECT g.accno, sum(ac.amount) AS amount,
				         g.description, c.category
				    FROM acc_trans ac
				    JOIN chart c ON (c.id = ac.chart_id)
				    JOIN ap a ON (a.id = ac.trans_id)
				    JOIN gifi g ON (g.accno = c.gifi_accno)
				$dpt_join
				   WHERE $where $ywhere $dpt_where $category
				         AND ac.trans_id IN
				         (SELECT trans_id FROM acc_trans
				            JOIN chart ON (chart_id = id)
				           WHERE link LIKE '%AP_paid%'
				                 $subwhere) $project
				GROUP BY g.accno, g.description, c.category
		 
				UNION ALL
       
				  SELECT '' AS accno, SUM(ac.amount) AS amount,
				         '' AS description, c.category
				    FROM acc_trans ac
				    JOIN chart c ON (c.id = ac.chart_id)
				    JOIN ap a ON (a.id = ac.trans_id)
				 $dpt_join
				   WHERE $where $ywhere $dpt_where $category
				         AND c.gifi_accno = '' 
				         AND ac.trans_id IN
				         (SELECT trans_id FROM acc_trans
				            JOIN chart ON (chart_id = id)
				   WHERE link LIKE '%AP_paid%' $subwhere)
				         $project
				GROUP BY c.category

				UNION ALL

				  SELECT g.accno, sum(ac.amount) AS amount,
				         g.description, c.category
				    FROM acc_trans ac
				    JOIN chart c ON (c.id = ac.chart_id)
				    JOIN gifi g ON (g.accno = c.gifi_accno)
				    JOIN gl a ON (a.id = ac.trans_id)
				$dpt_join
				   WHERE $where $ywhere $glwhere $dpt_where
				         $category AND NOT 
				         (c.link = 'AR' OR c.link = 'AP')
				         $project
				GROUP BY g.accno, g.description, c.category
		 
				UNION ALL

				  SELECT '' AS accno, SUM(ac.amount) AS amount,
				         '' AS description, c.category
				    FROM acc_trans ac
				    JOIN chart c ON (c.id = ac.chart_id)
				    JOIN gl a ON (a.id = ac.trans_id)
				$dpt_join
				   WHERE $where $ywhere $glwhere $dpt_where
				         $category AND c.gifi_accno = ''
				         AND NOT 
				         (c.link = 'AR' OR c.link = 'AP')
				         $project
				GROUP BY c.category|;

            if ($excludeyearend) {

                $query .= qq|

					UNION ALL

					  SELECT g.accno, 
					         sum(ac.amount) AS amount,
					         g.description, c.category
					    FROM yearend y
					    JOIN gl a ON (a.id = y.trans_id)
					    JOIN acc_trans ac 
					         ON (ac.trans_id = y.trans_id)
					    JOIN chart c 
					         ON (c.id = ac.chart_id)
					    JOIN gifi g 
					         ON (g.accno = c.gifi_accno) 
					$dpt_join
					   WHERE $yearendwhere 
					         AND c.category = 'Q' 
					         $dpt_where $project
					GROUP BY g.accno, g.description, 
					         c.category|;
            }

        }
        else {

            if ($department_id) {
                $dpt_join = qq|
					JOIN dpt_trans t 
					     ON (t.trans_id = ac.trans_id)|;
                $dpt_where = qq|
					AND t.department_id = | . $dbh->quote($department_id);
            }

            $query = qq|
				  SELECT g.accno, SUM(ac.amount) AS amount,
				         g.description, c.category
				    FROM acc_trans ac
				    JOIN chart c ON (c.id = ac.chart_id)
				    JOIN gifi g ON (c.gifi_accno = g.accno)
				    JOIN (SELECT id, approved FROM gl UNION
				          SELECT id, approved FROM ar UNION
				          SELECT id, approved FROM ap) gl
				         ON (ac.trans_id = gl.id)
				         $dpt_join
				   WHERE $where $ywhere $dpt_where $category
				         AND gl.approved AND ac.approved
				         $project
				GROUP BY g.accno, g.description, c.category
	      
				UNION ALL
	   
				  SELECT '' AS accno, SUM(ac.amount) AS amount,
				         '' AS description, c.category
				    FROM acc_trans ac
				    JOIN chart c ON (c.id = ac.chart_id)
				         $dpt_join
				   WHERE $where $ywhere $dpt_where $category
				         AND c.gifi_accno = '' $project
				GROUP BY c.category|;

            if ($excludeyearend) {

                $query .= qq|

						UNION ALL

						  SELECT g.accno, 
						         sum(ac.amount) 
						         AS amount,
						         g.description, 
						         c.category
						    FROM yearend y
						    JOIN gl a 
						         ON (a.id = y.trans_id)
						    JOIN acc_trans ac 
						         ON (ac.trans_id = 
						         y.trans_id)
						    JOIN chart c 
						         ON 
						         (c.id = ac.chart_id)
						    JOIN gifi g 
						         ON (g.accno = 
						         c.gifi_accno)
						         $dpt_join
						   WHERE $yearendwhere
						         AND c.category = 'Q'
						         $dpt_where $project
						GROUP BY g.accno, 
						         g.description, 
						         c.category|;
            }
        }

    }
    else {    # standard account

        if ( $form->{method} eq 'cash' ) {

            $query = qq|
			  SELECT c.accno, sum(ac.amount) AS amount,
			         c.description, c.category
			    FROM acc_trans ac
			    JOIN chart c ON (c.id = ac.chart_id)
			    JOIN ar a ON (a.id = ac.trans_id) $dpt_join
			   WHERE $where $ywhere $dpt_where $category 
			         AND ac.trans_id IN (
			         SELECT trans_id FROM acc_trans
			           JOIN chart ON (chart_id = id)
			          WHERE link LIKE '%AR_paid%' $subwhere)
			         $project
			GROUP BY c.accno, c.description, c.category

			UNION ALL
	
			  SELECT c.accno, sum(ac.amount) AS amount,
			         c.description, c.category
			    FROM acc_trans ac
			    JOIN chart c ON (c.id = ac.chart_id)
			    JOIN ap a ON (a.id = ac.trans_id) $dpt_join
			   WHERE $where $ywhere $dpt_where $category
			         AND ac.trans_id IN (
			         SELECT trans_id FROM acc_trans
			           JOIN chart ON (chart_id = id)
			          WHERE link LIKE '%AP_paid%' $subwhere)
			         $project
			GROUP BY c.accno, c.description, c.category
		 
			UNION ALL

			  SELECT c.accno, sum(ac.amount) AS amount,
			         c.description, c.category
			    FROM acc_trans ac
			    JOIN chart c ON (c.id = ac.chart_id)
			    JOIN gl a ON (a.id = ac.trans_id) $dpt_join
			   WHERE $where $ywhere $glwhere $dpt_where $category
			         AND NOT (c.link = 'AR' OR c.link = 'AP')
			         $project
			GROUP BY c.accno, c.description, c.category|;

            if ($excludeyearend) {

                # this is for the yearend

                $query .= qq|

 					UNION ALL

					  SELECT c.accno, 
					         sum(ac.amount) AS amount,
					         c.description, c.category
					    FROM yearend y
					    JOIN gl a ON (a.id = y.trans_id)
					    JOIN acc_trans ac 
					         ON (ac.trans_id = y.trans_id)
					    JOIN chart c 
					         ON (c.id = ac.chart_id)
					         $dpt_join
					   WHERE $yearendwhere AND 
					         c.category = 'Q' $dpt_where
					         $project
					GROUP BY c.accno, c.description, 
					         c.category|;
            }

        }
        else {

            if ($department_id) {
                $dpt_join = qq|
					JOIN dpt_trans t 
					     ON (t.trans_id = ac.trans_id)|;
                $dpt_where =
                  qq| AND t.department_id = | . $dbh->quote($department_id);
            }

            $query = qq|
				  SELECT c.accno, sum(ac.amount) AS amount,
				         c.description, c.category
				    FROM acc_trans ac
				    JOIN (SELECT id, approved FROM ar
				          UNION
                                          SELECT id, approved FROM ap
                                          UNION
                                          SELECT id, approved FROM gl
                                          ) g ON (ac.trans_id = g.id)
				    JOIN chart c ON (c.id = ac.chart_id)
				         $dpt_join
				   WHERE $where $ywhere $dpt_where $category
				         $project
					  AND ($approved IS NULL OR
						$approved = 
					        (ac.approved AND g.approved))
				GROUP BY c.accno, c.description, c.category|;

            if ($excludeyearend) {

                $query .= qq|

					UNION ALL
       
					  SELECT c.accno, 
					         sum(ac.amount) AS amount,
					         c.description, c.category
					    FROM yearend y
					    JOIN gl a ON (a.id = y.trans_id)
					    JOIN acc_trans ac 
					         ON (ac.trans_id = y.trans_id)
					    JOIN chart c 
					         ON (c.id = ac.chart_id)
					         $dpt_join
					   WHERE $yearendwhere AND 
					         c.category = 'Q' $dpt_where
					         $project
					GROUP BY c.accno, c.description, 
					         c.category|;
            }
        }
    }

    my @accno;
    my $accno;
    my $ref;

    my $sth = $dbh->prepare($query);
    $sth->execute || $form->dberror($query);

    while ( $ref = $sth->fetchrow_hashref(NAME_lc) ) {

        $form->db_parse_numeric(sth=>$sth, hashref=>$ref);
        # get last heading account
        @accno = grep { $_ le "$ref->{accno}" } @headingaccounts;
        $accno = pop @accno;
        if ( $accno && ( $accno ne $ref->{accno} ) ) {
            if ($last_period) {
                $form->{ $ref->{category} }{$accno}{last} += $ref->{amount};
            }
            else {
                $form->{ $ref->{category} }{$accno}{this} += $ref->{amount};
            }
        }

        $form->{ $ref->{category} }{ $ref->{accno} }{accno} = $ref->{accno};
        $form->{ $ref->{category} }{ $ref->{accno} }{description} =
          $ref->{description};
        $form->{ $ref->{category} }{ $ref->{accno} }{charttype} = "A";

        if ($last_period) {
            $form->{ $ref->{category} }{ $ref->{accno} }{last} +=
              $ref->{amount};
        }
        else {
            $form->{ $ref->{category} }{ $ref->{accno} }{this} +=
              $ref->{amount};
        }
    }
    $sth->finish;

    # remove accounts with zero balance
    foreach $category ( @{$categories} ) {
        foreach $accno ( keys %{ $form->{$category} } ) {
            $form->{$category}{$accno}{last} =
              $form->round_amount( $form->{$category}{$accno}{last},
                $form->{decimalplaces} );
            $form->{$category}{$accno}{this} =
              $form->round_amount( $form->{$category}{$accno}{this},
                $form->{decimalplaces} );

            delete $form->{$category}{$accno}
              if ( $form->{$category}{$accno}{this} == 0
                && $form->{$category}{$accno}{last} == 0 );
        }
    }

}

sub get_taxaccounts {
    my ( $self, $myconfig, $form ) = @_;

    my $dbh  = $form->{dbh};
    my $ARAP = uc $form->{db};

    # get tax accounts
    my $query = qq|
		  SELECT DISTINCT a.accno, a.description
		    FROM account a
		   WHERE a.tax is true
                ORDER BY a.accno|;
    my $sth = $dbh->prepare($query);
    $sth->execute || $form->dberror;

    my $ref = ();
    while ( $ref = $sth->fetchrow_hashref(NAME_lc) ) {
        push @{ $form->{taxaccounts} }, $ref;
    }
    $sth->finish;

    # get gifi tax accounts
    $query = qq|
		  SELECT DISTINCT g.accno, g.description
		    FROM gifi g
		    JOIN chart c ON (c.gifi_accno= g.accno)
		    JOIN tax t ON (c.id = t.chart_id)
		   WHERE c.link LIKE '%${ARAP}_tax%'
		ORDER BY accno|;
    $sth = $dbh->prepare($query);
    $sth->execute || $form->dberror;

    while ( $ref = $sth->fetchrow_hashref(NAME_lc) ) {
        push @{ $form->{gifi_taxaccounts} }, $ref;
    }
    $sth->finish;

    $dbh->commit;

}

sub inventory_accounts {
    my ( $self, $myconfig, $form ) = @_;
    my $dbh = $form->{dbh};
    my $query = qq|
		SELECT id, accno, description FROM chart
		 WHERE link = 'IC'
		 ORDER BY accno|;
    my $sth = $dbh->prepare($query);
    $sth->execute || $form->dberror($query);
    while ( my $ref = $sth->fetchrow_hashref(NAME_lc) ) {
        push @{ $form->{selectIC} }, $ref;
    }
    $sth->finish;
    $dbh->{dbh};
}

sub inventory {
    my ( $self, $myconfig, $form ) = @_;
    my $dbh = $form->{dbh};
    my $where_date = '';
    my $where_date = '';
    my $where_date_acc = '';
    my $where_product = '';
    my $where_chart = '';
    if($form->{fromdate}) {
	$where_date.=" AND a.transdate>='".$form->{fromdate}."' ";
	$where_date_acc.=" AND acc.transdate>='".$form->{fromdate}."' ";
    }
    if($form->{todate}) {
	$where_date.=" AND a.transdate<='".$form->{todate}."' ";
	$where_date_acc.=" AND acc.transdate<='".$form->{todate}."' ";
    }

    if($form->{partnumber}) {
	$where_product.= " AND partnumber LIKE '%".$form->{partnumber}."%' ";
    } 
    if($form->{description}) {
	$where_product.= " AND description LIKE '%".$form->{description}."%' ";
    } 
    if($form->{inventory_account}) {
	$where_chart .= " AND p.inventory_accno_id = ".$form->{inventory_account}." ";
    }

    my $query = qq|
	SELECT id, description, partnumber, sum(qty) as qty, sum(exited) as exited, sum(entered) as entered, sum(entered)-sum(exited) as value FROM 
	(
	    SELECT p.id, p.description, p.partnumber, -sum(i.qty) as qty, 0 as exited, 0 as entered
	    FROM invoice i 
	    JOIN ar a ON (a.id=i.trans_id $where_date) 
	    JOIN parts p ON (i.parts_id=p.id AND p.inventory_accno_id>0 $where_chart) 
	    GROUP BY p.id, p.description, p.partnumber 
	    
	    UNION ALL 
	    
	    SELECT p.id, p.description, p.partnumber, 0, sum(acc.amount) as exited, 0 as entered
	    FROM acc_trans acc 
	    JOIN parts p ON (p.inventory_accno_id=acc.chart_id AND p.inventory_accno_id>0 $where_chart) 
	    JOIN invoice i ON (i.id=acc.invoice_id AND i.parts_id=p.id) 
	    WHERE acc.trans_id NOT IN (SELECT id FROM ap) $where_date_acc  
	    GROUP BY p.id, p.description, p.partnumber 
	    
	    UNION ALL 
	    
	    SELECT p.id, p.description, p.partnumber, -sum(i.qty) as qty, 0 as exited, -sum(i.qty*i.sellprice) as entered
	    FROM invoice i 
	    JOIN ap a ON (a.id=i.trans_id $where_date) 
	    JOIN parts p ON (i.parts_id=p.id AND p.inventory_accno_id>0 $where_chart) 
	    GROUP BY p.id, p.description, p.partnumber
	) AS temp WHERE 1=1 $where_product GROUP BY id, description, partnumber HAVING sum(entered)-sum(exited)!=0 OR sum(qty)!=0 ORDER BY description;|;

    my $sth = $dbh->prepare($query);
    $sth->execute || $form->dberror($query);
    while ( my $ref = $sth->fetchrow_hashref(NAME_lc) ) {
        push @{ $form->{inventory} }, $ref;
    }
    $sth->finish;
    $dbh->{dbh};
}
1;
