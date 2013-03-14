#Last edit: 13/3/2013 MC
#Auth: JH



#Hash keys for each fasta entry 

#'sequence' => 'seq3'
#'c' => 'c0'
#'comp' => 'comp1142741'
#'identifier' => 'comp1142741_c0_seq4'
#'length' => 1110
#'path' => '[1:0-468 470:469-720 . . . 11512:1085-1109]'
#'raw' => '<full raw value of the fasta entry>'

#!/usr/bin/perl

use Fasta;

$fasta = new Fasta($ARGV[0]);
while($fasta->hasNext()) {
	my $entry = $fasta->next();
	my $sequence = $entry->{sequence};
	
	if ($sequence eq "seq1") {
		$fasta->keep();
	} else {
		$fasta->skip();
	}
}

$fasta->print();
