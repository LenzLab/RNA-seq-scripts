#!/usr/bin/perl

# provided a list of choices and a fasta file this prints out a new fast file that
# includes only the comps specified in the list

$choices = $ARGV[0];
$fasta = $ARGV[1];

# load the choices text file into an array, perl does this easily for us
open(my $fh_choices,$choices) or die $!;
my @choices = <$fh_choices>;
close($fh_choices);

my %data = ();

open(my $fh_fasta,$fasta) or die $!;
$current = "";
# as with previous programs, we're loading each entry by its key to make
# manipulating it easier.
while(<$fh_fasta>) {
	if ($_ =~ m/^>(comp.*?) /) {
		$current = $1;
		$data{$current} = $_;
	} else {
		$data{$current} .= $_;
	}
}
close($fh_fasta);

# now, we simply iterate through the choices and print out the corresponding entry
foreach (@choices) {
	$_ =~ s/\n//;
	print $data{$_};
}

