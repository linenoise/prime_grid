#!/usr/bin/perl -w
use strict;
use Data::Dumper;

###
# prime_grid.pl
# A brute force test of grid parity for the fifty million prime numbers
# Why?  http://www.futilitycloset.com/2012/06/12/transversal-of-primes/
#
# Copyright (c) 2012 by Danne Stayskal
# Available under the GPL v.3 (see LICENSE.txt)
#
# Because primes.
###

$| = 1; ### Autoflush STDOUT.

### Load the first million prime numbers into memory
open('PRIMES', '<', 'primes1.txt')||
	die "Please download primes1.txt from http://primes.utm.edu and place it in this directory";
my @primes;
print "Loading the first million primes...";
foreach my $line (<PRIMES>) {
	chomp $line;
	next if $line =~ /The/;
	next if $line =~ /^\s*$/;
	$line =~ s/(\d*)/push @primes, $1 if $1/sexg;
}
print "done.\n";

### Prealculate prime lookup mask (so checking whether something is prime isn't linear time)
my $prime_mask = [];
print "Precalculating prime bitmask...";
my $next_prime = shift @primes;
push @primes, $next_prime;
foreach my $i (0..$primes[-2]){
	last if ($next_prime eq '2' && scalar(@$prime_mask) > 4);
	if ($i == $next_prime-1){
		push @$prime_mask, 1;
		$next_prime = shift @primes;
		push @primes, $next_prime;
	} else {
		push @$prime_mask, 0;
	}
}
print "done.\n";
print "   - prime mask has ".scalar(@$prime_mask)." elements.\n";

my $largest_valid_check = int(sqrt(scalar(@$prime_mask)))-1;

print "   - the largest prime we can check with this mask is ".$largest_valid_check.".\n";

### Iterate through each prime
foreach my $p (@primes) {
	
	next if $p > $largest_valid_check;

	### Contruct a PxP grid consisting of primes
	my $grid = [];
	my $counter = 1;
	foreach my $i (1..$p) {
		my $row = [];
		foreach my $j (1..$p) {
			push @$row, $counter++;
		}
		push @$grid, $row;
	}

	### Print and check the table
	print "Examining $p...\n";
	my $y_base = [];
	my $x_base = [];
	foreach (1..$p) {
		push @$x_base, 0;
		push @$y_base, 0;
	}
	foreach my $i (0..scalar(@$grid)-1) {
		my $row = $$grid[$i];
		foreach my $j (0..scalar(@$row)-1) {
			my $element = $$row[$j];

			if ($$prime_mask[$element-1]) {
				### We have a prime.  Mark it in the base vectors
#				printf('[%4d] ',$element);
				$$y_base[$i]++;
				$$x_base[$j]++;

			} else {
#				printf(' %4d  ',$element);
			}
		}
#		print "\n";
	}

  ### Print whether the x and y bases are fully covered
	my $parity = 1;
	foreach my $x_pos (0..scalar(@$x_base)-1){
	  if ($$x_base[$x_pos] == 0) {
			print "   - There are no possible primes at x_position $x_pos.\n";
			$parity = 0;
		}
	}
	foreach my $y_pos (0..scalar(@$y_base)-1){
	  if ($$y_base[$y_pos] == 0) {
			print "   - There are no possible primes at y_position $y_pos.\n";
			$parity = 0;
		}
	}
	if ($parity) {
		print "   - Each row and column has at least one prime number.\n"
  }

}

