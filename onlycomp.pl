#!/usr/bin/perl

my %comps = ();
# simply prints a list of all the "comp1234" values, no other information
while(<>) {
	if ($_ =~ m/^>comp(\d+)/) {
		print $1."\n";
	}
}
