#!usr/bin/perl


#findpatterns.pl - 2013-02-14 mc
#Usage: perl findpatterns.pl filename.fasta patternlist.txt
#
#This script takes a fasta file and a text file with a list of
#patterns, one on each line, such as TAAAT. Its output is categorized
#into sequence identifiers, and for each sequence, the amount of each
#pattern as well as the position of each occurence of that pattern
#is shown. This position is the number of the nucleotide of the first
# character of the matched pattern. 

#output of results is restricted to counts in the range: $lothreshold <= counts < $hithreshold
#edit the lines below to set the range

use Fasta;
use strict;

my $lothreshold = 1;
my $hithreshold = 200;

my $fasta = new Fasta($ARGV[0]) or die "need a fasta file";
my $pattern_list = $ARGV[1] or die "need a list of patterns";

open(my $fh_pattern_list, $pattern_list) or die $!;
my @patterns;
while(<$fh_pattern_list>) {
	chomp $_;
	push(@patterns, $_);
}
close($fh_pattern_list);


#output is organized in a fairly complex data structure before sorted and printed
#general structure follows:
#
#%output = {
#	$ident1 => {
#		$pattern1 => {
#			'count' => count of this pattern
#			'positions' => array of positions where this pattern occurs
#		}
#
#		$pattern2 => {
#			...
#		}
#	}
#
#	$ident2 => {
#		...
#	}
#}

#this loop loads the data structure with information 
#about the patterns found for each identifier
my %output;
while($fasta->hasNext()) {
	my $entry = $fasta->next();
	my $ident = $entry->{identifier};
	my $transcript = $entry->{transcript};


	foreach my $pattern (@patterns) {
		$output{$ident}{$pattern}{count} = 0;
		$output{$ident}{$pattern}{positions} = [];
		while($transcript =~ /(?=$pattern)/g){
			my $position = pos($transcript)+1;
			$output{$ident}{$pattern}{count}++;
			#@{} notation used in order to treat a hash element as an array
			push(@{$output{$ident}{$pattern}{positions}}, $position);
		}
	}
}


#the hash of outputs is sorted by the value of 'count' of the first pattern in the pattern list.
#this foreach loops through the returned list of idents, printing the ones where the count
#is within the threshold variables set at the top of the script
foreach my $ident (sort {$output{$b}{$patterns[0]}{count} <=> $output{$a}{$patterns[0]}{count}} keys %output){

	if ($output{$ident}{$patterns[0]}{count} >= $lothreshold and $output{$ident}{$patterns[0]}{count}< $hithreshold){
		print "$ident\n";
		foreach my $pattern (@patterns) {
			print "$pattern\n";
			print "count: $output{$ident}{$pattern}{count}\n";
			print "found at: @{$output{$ident}{$pattern}{positions}}\n\n";
		}
	}
}


