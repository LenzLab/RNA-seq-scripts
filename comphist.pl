#!/usr/bin/perl

# outputs the frequency that each comp# appears.
# returns a list sorted in descending order..
# comp1235 100
# comp1234 20
# comp1232 10
# comp1232 1

# we're going to use this hash to store frequencies of comps eg..
# comp1234 = 5 (means that we've seen this comp 5 times)
# First we create a hash, a hash is a set of key value pairs
my %comps = ();

# This while loop automatically loops over the input file
# so if we run ./comphist.pl foo.txt, this will loop through the lines
# of foo.txt one line at a time
while(<>) {
	# Each time the program enters this loop, the line will be placed 
	# into the special variable $_

	# This line performs a regular expression match on the line in $_
	# in this case we're looking for the pattern >comp followed
	# by a series of numbers and then terminated by an underscore
	# The carat (^) at the beginning anchors it at the beginning
	# the parentheses captures the contents into the $1 variable
	# the \d means to match any digit (0-9)
	# the + means to match at least one digit
	if ($_ =~ m/^>(comp\d+)_/) {
		# When we get here, the $1 variable holds something that looks
		# like comp12345
		# we'd like to "tally" this occurence, the ++ operator
		# increments the value by one
		# note that perl is clever enough to assume that if there
		# is nothing there, it assumes the value to be 0
		$comps{$1}++;
	}
}

# this line sorts the hash by VALUE (the count)

# sort here is taking two arguments, the first one is a comparison block and
# the second is the 'keys %comps'
# 'keys %comps' returns a list of all the available keys in the hash

# the  comparison block tells the sort function how to compare two items
# when the sorting algoritm has to find out which is bigger, $a or $b
# it executes this block and uses the return value
# in this case, instead of using $a and $b directly, we're evaluating them
# against the hash. finally the <=> operator is a NUMERICAL comparison operator
# it handles returning the order the values
foreach $k (sort {$comps{$b} <=> $comps{$a}} keys %comps) {
	# $k is populated with the key from the hash (in sorted order)
	# we display the key (comp1234) and the number of occurences
	print $k." ".$comps{$k}."\n";
}
