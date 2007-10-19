
=head1 NAME

LedgerSMB::Template - Template support module for LedgerSMB 

=head1 SYNOPSIS

This module renders templates.

=head1 METHODS

=over

=item new(user => \%myconfig, template => $string, format => $string, [locale => $locale] [language => $string], [include_path => $path], [no_auto_output => $bool], [method => $string], [no_escape => $bool], [debug => $bool], [output_file => $string] );

This command instantiates a new template:

=over

=item template

The template to be processed.  This can either be a reference to the template
in string form or the name of the file that is the template to be processed.

=item format

The format to be used.  Currently HTML, PS, PDF, TXT and CSV are supported.

=item format_options (optional)

A hash of format-specific options.  See the appropriate LSMB::T::foo for
details.

=item output_options (optional)

A hash of output-specific options.  See the appropriate output method for
details.

=item locale (optional)

The locale object to use for regular gettext lookups.  Having this option adds
the text function to the usable list for the templates.  Has no effect on the
gettext function.

=item language (optional)

The language for template selection.

=item include_path (optional)

Overrides the template directory.  Used with user interface templates.

=item no_auto_output (optional)

Disables the automatic output of rendered templates.

=item no_escape (optional)

Disables escaping on the template variables.

=item debug (optional)

Enables template debugging.

With the TT-based renderers, HTML, PS, PDF, TXT, and CSV, the portion of the
template to get debugging messages is to be surrounded by
<?lsmb DEBUG format 'foo' ?> statements.  Example:

    <tr><td colspan="<?lsmb columns.size ?>"></td></tr>
    <tr class="listheading">
  <?lsmb FOREACH column IN columns ?>
  <?lsmb DEBUG format '$file line $line : [% $text %]' ?>
      <th class="listtop"><?lsmb heading.$column ?></th>
  <?lsmb DEBUG format '' ?>
  <?lsmb END ?>
    </tr>

=item method/media (optional)

The output method to use, defaults to HTTP.  Media is a synonym for method

=item output_file (optional)

The base name of the file for output.

=back

=item new_UI(user => \%myconfig, locale => $locale, template => $file, ...)

Wrapper around the constructor that sets the path to 'UI', format to 'HTML',
and leaves auto-output enabled.

=item render($hashref)

This command renders the template.  If no_auto_output was not specified during
instantiation, this also writes the result to standard output and exits.
Otherwise it returns the name of the output file if a file was created.  When
no output file is created, the output is held in $self->{output}.

Currently email and server-side printing are not supported.

=item output

This function outputs the rendered file in an appropriate manner.

=item my $bool = _valid_language()

This command checks for valid langages.  Returns 1 if the language is valid, 
0 if it is not.

=back

=head1 Copyright 2007, The LedgerSMB Core Team

This file is licensed under the GNU General Public License version 2, or at your
option any later version.  A copy of the license should have been included with
your software.

=cut

package LedgerSMB::Template;

use warnings;
use strict;

use Error qw(:try);
use LedgerSMB::Sysconfig;
use LedgerSMB::Mailer;

sub new {
	my $class = shift;
	my $self = {};
	my %args = @_;

	$self->{myconfig} = $args{user};
	$self->{template} = $args{template};
	$self->{format} = $args{format};
	$self->{language} = $args{language};
	$self->{no_escape} = $args{no_escape};
	$self->{debug} = $args{debug};
	$self->{outputfile} =
		"${LedgerSMB::Sysconfig::tempdir}/$args{output_file}" if
		$args{output_file};
	$self->{include_path} = $args{path};
	$self->{locale} = $args{locale};
	$self->{noauto} = $args{no_auto_output};
	$self->{method} = $args{method};
	$self->{method} ||= $args{media};
	$self->{format_args} = $args{format_options};
	$self->{output_args} = $args{output_options};

	# SC: Muxing pre-format_args LaTeX format specifications.  Now with
	#     DVI support.
	if (lc $self->{format} eq 'dvi') {
		$self->{format} = 'LaTeX';
		$self->{format_args}{filetype} = 'dvi';
	} elsif (lc $self->{format} eq 'pdf') {
		$self->{format} = 'LaTeX';
		$self->{format_args}{filetype} = 'pdf';
	} elsif (lc $self->{format} eq 'ps' or lc $self->{format} eq 'postscript') {
		$self->{format} = 'LaTeX';
		$self->{format_args}{filetype} = 'ps';
	}	
	bless $self, $class;

	if ($self->{format} !~ /^\p{IsAlnum}+$/) {
		throw Error::Simple "Invalid format";
	}
	if (!$self->{include_path}){
## SC: XXX hardcoding due to config migration, will need adjustment
		$self->{include_path} = $self->{'myconfig'}->{'templates'};
		$self->{include_path} ||= 'templates/demo';
		if (defined $self->{language}){
			if (!$self->_valid_language){
				throw Error::Simple 'Invalid language';
				return undef;
			}
			$self->{include_path} = "$self->{'include_path'}"
					."/$self->{language}"
					.";$self->{'include_path'}"
		}
	}

	return $self;
}

