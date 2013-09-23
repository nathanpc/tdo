#!/usr/bin/perl -w

# tdo.pl
#
# The easiest way to manage your TODOs.

use strict;
use warnings;
use Data::Dumper;

use Getopt::Long;
use Term::ANSIColor;


# Usage message.
sub usage {
	print "Usage: tdo\n\n";

	print "Arguments:\n";
	print "    -h\t\tThis message\n";
}
