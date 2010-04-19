use Test::More;
use LWP;
use LedgerSMB::Sysconfig;
use HTTP::Cookies;

if (!$ENV{'LSMB_TEST_LWP'}){
	plan 'skip_all' => 'LWP Test not enabled!';
} elsif ($ENV{'LSMB_INSTALL_DB'}){
        plan 'skip_all' => 'Tests not save for production db';
} else {
	plan 'no_plan';
}


my $host = $ENV{LSMB_BASE_URL} || 'http://localhost/ledgersmb/';
if ($host !~ /\/$/){
	$host .= "/";
};
$host =~ /https?:\/\/([^\/]+)\//;
$hostname = $1;
my $db = $ENV{LSMB_NEW_DB} || $ENV{PGDATABASE};
do 't/data/62-request-data'; # Import test case oashes
my $browser = LWP::UserAgent->new( );
if ($host !~ /https?:.+:/){
	if ($host =~ /http:/){
		$hport = 80;
	} elsif ($host =~ /https:/){
		$hport = 443;
	}
	$hostport = "$hostname:$hport";
} else {
	$hostport = "$hostname";
}

my $cookie = HTTP::Cookies->new;
$browser->credentials("$hostport", 'LedgerSMB', $ENV{LSMB_USER} => $ENV{LSMB_PASS});

my $login_url = "${host}login.pl?action=authenticate&company=$db";
my $response = $browser->get($login_url);

ok($response->is_success(), "Login cookie received");

$cookie->extract_cookies($response);
$browser->cookie_jar($cookie);

for my $test (@$test_request_data){
	next if $test->{_skip_lwp};
	my $argstr = "";
        my $module = "";
	for $key (keys %$test){
		# scan both key and value for _$GLOBAL$.
		# replace _$GLOBAL$:varname with the value from the %GLOBAL{varname}
		if ($key =~ /_\$GLOBAL\$:(.*)$/) {
			my $newkey = $GLOBAL{$1};
			$test->{$newkey} = $test->{$key};
			$key = $newkey;
		}
		if ($test->{$key} =~ /_\$GLOBAL\$:(.*)$/) {
			my $val = $GLOBAL{$1};
			$test->{$key} = $val;
		}
		if ($key eq 'module'){
			$module = $test->{"$key"}
		}
		elsif ($key !~ /^\_/){
			$argstr .= "&" . "$key=".$test->{"$key"};
		}
	}
	$argstr =~ s/^&//;
	my $url="$host$module?$argstr&company=$db";
	my $response = $browser->get($url);
	ok($response->is_success(), "$test->{_test_id} RESPONSE 200")
		|| print STDERR "# " .$response->status_line() . ":$url\n";
	if ($test->{format} eq 'PDF'){
		cmp_ok($response->header('content-type'), 'eq', 
			'application/pdf', "$test->{_test_id} PDF sent");
	} else {
		like($response->header('content-type'), qr/^text\/html/,
			"$test->{_test_id} HTML sent");
	}
	if (ref($test->{_lwp_tests}) eq 'CODE'){
		$test->{_lwp_tests}($response);
	}
	#cmp_ok(($response->content =~ /Error/), 'eq', "$test->{_lwp_error}", "No Error on Request $test->{_test_id}");
	#if ($response->content =~ /Error/){
	#	print STDERR $response->content;
	#}
}
