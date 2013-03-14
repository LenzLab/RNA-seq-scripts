
#segregate.pl - 2013-3-13 mc
#given the filenames of one or more sequence alignment files, this 
#script will output a similar file, with sequences marked by the 
#same identifier adjacent to each other, and sorted by the identifiers.
#Note: the first white space on each line defines the separation between identifier
#      and data fields. 
#      Lines must be terminated by an end-of-line character.

#lines in the input file(s) may look something like:
#cp222993_c0_s1 --------------------------------------DDSRVGSPNGSLD------GGV
#cp44060_c3_s1 RREKYKKQEDEREVVRQSIREKYGLEKPPNDFSDDDDEDDDCDKGDDGRGGSEMQSRSGL
#
#cp222993_c0_s1 -----------------------------------------IQLGQG-------------
#cp44060_c3_s1 PSPGRESTTFTNKYPSRTLPANSYEQVDKSEDPETTTDRMSI---RSATLSLYKSEESLD

#lines in the corresponding output file will be:
#cp222993_c0_s1 --------------------------------------DDSRVGSPNGSLD------GGV
#cp222993_c0_s1 -----------------------------------------IQLGQG-------------
#
#cp44060_c3_s1 RREKYKKQEDEREVVRQSIREKYGLEKPPNDFSDDDDEDDDCDKGDDGRGGSEMQSRSGL
#cp44060_c3_s1 PSPGRESTTFTNKYPSRTLPANSYEQVDKSEDPETTTDRMSI---RSATLSLYKSEESLD


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
