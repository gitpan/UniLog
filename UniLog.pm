package UniLog;

use strict;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

require Exporter;

@ISA = qw(Exporter);
# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.
@EXPORT = qw();

@EXPORT_OK = qw(LOG_EMERG LOG_ALERT LOG_CRIT LOG_ERR
		LOG_WARNING LOG_NOTICE LOG_INFO LOG_DEBUG
		LOG_CONS LOG_NDELAY LOG_PERROR LOG_PID
		LOG_AUTH LOG_CRON LOG_DAEMON
		LOG_KERN LOG_LPR LOG_MAIL LOG_NEWS
		LOG_SECURITY LOG_SYSLOG LOG_USER LOG_UUCP
		LOG_LOCAL0 LOG_LOCAL1 LOG_LOCAL2 LOG_LOCAL3
		LOG_LOCAL4 LOG_LOCAL5 LOG_LOCAL6 LOG_LOCAL7);

%EXPORT_TAGS = ('levels'     => [qw(LOG_EMERG LOG_ALERT LOG_CRIT LOG_ERR
			            LOG_WARNING LOG_NOTICE LOG_INFO LOG_DEBUG  )],
		'options'    => [qw(LOG_CONS LOG_NDELAY LOG_PERROR LOG_PID     )],
		'facilities' => [qw(LOG_AUTH LOG_CRON LOG_DAEMON
				    LOG_KERN LOG_LPR LOG_MAIL LOG_NEWS
				    LOG_SECURITY LOG_SYSLOG LOG_USER LOG_UUCP
				    LOG_LOCAL0 LOG_LOCAL1 LOG_LOCAL2 LOG_LOCAL3
				    LOG_LOCAL4 LOG_LOCAL5 LOG_LOCAL6 LOG_LOCAL7)]);

$VERSION = '0.04';

use Carp;

my @LogLevels     = ();
my %LogOptions    = ();
my %LogFacilities = ();

# Define log levels
sub LOG_EMERG()   { return 0; };
sub LOG_ALERT()   { return 1; };
sub LOG_CRIT()    { return 2; };
sub LOG_ERR()     { return 3; };
sub LOG_WARNING() { return 4; };
sub LOG_NOTICE()  { return 5; };
sub LOG_INFO()    { return 6; };
sub LOG_DEBUG()   { return 7; };

# Define log options
sub LOG_CONS()   { return $LogOptions{'LOG_CONS'}; };
sub LOG_NDELAY() { return $LogOptions{'LOG_NDELAY'}; };
sub LOG_PID()    { return $LogOptions{'LOG_PID'}; };

# Define log facilities
sub LOG_AUTH()     { return $LogFacilities{'LOG_AUTH'}; };
sub LOG_AUTHPRIV() { return $LogFacilities{'LOG_AUTHPRIV'}; };
sub LOG_CRON()     { return $LogFacilities{'LOG_CRON'}; };
sub LOG_DAEMON()   { return $LogFacilities{'LOG_DAEMON'}; };
sub LOG_FTP()      { return $LogFacilities{'LOG_FTP'}; };
sub LOG_KERN()     { return $LogFacilities{'LOG_KERN'}; };
sub LOG_LPR()      { return $LogFacilities{'LOG_LPR'}; };
sub LOG_MAIL()     { return $LogFacilities{'LOG_MAIL'}; };
sub LOG_NEWS()     { return $LogFacilities{'LOG_NEWS'}; };
sub LOG_SYSLOG()   { return $LogFacilities{'LOG_SYSLOG'}; };
sub LOG_USER()     { return $LogFacilities{'LOG_USER'}; };
sub LOG_UUCP()     { return $LogFacilities{'LOG_UUCP'}; };
sub LOG_LOCAL0()   { return $LogFacilities{'LOG_LOCAL0'}; };
sub LOG_LOCAL1()   { return $LogFacilities{'LOG_LOCAL1'}; };
sub LOG_LOCAL2()   { return $LogFacilities{'LOG_LOCAL2'}; };
sub LOG_LOCAL3()   { return $LogFacilities{'LOG_LOCAL3'}; };
sub LOG_LOCAL4()   { return $LogFacilities{'LOG_LOCAL4'}; };
sub LOG_LOCAL5()   { return $LogFacilities{'LOG_LOCAL5'}; };
sub LOG_LOCAL6()   { return $LogFacilities{'LOG_LOCAL6'}; };
sub LOG_LOCAL7()   { return $LogFacilities{'LOG_LOCAL7'}; };