sub new_UI {
	my $class = shift;
	return $class->new(@_, no_auto_ouput => 0, format => 'HTML', path => 'UI');
}

sub _valid_language {
	my $self = shift;
	if ($self->{language} =~ m#(/|\\|:|\.\.|^\.)#){
		return 0;
	}
	return 1;
}

sub render {
	my $self = shift;
	my $vars = shift;
	if ($self->{format} !~ /^\p{IsAlnum}+$/) {
		throw Error::Simple "Invalid format";
	}
	my $format = "LedgerSMB::Template::$self->{format}";

	eval "require $format";
	if ($@) {
		throw Error::Simple $@;
	}

	my $cleanvars;
	if ($self->{no_escape}) {
		$cleanvars = $vars;
	} else {
		$cleanvars = $format->can('preprocess')->($vars);
	}

	if (UNIVERSAL::isa($self->{locale}, 'LedgerSMB::Locale')){
		$cleanvars->{text} = sub { return $self->{locale}->text(@_)};
	} else {
                $cleanvars->{text} = sub { return shift @_ };
        }

	$format->can('process')->($self, $cleanvars);
	#return $format->can('postprocess')->($self);
	my $post = $format->can('postprocess')->($self);
	if (!$self->{'noauto'}) {
		$self->output;
		# Clean up
		if ($self->{rendered}) {
			unlink($self->{rendered}) or
				throw Error::Simple 'Unable to delete output file';
		}
	}
	return $post;
}

sub output {
	my $self = shift;
	my %args = @_;
	my $method = $self->{method} || $args{method} || $args{media};

	if ('email' eq lc $method) {
		$self->_email_output;
	} elsif ('print' eq lc $method) {
		$self->_lpr_output;
	} elsif (defined $self->{output}) {
		$self->_http_output;
		exit;
	} else {
		$self->_http_output_file;
	}
}

sub _http_output {
	my $self = shift;
	my $data = shift;
	$data ||= $self->{output};
	if ($self->{format} !~ /^\p{IsAlnum}+$/) {
		throw Error::Simple "Invalid format";
	}
	my $format = "LedgerSMB::Template::$self->{format}";
	my $disposition = "";
	my $name = $format->can('postprocess')->($self);

	if ($name) {
		$name =~ s#^.*/##;
		$disposition .= qq|\nContent-Disposition: attachment; filename="$name"|;
	}
	if ($self->{mimetype} =~ /^text/) {
		print "Content-Type: $self->{mimetype}; charset=utf-8$disposition\n\n";
	} else {
		print "Content-Type: $self->{mimetype}$disposition\n\n";
		binmode STDOUT, ':bytes';
	}
	print $data;
	binmode STDOUT, ':utf8';
}

sub _http_output_file {
	my $self = shift;
	my $FH;

	open($FH, '<:bytes', $self->{rendered}) or
		throw Error::Simple 'Unable to open rendered file';
	my $data;
	{
		local $/;
		$data = <$FH>;
	}
	close($FH);
	
	$self->_http_output($data);
	
	unlink($self->{rendered}) or
		throw Error::Simple 'Unable to delete output file';
	exit;
}

sub _email_output {
	my $self = shift;
	my $args = $self->{output_args};

	my @mailmime;
	if (!$self->{rendered} and !$args->{attach}) {
		$args->{message} .= $self->{output};
		@mailmime = ('contenttype', $self->{mimeytype});
	}

	my $mail = new LedgerSMB::Mailer(
		from => $args->{from} || $self->{user}->{email},
		to => $args->{to},
		cc => $args->{cc},
		bcc => $args->{bcc},
		subject => $args->{subject},
		notify => $args->{notify},
		message => $args->{message},
		@mailmime,
	);
	if ($args->{attach} or $self->{mimetype} !~ m#^text/# or $self->{rendered}) {
		my @attachment;
		my $name = $args->{filename};
		if ($self->{rendered}) {
			@attachment = ('file', $self->{rendered});
			$name ||= $self->{rendered};
		} else {
			@attachment = ('data', $self->{output});
		}
		$mail->attach(
			mimetype => $self->{mimetype},
			filename => $name,
			strip => $$,
			@attachment,
			);
	}
	$mail->send;
}

sub _lpr_output {
	my $self = shift;
	#TODO stub
}

1;
