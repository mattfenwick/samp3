#! /usr/bin/perl
#
# Takes output from the pred.tab file created by talos and creates
# a distance constraint file in Dyana format
# Usage: talos2dyana.prl pred.tab switch > output.aco
#   where switch is either 'all' or 'good'
# 'all' selects all values listed in the pred.tab file
# 'good' only selects those with a class value of good
# factor represents a value that the errors are multiplied by.
# Example: talos2dyana.prl pred.tab all 1.5 > polx.aco
# NOTE: produces additional junk lines at top of file

use strict;
use warnings;

my %one2three = (
  "A" => "ALA",
  "C" => "CYS",
  "D" => "ASP",
  "E" => "GLU",
  "F" => "PHE",
  "G" => "GLY",
  "H" => "HIS",
  "I" => "ILE",
  "K" => "LYS",
  "L" => "LEU",
  "M" => "MET",
  "N" => "ASN",
  "P" => "PRO",
  "Q" => "GLN",
  "R" => "ARG",
  "S" => "SER",
  "T" => "THR",
  "V" => "VAL",
  "W" => "TRP",
  "Y" => "TYR"
);

my $input = $ARGV[0];
my $switch = $ARGV[1];
my $factor = $ARGV[2];

	open(my $fh, "<", $input)  || die "Can't open $input.";
	while (my $line = <$fh>) {
		my @fields = split(' ', $line);

 #print "FIELDS: " . scalar(@fields) . "  " . join('<>', @fields) . "\n";

		if (!$fields[0]) { next;}
	    	if ($fields[0] =~ m/#/) { next;}
		if ($fields[0] =~ m/REMARK/) { next;}
		if ($fields[0] =~ m/DATA/) { next;}
		if ($fields[0] =~ m/VARS/) { next;}
		if ($fields[0] =~ m/FORMAT/) { next;}
	    
		my $resid =   $fields[0];
		my $resname = $one2three{$fields[1]};
		my $phi   = $fields[2];
		my $psi   = $fields[3];
		my $dphi  = $fields[4];
		my $dpsi  = $fields[5];
		my $dist  = $fields[6];
		my $dunno1 =   $fields[7];
		my $dunno2 =   $fields[8];
		my $dunno3 =   $fields[9];
		my $class =   $fields[10];

		my ($phi_min, $phi_max, $psi_min, $psi_max);
		
		if ( ($phi != 9999.000) || ($psi != 9999.000)) {
			
			# PHI SECTION
			if ($phi == 9999.000) {	next;}

			$phi_min = $phi - ($factor * $dphi);
			$phi_max = $phi + ($factor * $dphi);
	
			if ( ($switch eq "good" && $class eq "Good") || $switch eq "all") {
				print "  $resid  $resname";
				printf ("\t PHI%8.1f%8.1f\n",$phi_min,$phi_max);
			} # else { print "skipping -- $switch $class\n";}
	       
			# PSI SECTION 
			if ($psi == 9999.000) { next;}

			$psi_min = $psi - ($factor * $dpsi);
			$psi_max = $psi + ($factor * $dpsi);
			    		
			if ( ($switch eq "good" && $class eq "Good") || $switch eq "all") {
				print "  $resid  $resname";
				printf ("\t PSI%8.1f%8.1f\n",$psi_min,$psi_max);
        		}
		}
	}   	 
