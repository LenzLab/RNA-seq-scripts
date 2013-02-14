#!usr/bin/perl

use strict;

my $left_table_fname = $ARGV[0];
my $right_table_fname = $ARGV[1];
my @table_header;
my %left_table;
my %right_table;


#2-layered hash used for these: first layer is keyed by 
#just comps, each comp has its own hash keyed by full 
#identifiers. The entry for an identifier is an array containing
#every token on that line, separated by whitespace, including 
#the identifier
#%tablehash = {
#		'comp' = {
#			'identifier' => (ident, #, #, #, #, #, #)
#		}
#}
open(my $fh_left_table, $left_table_fname) or die $!;
#get the table header if it's the first line in the file
$_ = <$fh_left_table>;
chomp;
if(!(m/^((comp.*?)_.*?)\s/)) {#whole identifier captured in $1, just comp in $2
	@table_header = split /\s+/;
}
else {#if first line is an entry rather than header, put it into the hash
	@{$left_table{$2}{$1}} = split /\s+/;
}
#insert all other lines as entries into the hash
while(<$fh_left_table>){
	chomp;
	if(m/^((comp.*?)_.*?)\s/){
		@{$left_table{$2}{$1}} = split /\s+/;	
	}
}
close($fh_left_table);

#enter values from 2nd file into another hash
open(my $fh_right_table, $right_table_fname) or die $!;
while(<$fh_right_table>){
	chomp;
	if(m/^((comp.*?)_.*?)\s/){
		@{$right_table{$2}{$1}} = split /\s+/;
	}
}
close($fh_right_table);
#reading files done

#prints headers on first line
print join( "\t", @table_header) ."\t". join( "\t", @table_header) . "\n";


#prints entries in parallel
foreach my $comp (keys(%left_table)){
	foreach my $ident (keys(%{$left_table{$comp}})){
		my @left_entry = @{$left_table{$comp}{$ident}}; 
		my @right_entry;
		print join("\t", @left_entry);
		if(exists $right_table{$comp}{$ident}) {
			@right_entry = @{$right_table{$comp}{$ident}};
			print "\t".join("\t", @right_entry);
			delete $right_table{$comp}{$ident};
		}
		print "\n";
	}
	#since idents that exist in this comp on the left table were deleted
	#on the right table, any remaining idents in this comp on the right 
	#table should be printed, with the left side blank
	foreach my $ident (keys(%{$right_table{$comp}})){
		my @right_entry = @{$right_table{$comp}{$ident}};
		my $array_size = @right_entry;
		my $spacing = "\t" x ($array_size+1);
		print $spacing . "\t" . join("\t", @right_entry)."\n"; 
	}
}
