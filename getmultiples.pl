#!/usr/bin/perl

#usage: perl getmultiples.pl <comp list> <frequency list>
#Given a file with a comp as the first thing on each line, 
#and a list of comp frequencies such as that output by 
#comphist.pl, outputs a file similar to the frequency list,
#containing only comps that were in the comp list and 
#have 2 or more occurences.

use strict;

my $comps = $ARGV[0];
my $comp_freqs = $ARGV[1];

open(my $fh_comps, $comps) or die $!;
my @comps;
while(<$fh_comps>){
	m/(^comp[\d]+)/;	
	push(@comps, $1);
}
close($fh_comps);

open(my $fh_freqs, $comp_freqs) or die $!;

my %frequencies;
while(<$fh_freqs>) {
	m/^(comp[\d]+) ([\d]+)/;
	$frequencies{$1} = $2;
}
close($fh_freqs);

my %output;
foreach my $comp (@comps) {
	if($frequencies{$comp} > 1) {
		$output{$comp} = $frequencies{$comp};
	}
}

foreach my $k (sort {$output{$b} <=> $output{$a}} keys %output) {
	print "$k $output{$k}\n";
}