my $OpenLog  = undef;
my $CloseLog = undef;
my $PutMsg   = undef;

if ( "\L$^O" =~ m/win32/ )
	{
	eval   'use Win32::EventLog;
	        $OpenLog  = sub { return Win32::EventLog->new($_[0], $ENV{ComputerName}); };
                $CloseLog = sub { $_[0]->{Handler}->Close(); };
                $PutMsg   = sub { $_[0]->{Handler}->Report({EventType => $_[1],
                					    Strings   => $_[2],
                					    Category  => $_[0]->{Facility},
                					    EventID   => 0,
                					    Data      => "",
                					   }
                					  );
				};
		$LogLevels[LOG_EMERG]   = EVENTLOG_ERROR_TYPE;
		$LogLevels[LOG_ALERT]   = EVENTLOG_ERROR_TYPE;
		$LogLevels[LOG_CRIT]    = EVENTLOG_ERROR_TYPE;
		$LogLevels[LOG_ERR]     = EVENTLOG_ERROR_TYPE;
		$LogLevels[LOG_WARNING] = EVENTLOG_WARNING_TYPE;
		$LogLevels[LOG_NOTICE]  = EVENTLOG_INFORMATION_TYPE;
		$LogLevels[LOG_INFO]    = EVENTLOG_INFORMATION_TYPE;
		$LogLevels[LOG_DEBUG]   = EVENTLOG_INFORMATION_TYPE;
		#
		# Set log options
		$LogOptions{"LOG_CONS"}   = 0;
		$LogOptions{"LOG_NDELAY"} = 0;
		$LogOptions{"LOG_PID"}    = 0;
		#
		# Set log facilities
		$LogFacilities{"LOG_AUTH"}     =  1;
		$LogFacilities{"LOG_CRON"}     =  2;
		$LogFacilities{"LOG_DAEMON"}   =  3;
		$LogFacilities{"LOG_KERN"}     =  4;
		$LogFacilities{"LOG_LPR"}      =  5;
		$LogFacilities{"LOG_MAIL"}     =  6;
		$LogFacilities{"LOG_NEWS"}     =  7;
		$LogFacilities{"LOG_SYSLOG"}   =  8;
		$LogFacilities{"LOG_USER"}     =  9;
		$LogFacilities{"LOG_UUCP"}     = 10;
		$LogFacilities{"LOG_LOCAL0"}   = 11;
		$LogFacilities{"LOG_LOCAL1"}   = 12;
		$LogFacilities{"LOG_LOCAL2"}   = 13;
		$LogFacilities{"LOG_LOCAL3"}   = 14;
		$LogFacilities{"LOG_LOCAL4"}   = 15;
		$LogFacilities{"LOG_LOCAL5"}   = 16;
		$LogFacilities{"LOG_LOCAL6"}   = 17;
		$LogFacilities{"LOG_LOCAL7"}   = 18;
                ';
	}
