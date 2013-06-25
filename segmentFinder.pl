#segmentFinder.pl   MC   14-6-2013

#usage: perl segmentFinderV1.pl MAFFTfile.txt

#Reads a MAFFT alignment file and detects segments.
#
#detects a segment change when the pattern of differences
#between two columns changes, or if a strand changes from blank (hyphens) to coding
#If there are consecutive segments shorter than $MIN_SEGMENT_LENGTH 
#(this value can be set below; set to 1 or less for no segment combination), 
#combines them into a composite segment. 
#Output is a list of segment lengths and multiplicities (for non-composites)
#in the order that they appear.

#a copy of the MAFFT file with the beginning of each segment marked with its length is also printed.
#be aware that a segment length of 1 may be misleading, as there will be no gap between its marker
#and the length of the next segment. For example, a 1-segment followed by an 18-segment will appear
#to be marked as a 118-segment.

#!usr/bin/per
use strict;

my $MIN_SEGMENT_LENGTH = 10;




print "\$MIN_SEGMENT_LENGTH = $MIN_SEGMENT_LENGTH\n";
my $MAFFTfile = $ARGV[0];
my @segments = @{findSegments($MAFFTfile)};
@segments = @{combineSmallSegments(\@segments, $MIN_SEGMENT_LENGTH)};
printSegmentInfo(\@segments);
printMarkedMAFFT(\@segments, $MAFFTfile);


sub findSegments{
#################################################
#Takes the name of a MAFFT file, reads it       #
#and detects segments, then returns an          #
#array with information about the segments found#
#################################################

	my $filename = shift(@_);
	
	my @lineBuffer;
	my @seqBuffer;
	my $currentPos = 0;
	my $segLength = 0;
	my $segNumber = 0;
	my @thisPattern;
	my @lastPattern;
	my $thisMulti;
	my $lastMulti;
	my $bufferReady = 0;
	my @segments;
	
	
	open(my $fh, $MAFFTfile) or die $!;
	
	#main loop for segment detecting
	SECTION: while(1){
	
		#if between sections, load the next section as lines into an array
		while(!$bufferReady){
			$_ = <$fh>;
			if(!$_){
				if(@lineBuffer == 0){
					last SECTION;
				}else{
					$bufferReady = 1;
				}
			}elsif(!/^(\S+?)\s+(\S+)\s*$/){
				if(@lineBuffer == 0){
					next;
				}else{
					$bufferReady = 1;
				}
			}else{
				push(@lineBuffer, $_);	
			}
		}
	
		#load the sequencing part of each line individually into another array, 
		#each as an array of individual characters
		foreach my $line (@lineBuffer){
			$line =~ /^(\S+?)\s+(\S+)\s*$/;
			my @lineArray = split("", $2);
			push(@seqBuffer, \@lineArray);
		}
	
		#shift one column of a single character over and compare for a 
		#possible segment change
		while(@{$seqBuffer[0]}){
			@lastPattern = @thisPattern;
			undef(@thisPattern);
			
			my %patternHash;
			$lastMulti = $thisMulti;
			$thisMulti = 0;
			#determine the pattern for this column
			for(my $i = 0; $i < @seqBuffer; $i++){
				my $char = shift(@{$seqBuffer[$i]});
				if($char eq "-"){
					push(@thisPattern, "-");
					$thisMulti = keys(%patternHash) + 1;
				}elsif(exists($patternHash{$char})){
					push(@thisPattern, $patternHash{$char});
				}else{
					my $numSeqs = keys(%patternHash);
					$patternHash{$char} = $numSeqs + 1;
					push(@thisPattern, $patternHash{$char});
					$thisMulti++;
				}
			}
			if(@lastPattern){
				#compares the patterns of the current column
				#with the previous column to detect a segment 
				#boundary
				for(my $i = 0; $i < @lastPattern; $i++){
					if( $lastPattern[$i] ne $thisPattern[$i] ){
						$segNumber++;
						push(@segments, {
								   "length" => $segLength,
								   "multiplicity" => $lastMulti,
								   "isComposite" => 0
								}
						);
						$segLength = 0;
						last;
					}
				}
			}
			$segLength++;
			$currentPos++;
		}
	
		$bufferReady = 0;
		undef(@lineBuffer);
		undef(@seqBuffer);
	}
	close($fh);
	#enter final segment since the loop only reports segments when it finds a new one
	$segNumber++;
	push(@segments, {
			   "length" => $segLength,
			   "multiplicity" => $lastMulti,
			   "isComposite" => 0
			}
	);

	return \@segments;

}
	
