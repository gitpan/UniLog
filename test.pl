# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test;
BEGIN { plan tests => 2 };

$^W++;

use UniLog qw(:levels :options :facilities);
ok(1); # If we made it this far, we're ok.

#########################

# Insert your test code below, the Test module is use()ed here so read
# its man page ( perldoc Test ) for help writing this test script.

my $Logger=UniLog->new(Ident    => 'UniLog test script',
                                   # The log source identification
                       Options  => LOG_PID|LOG_CONS|LOG_NDELAY,
                                   # Logger options, see "man 3 syslog"
                       Facility => LOG_USER,
                                   # Logger facility, see "man 3 syslog"
                       Level    => LOG_DEBUG,
                                   # The log level                       
                       StdErr   => 1,
                                   # Log messages also to STDERR
                      );

$Logger->Message(LOG_INFO, "The test message. You have to see it on your console (STDERR) and in your system log (syslog or EventLog)");

$Logger->Close;

print "If you do not see \"The test messsage...\" UniLog is not working on your computer. Please inform tpaba\@cpan.org\n";

ok(2);