else
	{
	eval   'use Unix::Syslog;
	        $OpenLog  = sub {
	        		my $Ident = $_[0];
				Unix::Syslog::openlog($Ident, $_[1], $_[2]);
                		return 1;
                		};
                $CloseLog = sub { Unix::Syslog::closelog; };
                $PutMsg   = sub { Unix::Syslog::syslog($_[1], "%s", $_[2]); };
		# Set real log levels
		$LogLevels[LOG_EMERG]   = Unix::Syslog::LOG_EMERG;
		$LogLevels[LOG_ALERT]   = Unix::Syslog::LOG_ALERT;
		$LogLevels[LOG_CRIT]    = Unix::Syslog::LOG_CRIT;
		$LogLevels[LOG_ERR]     = Unix::Syslog::LOG_ERR;
		$LogLevels[LOG_WARNING] = Unix::Syslog::LOG_WARNING;
		$LogLevels[LOG_NOTICE]  = Unix::Syslog::LOG_NOTICE;
		$LogLevels[LOG_INFO]    = Unix::Syslog::LOG_INFO;
		$LogLevels[LOG_DEBUG]   = Unix::Syslog::LOG_DEBUG;
		#
		# Set log options
		$LogOptions{"LOG_CONS"}   = Unix::Syslog::LOG_CONS;
		$LogOptions{"LOG_NDELAY"} = Unix::Syslog::LOG_NDELAY;
		$LogOptions{"LOG_PID"}    = Unix::Syslog::LOG_PID;
		#
		# Set log facilities
		$LogFacilities{"LOG_AUTH"}     = Unix::Syslog::LOG_AUTH;
		$LogFacilities{"LOG_CRON"}     = Unix::Syslog::LOG_CRON;
		$LogFacilities{"LOG_DAEMON"}   = Unix::Syslog::LOG_DAEMON;
		$LogFacilities{"LOG_KERN"}     = Unix::Syslog::LOG_KERN;
		$LogFacilities{"LOG_LPR"}      = Unix::Syslog::LOG_LPR;
		$LogFacilities{"LOG_MAIL"}     = Unix::Syslog::LOG_MAIL;
		$LogFacilities{"LOG_NEWS"}     = Unix::Syslog::LOG_NEWS;
		$LogFacilities{"LOG_SYSLOG"}   = Unix::Syslog::LOG_SYSLOG;
		$LogFacilities{"LOG_USER"}     = Unix::Syslog::LOG_USER;
		$LogFacilities{"LOG_UUCP"}     = Unix::Syslog::LOG_UUCP;
		$LogFacilities{"LOG_LOCAL0"}   = Unix::Syslog::LOG_LOCAL0;
		$LogFacilities{"LOG_LOCAL1"}   = Unix::Syslog::LOG_LOCAL1;
		$LogFacilities{"LOG_LOCAL2"}   = Unix::Syslog::LOG_LOCAL2;
		$LogFacilities{"LOG_LOCAL3"}   = Unix::Syslog::LOG_LOCAL2;
		$LogFacilities{"LOG_LOCAL4"}   = Unix::Syslog::LOG_LOCAL4;
		$LogFacilities{"LOG_LOCAL5"}   = Unix::Syslog::LOG_LOCAL5;
		$LogFacilities{"LOG_LOCAL6"}   = Unix::Syslog::LOG_LOCAL6;
		$LogFacilities{"LOG_LOCAL7"}   = Unix::Syslog::LOG_LOCAL7;
                ';
	};
if ($@) { croak $@; };

my %LogParam = (Ident    => $0,
                Level    => 6,
                StdErr   => 0,
                Options  => LOG_PID | LOG_CONS,
                Facility => LOG_USER);

# Preloaded methods go here.

my $CleanStr = sub($)
	{
	if (!defined($_[0])) { return; };
	my %BadChars = ("\x00" => "\\x00", "\x01" => "\\x01", "\x02" => "\\x02", "\x03" => "\\x03",
	                "\x04" => "\\x04", "\x05" => "\\x05", "\x06" => "\\x06", "\a"   => "\\a",
	                "\b"   => "\\b",   "\t"   => "\\t",   "\n"   => "\\n",   "\x0b" => "\\x0b",
	                "\f"   => "\\f",   "\r"   => "\\r",   "\x0e" => "\\x0e", "\x0f" => "\\x0f",
	                "\x10" => "\\x10", "\x11" => "\\x11", "\x12" => "\\x12", "\x13" => "\\x13",
	                "\x14" => "\\x14", "\x15" => "\\x15", "\x16" => "\\x16", "\x17" => "\\x17",
	                "\x18" => "\\x18", "\x19" => "\\x19", "\x1a" => "\\x1a", "\e"   => "\\e",    
	                "\x1c" => "\\x1c", "\x1d" => "\\x1d", "\x1e" => "\\x1e", "\x1f" => "\\x1f",
	                "\xff" => "\\xff",
	               );
	my $Str = $_[0];
	$Str =~ s/\A[\s\n]+//gm;
	$Str =~ s/[\s\n]+\Z//gm;
	$Str =~ s{ ( [\x00-\x1f\xff] ) } { $BadChars{"$1"} }gmex;
	return $Str;
	};

sub new($%)
	{
	my ($class, %LogParam) = @_;

	my $Logger = undef;
	
	$LogParam{Ident} = &{$CleanStr}($LogParam{Ident});

	my $Handler = &$OpenLog($LogParam{Ident}, $LogParam{Options}, $LogParam{Facility})
		or croak "Can nor create log handler!\n";

	return bless {Ident    => $LogParam{Ident},
		      Level    => $LogParam{Level},
		      Facility => $LogParam{Facility},
		      StdErr   => $LogParam{StdErr},
                      Handler  => $Handler} => $class;
	};