sub combineSmallSegments{
###########################################
#Takes an array of segment information and#
#an integer representing the threshold for#
#the length a segment must surpass to not #
#be considered for consolidation. Returns #
#an array of segment information with     #
#consecutive small segments combined.     #
###########################################
	my @segments = @{shift(@_)};
	my $MIN_SEGMENT_LENGTH = shift(@_);

	#find consecutive short segments and combine them into composite segments
	for(my $i = 1; $i < @segments; $i++){
		my %thisSegment = %{$segments[$i]};
		if($thisSegment{"length"} < $MIN_SEGMENT_LENGTH){
			my %lastSegment = %{$segments[$i-1]};
			if($lastSegment{"isComposite"} or
			   $lastSegment{"length"} < $MIN_SEGMENT_LENGTH
			  ){
				$lastSegment{"isComposite"} = 1;
				$lastSegment{"length"} += $thisSegment{"length"};
				$segments[$i-1] = \%lastSegment;
				splice(@segments, $i, 1);
				$i--;
			}
		}
	}

	return \@segments;
}


sub printSegmentInfo{
########################################
#Given an array of segment information,#
#prints the segments in columns        #
########################################
	my @segments = @{shift(@_)};

	#segment info output by columns
	print("Seg #\tLength\tMultiplicity\n");
	for(my $i = 1; $i <= @segments; $i++){
		my %segment = %{$segments[$i-1]};
		print $i."\t".$segment{"length"};
		if(!$segment{"isComposite"}){
			print "\t".$segment{"multiplicity"};
		}
		print "\n";
	}
	print "\n";
}


sub printMarkedMAFFT{
###################################################
#Given an array of segment info and the name of   #
#the MAFFT file it came from, prints the contents #
#of the MAFFT file with each segment marked by its#
#length.                                          #
###################################################
	my @segments = @{shift(@_)};
	my $MAFFTfile = shift(@_);

	#output MAFFT file with segments marked
	my $indentLength;
	my $sectionLength;
	my $lineLength;
	my $segIndex = 0;
	my $markerLine;
	my $spacesLeft = 0;
	my $currentSection;
	
	open(my $fh, $MAFFTfile) or die $!;
	while(){
		if(!$currentSection){
			my $haveLines = 0;
			while(<$fh>){
				if(/^(\S+\s+)(\S+)\s*$/){
					$currentSection .= $_;
					$haveLines = 1;
		
					if(!$lineLength){
						$indentLength = length($1);
						$sectionLength = length($2);
						$lineLength = $indentLength + $sectionLength;
						$markerLine = " " x $indentLength;
					}
				}elsif(!/\S/ and $haveLines){
					$currentSection .= $_;
					last;
				}
			}
		}
	
		if(length($markerLine) >= $lineLength){
			print $markerLine . "\n";
			$markerLine = " " x $indentLength;
			print $currentSection;
			$currentSection = "";
	
		}elsif($spacesLeft == 0){
			if($segIndex < @segments){
				my %segment = %{$segments[$segIndex]};
				$segIndex++;
				my $segLength = $segment{"length"};
				$spacesLeft = $segLength;
		
				my $charsLeftOnLine = $lineLength - length($markerLine);
				if($charsLeftOnLine < length($segLength)){
					$spacesLeft -= $charsLeftOnLine;
				}else{
					$spacesLeft -= length($segLength);
				}
				$markerLine .= $segLength;
			}else{
				print $markerLine . "\n";
				print $currentSection;
				$currentSection = "";
				last;
			}
		}else{
			$markerLine .= " ";
			$spacesLeft--;
		}
	}
	close($fh);
}


