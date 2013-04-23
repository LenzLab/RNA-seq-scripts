#slidingMatch.pl - 22-4-2013  Matt Cieslak

#usage: perl slidingMatch.pl templatefile.txt targetfile.txt
#
#The template and target files should contain a single line each, 
#where that line is a string of characters. The template string should
#be a potential substring of the target. This script will check each 
#possible alignment of one against the other, and count the number
#of matching characters for each alignment. The output is a string of 
#integers representing the number of character matches for each alignement
#check.
#
#
#For an example template of ABC and a target of ZNCIABCUAECA
#First alignment check:
#  ZNCIABCUAECA
#ABC
#
#Last alignment check:
#  ZNCIABCUAECA
#             ABC
#
#Ouput:
#0 0 1 0 0 0 3 0 0 0 2 0 0 1


#!usr/bin/perl

use strict;

my $template_fname = $ARGV[0];
my $target_fname = $ARGV[1];

open (my $template_fh, $template_fname) or die $!;
my $temp_string = <$template_fh>;
chomp $temp_string;
my @template = split("", $temp_string);
close ($template_fh);

open (my $target_fh, $target_fname) or die $!;
my $tar_string = <$target_fh>;
chomp $tar_string;
my @target = split("", $tar_string);
close ($target_fh);

my @output;

#for the loops below, $n is used to track an index within the template, 
# and $i is used to track an index within the target.

#first find partial matches of template at the beginning
#of the target string
for(my $n = $#template; $n > 0; $n--){
	my $num_matches = 0;
	for(my $i = 0; $i <= ($#template-$n); $i++){
		if($target[$i] eq $template[$n+$i]){
			$num_matches++;
		}
	}
	push(@output, $num_matches);
}

#now try matching the entire template against each position 
#in the target string
for(my $i = 0; $i <= $#target; $i++){
	my $num_matches = 0;
	for(my $n = 0; $n <= $#template; $n++){
		if($template[$n] eq $target[$i+$n]){
			$num_matches++;
		}
	}
	push(@output, $num_matches);
}

print join(" ", @output);
