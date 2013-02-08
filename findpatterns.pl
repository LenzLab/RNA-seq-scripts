#!usr/bin/perl


#findpatterns.pl
#Usage: perl findpatterns.pl filename.fasta patternlist.txt
#
#This script takes a fasta file and a text file with a list of
#patterns, one on each line, such as TAAAT. Its output is categorized
#into sequence identifiers, and for each sequence, the amount of each
#pattern as well as the position of each occurence of that pattern
#is shown. This position is the number of the nucleotide of the first
# character of the matched pattern. 

use Fasta;
use strict;


my $fasta = new Fasta($ARGV[0]) or die "need a fasta file";
my $pattern_list = $ARGV[1] or die "need a list of patterns";

open(my $fh_pattern_list, $pattern_list) or die $!;
my @patterns;
while(<$fh_pattern_list>) {
	chomp $_;
	push(@patterns, $_);
}
close($fh_pattern_list);


while($fasta->hasNext()) {
	my $entry = $fasta->next();
	my $ident = $entry->{identifier};
	my $transcript = $entry->{transcript};

	print "$ident\n";
	foreach my $pattern  (@patterns) {
		my $count = 0;
		print "$pattern\n";
		print "found at: ";
		while($transcript =~ /(?=$pattern)/g){
			$count++;
			my $position = pos($transcript)+1;
			print "$position ";
		}
		print "\ncount: $count\n";
	}
}