sub Message($$$@)
	{
	my ($Self, $Level, $Format, @Args) = @_;

	if (!$_[0]->{Handler})
		{
		carp "Logger is closed!\n";
		return;
		};

	if    ($Level < 0)
		{
                if ($^W) { carp "Log level \"$Level\" adjusted from \"$Level\" to \"0\"\n"; };
		$Level = 0;
		}
	elsif ($Level > 7)
		{
                if ($^W) { carp "Log level \"$Level\" adjusted from \"$Level\" to \"7\"\n"; };
		$Level = 7;
		};

	if ($Level <= $Self->{Level})
		{
		my $Str = &{$CleanStr}(sprintf($Format, @Args));

		if ($Self->{StdErr})
			{ print STDERR localtime()." $Level\t$Str\n"; };

	        &$PutMsg($Self, $LogLevels[$Level], $Str);
		};
	};

sub Level($$)
	{
	if (!$_[0]->{Handler})
		{
		carp "Logger is closed!\n";
		return;
		};
	my $Return = $_[0]->{Level};
	if (defined($_[1]))
		{ $_[0]->{Level} = $_[1]; };
	return $Return;
	};

sub StdErr($$)
	{
	if (!$_[0]->{Handler})
		{
		carp "Logger is closed!\n";
		return;
		};
	my $Return = $_[0]->{StdErr};
	if (defined($_[1]))
		{ $_[0]->{StdErr} = $_[1]; };
	return $Return;
	};

sub Close($)
	{
	if (!$_[0]->{Handler})
		{
		carp "Logger is closed!\n";
		return;
		};
	&{$CloseLog}($_[0]);
	$_[0]->{Handler} = 0;
	};

1;
__END__
# Below is stub documentation for your module. You better edit it!

=head1 NAME

UniLog - Perl module for unified logging on Unix and Win32

=head1 SYNOPSIS

  use UniLog qw(:levels);
  use UniLog qw(:options :facilities); # Not useful on Win32

  $Logger=UniLog->new(Ident    => "MyProgram",
                                  # The log source identification
                      Options  => LOG_PID|LOG_CONS|LOG_NDELAY,
                                  # Logger options, see "man 3 syslog"
                      Facility => LOG_USER,
                                  # Logger facility, see "man 3 syslog"
                      Level    => LOG_INFO,
                                  # The log level                       
                      StdErr   => 1);
                                  # Log messages also to STDERR

  $Logger->Message(LOG_NOTICE, "Message text here, time: %d", time());
           # Send message to the log

  $Logger->Message(LOG_DEBUG, "You should not see this");
           # Will not be logged
  $Logger->Level(LOG_DEBUG);
  $Logger->Message(LOG_DEBUG, "You should see this now");
           # Will be logged

  $Logger->StdErr(0);
           # Stop logging to STDERR
  $Logger->Message(LOG_INFO, "Should not be logged to STDERR");
           # Send message to the log

  $Logger->Close();


=head1 DESCRIPTION

This module provides an unified way to send log messages on Unix and Win32.
Messages are logged using syslog on Unix and using EventLog on Win32.

This module uses L<Unix::Syslog> Perl module on Unix and L<Win32::EventLog> Perl module on Win32.

The idea was to give a programmer a posibility to write a program which will be able to run
on Unix and on Win32 without code adjusting and with the same logging functionality.

I<Notes:>

I<C<Win32::EventLog> does not support any Win32 platform except WinNT.
So, C<UniLog> does not support them too.>

I<Logging to remote server is not supported in this release.>

Module was tested on FreeBSD 4.2, Win2000 and Solaris 7.

=head1 The UniLog methods

=over 4

=item C<new(%PARAMHASH);>

The C<new> method creates the logger object and returns a handle to it.
This handle is then used to call the methods below.

The I<%PARAMHASH> could contain the following keys:

=over 4

=item C<Ident>

Ident field specifies a string which will be used as message source identifier.
C<syslogd>(8) will print it into every message 
and C<EventLog> will put it to the "Source" message field.

Default is $0, the name of the program being executed. 

=item C<Options>

This is an integer value which is the result of ORed options:
C<LOG_CONS>, C<LOG_NDELAY>, C<LOG_PID>.

See L<Unix::Syslog>, C<syslog>(3) for details.

Default is C<LOG_PID|LOG_CONS>.

