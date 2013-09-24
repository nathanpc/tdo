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

# Splits the readline arguments.
sub split_arguments {
	my ($line) = @_;

	my @args = split(/\s/, $line);
	shift @args;

	return @args;
}

# Prints a task item.
sub print_task {
	my ($task) = @_;

	my $state = "[ ]";
	my $msg = $task->{"msg"};

	# Check if the state is "done".
	if ($task->{"done"}) {
		$state = colored("[", "red") . "x" . colored("]", "red");
	}

	# Print the task.
	print "    $state $msg\n";
}

# Parses the tasks file.
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

# Prints a list of tasks.
sub list_tasks {
	my (@tasks) = @_;

	# Read each line.
	foreach my $task (@tasks) {
		print_task($task);
	}
}

# Marks a task as...
sub mark_task {
	my ($mark_as, $args, @tasks) = @_;

	if ($mark_as eq "done") {
		# Mark as done.
		foreach my $index (split(" ", $args)) {
			my $task = $tasks[$index - 1];

			$task->{"done"} = 1;
			print_task($task);
		}
	}
}

# Mains.
sub main {
	my $term = Term::ReadLine->new("tdo");
	my $prompt = ":";
	my $OUT = $term->OUT || \*STDOUT;

	my @tasks = parse_tasks("TODO");
	list_tasks(@tasks);

	# TODO: Put the readline loop in its own sub.
	while (defined($_ = $term->readline($prompt))) {
		my $command = $_;

		# TODO: Add a command to reload the file.

		if ($command =~ /^(q|quit|exit)$/i) {
			exit;
		} elsif ($command =~ /^(l|list)/i) {
			# Get the arguments.
			my @args = split_arguments($command);
			list_tasks(@tasks);
		} elsif ($command =~ /^(d|done)/i) {
			# Get the arguments.
			my @args = split_arguments($command);
			mark_task("done", join(" ", @args), @tasks);
		}

		# Add command to the history if it isn't empty.
		$term->addhistory($_) if /\S/;
	}
}

main();
