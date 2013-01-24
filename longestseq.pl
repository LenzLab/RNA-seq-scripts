#!/usr/bin/perl

# Usage: ./firstseq.pl all.fasta > firstseq.fasta

# This program takes a fasta file and prints out a new one that contains only
# the first sequence of each comp

my %data = ();
# This first section is similar to firstseq.pl
while(<>) {
	if ($_ =~ m/^>(comp.*?) /) {
		$current = $1;
		$data{$current} = $_;
	} else {
		$data{$current} .= $_;
	}
}

%longest = ();
# instead of getting all of the seq1 entries, we're going to pick the LONGEST
# entry from each comp, regardless of which sequence or c0, c1, c2 it's from
# this loop iterates through all of the collected comp entries and extracts the length
# from the metadata on the first line. When it has the length, it checks to see if the
# new length is longer than any previous lenghts found for this kind of comp
while(my ($k,$v) = each %data) {
	# Extract the comp number from the key
	$k =~ m/(comp\d+)/;
	$comp = $1;

	# extract the length from the body of the entry
	if ($v =~ m/len=(\d+)/) {
		$len = $1;
		# check the hash of comp1234: <longest_length> to see if the comp we're
		# looking at is longer than the previous longest fragment
		if ($len > @{$longest{$comp}}[1]) {
			# we store both the unique identifier of the entry and the length
			# this construct (between the parens) is called a tuple
			# it lets you bundle multiple values together easily
			$longest{$comp} = [$k,$len];
		}
	}
}

# print all of the longest entries, we dont need the key, just the value
foreach my $key ( keys %longest) {
	$identifier = @{$longest{$key}}[0];
	print $data{$identifier};
}

