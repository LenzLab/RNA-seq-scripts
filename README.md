RNA-seq-scripts
===============

This is a collection of small scripts built by the Lenz lab to make RNA sequencing tasks more efficient.


./comphist.pl somename.fasta

perl comphist.pl somename.fasta

./subfasta choices.txt somename.fasta

perl subfasta choices.txt somename.fasta


choices.txt looks like this...

comp199230_c0_seq1

comp184052_c1_seq42


if you like you can pipe the output to another file

./comphist.pl somename.fasta > histogram.txt

./subfasta choices.txt somename.fasta > smaller.fasta