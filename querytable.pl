#!usr/bin/perl

use strict;

#this script filters a file representing sequence presence/expression as a table
#through conditions set by the user. only rows in the table that satisfy all 
#conditions will be printed.

#usage: perl querytable.pl tablefile.txt
#    or perl querytable.pl tablefile.txt conditions.txt


#two ways to use this script: either enter a single conditional expression
#as a literal string in $condition, or supply as the 2nd argument to the script 
#a text file containing a condition on each line. if a file is supplied, the string in 
#the $condition variable will not be used. the condition file can also be seen as
#a series of conditions joined by an "and" between lines
#for both the file and the $condition variable, use $[digit] to express the value 
#in a specific column. for example $5 refers to the value in column 5
#a conditions file might look like this (translations on the right not part of file): 
#$1 > $2                 the value in col. 1 is greater than that of col. 2 
#$1 > 20            (and)the value in col. 1 is greater than 20
#$3 != 0 	    (and)the value in column 3 is not 0
#$2 == $3           (and)the value in col. 2 is equal to the value in col. 3

#using this example is equivalent to entering the string 
#'$1 > $2 and $1 > 20 and $3 != 0 and $2 == $3'
#into $condition below, and leaving off the conditions file.

# a number preceded by $ indicates the column number. 
#i.e. $3 indicates the value in column 3
my $condition = '$1 > $2 and $1 > 20 and $3 != 0 and $2 == $3';


#
#preparing conditions array for use
#
my @conditions;
if(@ARGV > 1) {
	my $fname_conditions = $ARGV[1];
	open(my $fh_conditions, $fname_conditions) or die $!;
	@conditions = <$fh_conditions>;
	close($fh_conditions);
}
else{
	@conditions[0] = $condition;
}

#this loop translates the conditions into actual statements that can be 
#evaluated later
foreach my $statement (@conditions) {
	chomp $statement;
	#replaces something like $3 in the condition with $table{$key}[3]
	$statement =~ s:\$([\d]+):\$table{\$key}\[\1\]:g
}



#
#preparing table file hash
#
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

#
#filter table hash with @conditions array, print entries that pass all conditions
#
foreach my $key (%table) {
	my $printable = 1;
	foreach my $statement (@conditions) {
		if(!eval $statement) {
			$printable = 0;
			last;
		}
	}
	if($printable) {
		print join("\t", @{$table{$key}}) . "\n";
	}
}

