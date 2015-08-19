#removeadapter.pl - 2015-8-18 jh


#Usage: perl removeadapter.pl filename.fasta adapters.txt
#       i.e.:  perl removeadapter.pl small.fasta adapters.txt
#              perl removeadapter.pl small.fasta adapters.txt > output.fasta
# This script takes a fasta file and an adapter file and removes
# the adapter sequences from each fasta sequence
# it outputs a new fasta file with the adapter sequences removed

#!usr/bin/perl

use Fasta;
use strict;

my $fasta = new Fasta($ARGV[0]) or die "need a fasta file\n";
my $adapter =  $ARGV[1] or die "need an adapter file\n";
my $lineLength = 70;

my @adapterSequences;
open(FH,$adapter) || die "Cannot open $adapter";
while (my $line = <FH>) {
    chomp $line;
	if ($line =~ /^5.* (.*)$/) {
		#print("adding: ".$1."\n");
		push(@adapterSequences,$1);
	}
}

my $out = "";
while($fasta->hasNext()){
	my $entry = $fasta->next();
	my $ident = $entry->{identifier};
	my $header = $entry->{header};
	my $transcript = $entry->{transcript};
	
	#print ("seesq: @adapterSequences\n");
	#print ("start length: ".length($transcript)."\n");
	foreach(@adapterSequences) {
		$adapter = $_;
		#print("removing ".$adapter);
		$transcript =~ s/$adapter//g;
		#print("  ".length($transcript)."\n");
	}

	$out .= "$header";
	while(length($transcript) > $lineLength) {
		$out .= substr($transcript,0,$lineLength)."\n";
		$transcript = substr($transcript,$lineLength);
	}
	$out .= $transcript."\n";
	$out .= "\n";
}

print $out;
