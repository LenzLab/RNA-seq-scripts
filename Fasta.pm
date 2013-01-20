#!/usr/bin/perl

# this is a module for easily filtering a fasta file, see fastatest.pl for an example
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
		if ($_ =~ m/^>(comp.*?) /) {
			my %entry = $self->parseEntry($_);

			push @entries, \%entry;
		} else {
			$entries[-1]{raw} .= $_;
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

	$entry =~ />((comp\d+)_(c\d+)_(seq\d+))/;
	my $identifier = $1;
	my $comp = $2;
	my $c = $3;
	my $sequence = $4;

	$entry =~ /len=([^ ]+) /;
	my $len = $1;

	$entry =~ /path=(.*)$/;
	my $path = $1;

	my %hash = (
		identifier => $identifier,
		comp => $comp,
		c => $c,
		sequence => $sequence,
		length => $len,
		path => $path,
		raw => $entry
	);

	return %hash;
}

1;
