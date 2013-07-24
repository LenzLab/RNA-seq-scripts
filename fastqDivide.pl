#fastqDivide.pl  23-7-2013, MC

#This script reads a fastq file and writes two new fastq
#files, each containing half of the entries in the original.
#Entries alternate between going to one or the other output file, 
#resulting in all even entries in one and all odd in another, if 
#they were numbered.

#usage: perl fastqDivide.pl
#File names must be set in the fname variables below


#!usr/bin/perl

use strict;

#Path to and name of original fastq file
my $input_fname = 'input.fastq';

#Paths and names of output files
my $output1_fname = 'output1.fastq';
my $output2_fname = 'output2.fastq';


open(my $input_fh, $input_fname) or die $!;
open(my $output1_fh, '>>'.$output1_fname) or die $!;
open(my $output2_fh, '>>'.$output2_fname) or die $!;


my $entry_line = 0; #cycles 0-1-2-3 to keep track of when a new entry begins
		    #all entries in fastq format are 4 lines long, as long 
		    #as they follow the convention of not wrapping single lines

my $out_toggle = 0; #flips between 0 and 1 to alternate outfiles
my $current_fh;
while(<$input_fh>){
	#if this is the first line of a new entry, change output file and 
	#flip $out_toggle
	if($entry_line == 0){
		#if the 0th line in an entry doesn't start with @, it's not a
		#header, so something is wrong.
		#exception for a blank line which is probably the end of 
		#the file.
		if(!/^@/ && !/^$/){
			die '0th line in this entry does not start with @:\n'.
			     "$_\n";
		} 
		if(!$out_toggle){
			$current_fh = $output1_fh;
		}else {
			$current_fh = $output2_fh;
		}
		$out_toggle = !$out_toggle;
	}

	print $current_fh $_;#write this line to the outfile
	$entry_line = ($entry_line + 1)%4;#cycle current entry line
}

close($output1_fh);
close($output2_fh);
close($input_fh);