This field is ignored on Win32.

=item C<Facility>

This is an integer value which specifies the part of the system the message
should be associated with (e.g. kernel message, mail subsystem).

Could be C<LOG_AUTH>, C<LOG_CRON>, C<LOG_DAEMON>,
C<LOG_KERN>, C<LOG_LPR>, C<LOG_MAIL>, C<LOG_NEWS>, C<LOG_SYSLOG>, 
C<LOG_USER>, C<LOG_UUCP>, C<LOG_LOCAL0>, C<LOG_LOCAL1>, C<LOG_LOCAL2>,
C<LOG_LOCAL3>, C<LOG_LOCAL4>, C<LOG_LOCAL5>, C<LOG_LOCAL6>, C<LOG_LOCAL7>.

See L<Unix::Syslog>, C<syslog>(3) for details.

Default is C<LOG_USER>.

This field is ignored on Win32.

=item C<Level>

This is an integer value which specifies log level.
All messages with Level greater than C<Level> will not be logged.
You will be able to change Level using C<Level> method.
See C<Message> method description for available log levels.

Default log level is C<LOG_INFO>.

=item C<StdErr>

If this flag have a 'true' value all messages are logged to C<STDERR> 
in addition to syslog/EventLog.
You will be able to change this flag using L<StdErr> method.

Default is 0 - do not log to C<STDERR>.

=back

=item C<Message($Level, $Format, @SprintfParams);>

The C<Message> method send a log string to the syslog or EventLog 
and, if allowed, to C<STDERR>.
Log string will be formed by sprintf function from I<$Format> format string and
parameters passed in I<@SprintfParams>. Of course, I<@SprintfParams> could be empty
if no parameters required by format string.

The I<$Level> should be an integer and could be:

=over 4

=item Z<>

=over 4

=item C<LOG_EMERG  >

Value B<C<0>>. Will be logged as C<LOG_EMERG>  in syslog, 
as C<EVENTLOG_ERROR_TYPE> in EventLog.

=item C<LOG_ALERT  >

Value B<C<1>>. Will be logged as C<LOG_ALERT>  in syslog, 
as C<EVENTLOG_ERROR_TYPE> in EventLog.

=item C<LOG_CRIT   >

Value B<C<2>>. Will be logged as C<LOG_CRIT>   in syslog, 
as C<EVENTLOG_ERROR_TYPE> in EventLog.

=item C<LOG_ERR    >

Value B<C<3>>. Will be logged as C<LOG_ERR>     in syslog,
as C<EVENTLOG_ERROR_TYPE> in EventLog.

=item C<LOG_WARNING>

Value B<C<4>>. Will be logged as C<LOG_WARNING> in syslog,
as C<EVENTLOG_WARNING_TYPE> in EventLog.

=item C<LOG_NOTICE >

Value B<C<5>>. Will be logged as C<LOG_NOTICE>  in syslog,
as C<EVENTLOG_INFORMATION_TYPE> in EventLog.

=item C<LOG_INFO   >

Value B<C<6>>. Will be logged as C<LOG_INFO>    in syslog,
as C<EVENTLOG_INFORMATION_TYPE> in EventLog.

=item C<LOG_DEBUG  >

Value B<C<7>>. Will be logged as C<LOG_DEBUG>   in syslog,
as C<EVENTLOG_INFORMATION_TYPE> in EventLog.

=back

Default is C<LOG_INFO>.

See L<Unix::Syslog>(3) for "C<LOG_*>" description,
see L<Win32::EventLog>(3) for "C<EVENTLOG_*_TYPE>" descriptions.

=back

=item C<Level([$LogLevel]);>

If I<$LogLevel> is not specified C<Level> returns a current log level.
If I<$LogLevel> is specified C<Level> sets the log level to the new value 
and returns a previous value.

=item C<StdErr([$Flag]);>

If I<$Flag> is not specified C<StdErr> returns a current state of logging-to-STDERR flag.
If I<$Flag> is specified C<StdErr> sets the logging-to-STDERR flag to the new state 
and returns a previous state.

=item C<Close();>

Close the logger.

=back

=head2 EXPORT

None by default.

=head1 AUTHOR

Daniel Podolsky, E<lt>tpaba@cpan.orgE<gt>

=head1 SEE ALSO

L<Unix::Syslog>, L<Win32::EventLog>, C<syslog>(3).

=cut
