#sorttable.pl - 2013-3-13 mc
#this script takes a table file with sequence identifiers on the leftmost
#column and 6 other columns (separated by tabs [\t]) for each sample.
#it outputs a file of the same type sorted by the value of data column 
#$column. (leftmost column of identifiers is column 0)

#usage: set the $column variable below to the column you want to sort by, 
# then run with:   
#perl sorttable.pl tablefile.txt

#!usr/bin/perl

use strict;


my $column = 3; # column number [1-6] that the entries will be sorted by

my $table_fname = $ARGV[0];
my @table_header;
my %table;

open(my $fh_table, $table_fname) or die $!;
#get the table header if it's the first line in the file
$_ = <$fh_table>;
chomp;
if(!(m/^(comp[\d]+_.*?)\s/)) {#whole identifier captured in $1
	@table_header = split /\s+/;
}
else {#if first line is an entry rather than header, put it into the hash
	@{$table{$1}} = split /\s+/;
}
#insert all other lines as entries into the hash
#      has is keyed by identifier, content is an 
#      array of the whole line, including the identifier
while(<$fh_table>){
	chomp;
	if(m/^(comp[\d]+_.*?)\s/){
		@{$table{$1}} = split /\s+/;	
	}
}
close($fh_table);


#prints header on first line
print join( "\t", @table_header) . "\n";


#prints entries sorted by column $column in descending order
foreach my $key (sort {@{$table{$b}}[$column] <=> @{$table{$a}}[$column]} keys(%table)){
	print join("\t", @{$table{$key}}) . "\n";
}
