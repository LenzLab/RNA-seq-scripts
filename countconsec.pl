#countconsec.pl - 2013-3-13 mc


#Usage: perl countconsec.pl filename.fasta [max_consec]
#       max_consec default is 5
#       i.e.:  perl countconsec.pl small.fasta
#              perl countconsec.pl small.fasta 7
#This script takes a fasta file and optionally an integer for the 
#max number of consecutive base pairs to look for, using 5 as the default
#if it is not specified. For example, if max_consec is 3, all occurences 
#of "A", "AA", and "AAA" are found, as well as the same patterns for C, G, and T.
#These matches are exclusive, so if a transcript is "AGAA", for example, 
#there would be 1 "A", 1 "AA", and 1 "G".

#Sample output (max_consec = 3):
#comp12345_c0_seq1
#A 3
#AA 2
#AAA 0
#C 10
#CC 5
#CCC 2
#T 20
#TT 2
#TTT 3
#G 9
#GG 4
#GGG 1



#!usr/bin/perl

use Fasta;
use strict;

my $max_consec = 5;

my $fasta = new Fasta($ARGV[0]) or die "need a fasta file\n";
if($#ARGV > 0) { $max_consec = $ARGV[1]; }

while($fasta->hasNext()){
	my $entry = $fasta->next();
	my $ident = $entry->{identifier};
	my $transcript = $entry->{transcript};

	print "$ident\n";
	#my $acount = $transcript =~ tr/A/A/;
	#print "acount: $acount\n";
	$transcript = "B$transcript"."B";
	foreach my $bp ('A', 'C', 'T', 'G'){
		for(my $consec = 1; $consec <= $max_consec; $consec++){
			my $searchFor = ($bp x $consec);
			my $pattern = "(?=([^$bp]".$searchFor."[^$bp]))";
			my $count = 0;
			$count = () = $transcript =~ /$pattern/g;
			print "$searchFor $count\n";
		}
	}
}
