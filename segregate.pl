
#segregate.pl - 2013-3-13 mc
#given the filenames of one or more sequence alignment files, this 
#script will output a similar file, with sequences marked by the 
#same identifier adjacent to each other, and sorted by the identifiers.

#lines in the input file may look something like:
#cp222993_c0_s1  CAAGATGACAATAAAGAGGAAGTAAGCCAGACCGAGGTGTGGGATCAGGGGGAGCCCGTG

#example usage: 
#perl segregate.pl file1.txt file2.txt >alldata.txt



#!usr/bin/perl 
use strict;

my %ID_hash;
foreach my $input_fname (@ARGV){
	open(my $input_fh, $input_fname);
		while(<$input_fh>){
			if(/^([^\s]+?)\s+.*$/){
				push(@{$ID_hash{$1}}, $_);
			}
		}
	close($input_fh);
}

foreach my $key (sort(keys(%ID_hash))){
	foreach my $line (@{$ID_hash{$key}}){
		print $line;
	}
	print "\n\n";
}
