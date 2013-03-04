#!/usr/bin/perl

# this is a module for easily filtering a fasta file, see fastatest.pl for an example

#available elements in an entry
#'header' => '>comp1142741_c0_seq1 len=1940 path=[...]'
#'transcript' => 'TACTGTGG...'  (newlines excluded)
#'sequence' => 'seq3'
#'c' => 'c0'
#'comp' => 'comp1142741'
#'identifier' => 'comp1142741_c0_seq4'
#'length' => 1110
#'path' => '[1:0-468 470:469-720 . . . 11512:1085-1109]'
#'raw' => '<full raw value of the fasta entry>'
package Fasta;

use strict;

sub new {
	my $class = shift;
	my $self = {
		_file => shift,
		_fasta => [],
		_keep => [],
		_index => 0,
	};

	bless $self, $class;

	$self->load();

	return $self;
}

sub load {
	my $self = shift;
	my $file = $self->{_file};
	open FH, $file;

	my @entries = ();
	while(<FH>) {
		if ($_ =~ m/^>(.*?)\s/) {
			my %entry = $self->parseEntry($_);

			push @entries, \%entry;
		} else {
			$entries[-1]{raw} .= $_;
			chomp($_);
			$entries[-1]{transcript} .= $_;
		}
	}


	$self->{_fasta} = \@entries;

	close FH;
}

sub hasNext {
	my $self = shift;
	my $size =  scalar @{$self->{_fasta}};
	return $self->{_index} < ($size);
}

sub next {
	my $self = shift;
	my $index = $self->{_index}++;
	my $arr = $self->{_fasta};
	
	return $arr->[$index];
}

sub keep {
	my $self = shift;
	my $index = $self->{_index}-1;
	$self->{_keep}[$index] = 1;
}

sub skip {
	my $self = shift;
	my $index = $self->{_index}-1;
	$self->{_keep}[$index] = 0;
}

sub print {
	my $self = shift;
	my $fasta = $self->{_fasta};
	my $keep = $self->{_keep};
	for my $i ( 0 .. scalar @{ $fasta } ) {
		if ($keep->[$i]) {
			print $fasta->[$i]->{raw};
		}
	}
}

sub parseEntry {
	my $self = shift;
	my $entry = shift;

	#match first token on header line up to whitespace as identifier
	$entry =~ /^>(.*?)\s.*$/;
	my $identifier = $1;

	#if header matches comp system, dissect for specific values
	$entry =~ />((comp\d+)_(c\d+)_(seq\d+))/;
	$identifier = $1;
	my $comp = $2;
	my $c = $3;
	my $sequence = $4;
		

	$entry =~ /len=([^ ]+)\s/;
	my $len = $1;

	$entry =~ /path=(.*)$/;
	my $path = $1;

	my %hash = (
		header => $entry,
		identifier => $identifier,
		comp => $comp,
		c => $c,
		sequence => $sequence,
		length => $len,
		path => $path,
		raw => $entry,
	);

	return %hash;
}

1;
