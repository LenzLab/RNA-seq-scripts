#!/usr/bin/perl

use Fasta;
use strict;
#This is a script that takes 2 fasta files as arguments, and outputs
#a new fasta file that only contains entries in the 2nd file that 
#do not already exist in the first file.


#Create an iterator for both fasta files given as arguments
my $oldFasta = new Fasta($ARGV[0]);
my $newFasta = new Fasta($ARGV[1]);

#Create a hash for the old fasta file that has already been processed, 
#and enter the IDs so we can compare them to the new file. 
my %oldIDs;
while($oldFasta->hasNext()) {
	my $entry = $oldFasta->next();
	my $iden = $entry->{identifier};
	$oldIDs{$iden} = $iden;
}

#Check the ID of each entry in the new file to see if 
#it already exists in the old file. IF it does, skip that
#entry, otherwise keep it.
while($newFasta->hasNext()) {
	my $entry = $newFasta->next();
	my $iden = $entry->{identifier};
	if(exists($oldIDs{$iden})){
		$newFasta->skip();
	}
	else{
		$newFasta->keep();
	}
}
#Print the filtered entries as a new fasta file.
$newFasta->print();

