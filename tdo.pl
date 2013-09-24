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

sub parse_tasks {
	my ($filename) = @_;

	my @tasks;
	open(TODO, "<", $filename) or die "Couldn't open TODO: $!";

	# Read each line.
	while (my $line = <TODO>) {
		chomp $line;

		my @part = $line =~ /^(\s[-x]\s)|(.+)$/gi;
		my $state = 0;
		my $msg = $part[3];

		# Check if the task is done.
		if ($part[0] =~ /x/) {
			$state = 1;
		}

		# Create the task hash.
		my $task = {
			"done" => $state,
			"msg"   => $msg
		};

		# Add the task.
		push(@tasks, $task);
	}

	close(TODO);
	return @tasks;
}

sub list_tasks {
	my (@tasks) = @_;

	# Read each line.
	foreach my $task (@tasks) {
		my $state = " ";
		my $msg = $task->{"msg"};

		# Check if the task is done.
		if ($task->{"done"}) {
			$state = "x";
		}

		# Print the task.
		print "    [$state] $msg\n";
	}
}

sub main {
	my $term = Term::ReadLine->new("tdo");
	my $prompt = ": ";
	my $OUT = $term->OUT || \*STDOUT;

	my @tasks = parse_tasks("TODO");
	list_tasks(@tasks);

	while (defined($_ = $term->readline($prompt))) {
		my $command = $_;

		if ($command =~ /^(q|quit|exit)$/i) {
			exit;
		} elsif ($command =~ /^(d|done)/i) {
			# Get the arguments.
			my @args = split(/\s/, $command);
			shift @args;

			print Dumper(\@args);
		}

		# Add command to the history if it isn't empty.
		$term->addhistory($_) if /\S/;
	}
}

main();
