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

	# Split the arguments.
	my @args = $line =~ /(?:[^\s"]+|"[^"]*")+/g;
	shift @args;

	# Clean the arguments.
	foreach my $item (@args) {
		$item =~ s/(^")|("$)//g;
	}

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

	# Check if the state is "important".
	if ($task->{"important"}) {
		$msg = colored($msg, "black on_white");
	}

	# Print the task.
	print "    $state $msg\n";
}

# Parses the tasks file.
sub parse_tasks {
	my ($filename) = @_;

	my @tasks;
	open(TODO, "<", $filename) or die "Couldn't open $filename: $!";

	# Read each line.
	while (my $line = <TODO>) {
		chomp $line;

		my @part = $line =~ /^(\s[-x!]\s)|(.+)$/gi;
		my $done = 0;
		my $important = 0;
		my $msg = $part[3];

		# Check if the task is done or important.
		if ($part[0] =~ /x/) {
			$done = 1;
		} elsif ($part[0] =~ /!/) {
			$important = 1;
		}

		# Create the task hash.
		my $task = {
			"done"      => $done,
			"important" => $important,
			"msg"       => $msg
		};

		# Add the task.
		push(@tasks, $task);
	}

	close(TODO);
	return @tasks;
}

# Save a TODO list.
sub save_todo {
	my ($filename, @tasks) = @_;

	open(my $todo, ">", $filename) or warn "Cannot open $filename: $!";
	foreach my $task (@tasks) {
		my $state = "-";

		if ($task->{"done"}) {
			$state = "x";
		} elsif ($task->{"important"}) {
			$state = "!";
		}

		print $todo "\t$state " . $task->{"msg"} . "\n";
	}
	close($todo);
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

# Add a new task.
sub add_task {
	my ($msg, $tasks) = @_;

	# Create the task hash.
	my $task = {
		"done"      => 0,
		"important" => 0,
		"msg"       => $msg
	};

	# Add the task.
	unshift($tasks, $task);
}

# Mains.
sub main {
	# Setup the readline stuff.
	my $term = Term::ReadLine->new("tdo");
	my $prompt = ":";
	my $OUT = $term->OUT || \*STDOUT;

	my $filename = "TODO";
	my @tasks = parse_tasks($filename);
	list_tasks(@tasks);

	# TODO: Put the readline loop in its own sub.
	while (defined($_ = $term->readline($prompt))) {
		my $command = $_;

		if ($command =~ /^(q|quit|exit)$/i) {
			exit;
		} elsif ($command =~ /^(l|list)/i) {
			# List tasks.
			my @args = split_arguments($command);
			list_tasks(@tasks);
		} elsif ($command =~ /^(d|done)/i) {
			# Mark a task as done.
			my @args = split_arguments($command);
			mark_task("done", join(" ", @args), @tasks);
			save_todo($filename, @tasks);
		} elsif ($command =~ /^(r|reload|refresh)/i) {
			# Reload the file.
			@tasks = parse_tasks($filename);
			list_tasks(@tasks);
		} elsif ($command =~ /^(o|open)/i) {
			# Open a file.
			my @args = split_arguments($command);

			# Load the new file.
			$filename = $args[0];
			@tasks = parse_tasks($filename);

			# List the tasks.
			list_tasks(@tasks);
		} elsif ($command =~ /^(a|add)/i) {
			# Add a new task.
			$command =~ s/^(a|add)\s//i;

			add_task($command, \@tasks);
			save_todo($filename, @tasks);
			list_tasks(@tasks);
		}

		# Add command to the history if it isn't empty.
		$term->addhistory($_) if /\S/;
	}
}

main();
