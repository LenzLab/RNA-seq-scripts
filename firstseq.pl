#!/usr/bin/perl

# Usage: ./firstseq.pl all.fasta > firstseq.fasta

# This program takes a fasta file and prints out a new one that contains only
# the first sequence of each comp

my %data = ();
# The goal here is to place each entry in its own block of text
# that means collecting both the starting line ">comp1234...." and all of the
# lines containing the sequence information after it
while(<>) {
	# note this match is different from comphist.pl
	# this one matches the entire identifier, eg "comp1234_c0_seq1"

	# each line that matches this pattern denotes the START of a set of
	# sequence information. thus if we're reading line by line, the
	# $current variable always holds the last identifier we saw
	# we use this to append the line to the right hash entry (this time
	# we use a string append "." operator
	if ($_ =~ m/^>(comp.*?) /) {
		# This is the header of the fasta entry, set the $current
		# variable, and initialize the hash entry to hold the entire
		# string. Note how we're using just the $1 (which is like
		# comp1234_c0_seq1) for $current, but we're using the entire
		# line (stored in $_) for storing into the hash
		$current = $1;
		$data{$current} = $_;
	} else {
		# If we didnt match the pattern, we're looking at a line of
		# sequence, we simply need to add this to the end of the
		# active hash entry
		$data{$current} .= $_;
	}
}

# now that we have all of the entries, we need to iterate through all of them
# and print out the ones that we want to keep (namely the ones that have seq1
# in them)
while(my ($k,$v) = each %data) {
	if ($k =~ m/seq1/) {
		# we're matching the key (comp1234_c0_seq1) for the text "seq1"
		# when we have a matching entry, simply print the entire entry
		# to the output. This should get piped to an output fasta file
		print $v;
	}
}

