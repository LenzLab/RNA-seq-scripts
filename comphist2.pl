#!/usr/bin/perl

# Given a fasta file, this finds the frequency of the comps and then outputs
# a histogram of the computed frequencies..
# comp1235 appears 3 times
# comp1234 appears 2 times
# comp1233 appears 1 times
# comp1232 appears 1 times

# the final output would be..
# 1 2 ("1 times" appears twice)
# 2 1 ("2 times" appears once)
# 3 1 ("3 times" appears once as well)
# all items above 20 are lumped together

# read each line as..
# 1 73925 "There are 73925 unique comps that show up exactly once
# 2 10539 "There are 10539 unique comps that show up exactly twice

use POSIX

my %comps = ();
# As with comphist.pl we're pulling out the frequencies of the comps
while(<>) {
	if ($_ =~ m/^>(comp\d*)/) {
		$comps{$1}++;
	}
}

# This function is used to perform "binning"
# basically, given a number it returns the name of a bin that it belongs to
# in this case we're simply collecting anything above 20 and putting it into
# a single bin
sub bin {
	$a = $_[0];
	if ($a > 20) {
		return "21+";
	}

	return $a;
}

# We're going to make a histogram out of the histogram
# instead of just using the value, we're going to put it through the bin
# function and count it up
my %histofhist = ();
while(my ($k,$v) = each %comps) {
	$histofhist{bin($v)}++;
}

# As in comphist.pl this is sorting by key
# it doesnt work quite perfectly because in some cases it tries to 
# compare a number to a string eg.. number 10 to string "21+"
foreach $k (sort {$histofhist{$b} <=> $histofhist{$a} } keys %histofhist) {
	print $k." ".$histofhist{$k}."\n";
}
