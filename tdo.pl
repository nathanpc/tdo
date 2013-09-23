#!/usr/bin/perl -w

# tdo.pl
#
# The easiest way to manage your TODOs.

# TODO:
#   - Have a global TODO list.
#   - Check for local TODO lists.
#   - Maybe: Read source code files for TODO comments.

use strict;
use warnings;
use Data::Dumper;

use Getopt::Long;
use Term::ANSIColor;
use Term::ReadLine;


# Usage message.
sub usage {
	print "Usage: tdo\n\n";

	print "Arguments:\n";
	print "    -h\t\tThis message\n";
}

sub main {
#	my $term = Term::ReadLine->new("tdo");
	my $prompt = ": ";
#	my $OUT = $term->OUT || \*STDOUT;

	open(TODO, "<", "TODO") or die "Couldn't open TODO: $!";
	while (my $line = <TODO>) {
		chomp $line;

		my @part = $line =~ /^(\s[-x]\s)|(.+)$/gi;
		my $state = " ";
		my $msg = $part[3];

		# Check if the task is done.
		if ($part[0] =~ /x/) {
			$state = "x";
		}

		# Print the task.
		print "    [$state] $msg\n";
	}
	close(TODO);
}

main();
