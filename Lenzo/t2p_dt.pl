#!/usr/local/bin/perl5

# kevin lenzo 12/07
#
# run the decision tree letter-to-phone rules
# 
# if run with no arguments, goes into interactive
# mode.  If given an argument, it expects the arg
# to be a t2p dictionary alignment, from which it
# will generate statistics.

$| = 1;
$interact = (!@ARGV);

# set the decision tree to use in the next line here.
# it will load the subroutine.
#require "r1d7.pl"; # the big tree from the 58K dictionary

if ($interact) {
    # print "\n decision-tree based text-to-phoneme conversion\n\n";
    $prompt =  " ";
    print $prompt;

    while (<>) {
	chomp;
	if (/^\/quit$/i) {
	    print "\n<exiting>\n\n";
	    exit(0);
	}
	tr/a-z/A-Z/;

	my @phones;
	foreach $word (split /\s+/, $_) {
	    push @phones, &l2p(split(//, $word));
	}
#	$phones = join(" ", &cleanup(@phones));
	my $phones .= join(" ", @phones);
	print join(" ", @phones)."\n";

	print $prompt;
    }
} else {
    my $input = $ARGV[0];

    open (IN, $input) || die "can't open $input: $!\n";

    my $gw = 0; my $pc; my $wc; my $gp;
    while (<IN>) {
	chomp;
	($w, $p) = split /\s+/, $_, 2;
	$w =~ s/\(.*//;
	$w =~ tr/a-z/A-Z/;

	@phones = &l2p(split(//, $w));
	@dphones = split /\s+/, $p;

	my $wgp = 0;
	foreach (0..$#phones) {
	    $wgp += ($phones[$_] eq $dphones[$_]);
	    $pc++;
	}

	$gp += $wgp;
#	print "$w $wgp ".scalar(@phones)."\n";
	if ($wgp == @phones) {
	    $gw++;
#	    print "\n\ngood word: $w\n\n";
	}
	$wc++;

	if (!($wc % 500)) {
	    printf "$wc %0.2f %0.2f\t$w $p", ($gp/$pc), ($gw/$wc);
	    $ph = join(" ", @phones);
	    print "/ $ph" unless $ph eq $p;
	    print "\n";
	}
	
    }
    close IN;
}


sub cleanup {
    # clean up the phonetic output a little

    my @phones = @_;
    my $x = " ".join(" ", @phones)." ";

    $x =~ s/ (\S+)( \1)+/ $1/g;
    $x =~ s/N NG/NG/g;

    $x =~ s/[AEIOU]X?[^R] ([AEIOU]X?R)/$1/g;

    $x =~ s/_//g;
    $x =~ s/^\s+//;
    $x =~ s/\s+$//;
    $x =~ s/\s+/ /g;

    split(/\s+/, $x);
}

sub l2p {
    # the letter-to-phone workhorse
    my @letters = @_;

    my @orig_letter = @letters;
    push @letters, ('-', '-', '-');
    unshift @letters, ('-', '-', '-');

    my @result; 
    my $localgoodcount = 0;
    my $opos;
    my @phones;

    for $opos (0..$#orig_letter) {
	# context2phone is the dtree subroutine from the "require"
	$res = &context2phone(@letters[$opos..$opos+6]);
	push @phones, $res;
    }

    @phones;
}
sub context2phone { 
  my @L = @_;
  my %att;

  $att{'L3'} = $L[0];
  $att{'L2'} = $L[1];
  $att{'L1'} = $L[2];
  $att{'L'} = $L[3];
  $att{'R1'} = $L[4];
  $att{'R2'} = $L[5];
  $att{'R3'} = $L[6];

  if ($att{'L'} eq '5') { 
    return 's'; # unique at depth 1
  } 
  if ($att{'L'} eq 'K') { 
    return 'k'; # unique at depth 1
  } 
  if ($att{'L'} eq 'Q') { 
    if ($att{'L1'} eq 'I') { 
      if ($att{'R3'} eq 'R') { 
        if ($att{'L2'} eq 'L') { 
          if ($att{'R2'} eq 'E') { 
            if ($att{'R1'} eq 'U') { 
              if ($att{'L3'} eq 'P') { 
                return 'k'; # depth limit (1/2; 2 classes) at depth 7
              } 
              return 'i';
            } 
            return 'i';
          } 
          return 'i';
        } 
        return 'k';
      } 
      if ($att{'R3'} eq 'N') { 
        return 'i'; # unique at depth 3
      } 
      return 'k';
    } 
    if ($att{'L1'} eq 'X') { 
      return 's'; # unique at depth 2
    } 
    if ($att{'L1'} eq 'C') { 
      return '_'; # unique at depth 2
    } 
    return 'k';
  } 
  if ($att{'L'} eq 'J') { 
    if ($att{'R2'} eq 'A') { 
      return 'd'; # unique at depth 2
    } 
    if ($att{'R2'} eq 'T') { 
      if ($att{'R3'} eq 'S') { 
        return 'd'; # unique at depth 3
      } 
      return 'Z';
    } 
    if ($att{'R2'} eq 'Z') { 
      return 'd'; # unique at depth 2
    } 
    return 'Z';
  } 
  if ($att{'L'} eq 'P') { 
    if ($att{'L1'} eq 'X') { 
      if ($att{'R3'} eq 'M') { 
        if ($att{'L3'} eq '-') { 
          if ($att{'R2'} eq 'I') { 
            if ($att{'R1'} eq 'R') { 
              return 's';
            } 
            return '_';
          } 
          return 's';
        } 
        return 's';
      } 
      return 's';
    } 
    if ($att{'L1'} eq 'R') { 
      if ($att{'L3'} eq '-') { 
        return '_'; # unique at depth 3
      } 
      if ($att{'L3'} eq 'M') { 
        return '_'; # unique at depth 3
      } 
      return 'p';
    } 
    if ($att{'L1'} eq 'I') { 
      if ($att{'L2'} eq 'P') { 
        if ($att{'R1'} eq 'I') { 
          return 'p'; # unique at depth 4
        } 
        return 'a';
      } 
      return 'p';
    } 
    if ($att{'L1'} eq 'P') { 
      if ($att{'R3'} eq 'T') { 
        if ($att{'L3'} eq 'R') { 
          return 'p'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'R3'} eq 'A') { 
        if ($att{'R2'} eq 'I') { 
          if ($att{'R1'} eq 'L') { 
            if ($att{'L2'} eq 'U') { 
              if ($att{'L3'} eq 'S') { 
                return 'l'; # depth limit (1/2; 2 classes) at depth 7
              } 
              return '_';
            } 
            return 'l';
          } 
          return 'l';
        } 
        return '_';
      } 
      if ($att{'R3'} eq '-') { 
        if ($att{'R2'} eq 'R') { 
          if ($att{'R1'} eq 'E') { 
            if ($att{'L2'} eq 'O') { 
              if ($att{'L3'} eq 'L') { 
                return 'p'; # depth limit (1/2; 2 classes) at depth 7
              } 
              return '_';
            } 
            return 'p';
          } 
          return '_';
        } 
        if ($att{'R2'} eq 'L') { 
          return 'p'; # unique at depth 4
        } 
        return '_';
      } 
      return '_';
    } 
    if ($att{'L1'} eq 'A') { 
      if ($att{'R1'} eq 'H') { 
        return '_'; # unique at depth 3
      } 
      if ($att{'R1'} eq 'T') { 
        if ($att{'L2'} eq 'B') { 
          return '_'; # unique at depth 4
        } 
        return 'p';
      } 
      if ($att{'R1'} eq 'P') { 
        if ($att{'R2'} eq 'O') { 
          if ($att{'L2'} eq 'R') { 
            return '_'; # unique at depth 5
          } 
          return 'p';
        } 
        return 'p';
      } 
      return 'p';
    } 
    if ($att{'L1'} eq 'U') { 
      if ($att{'R1'} eq 'H') { 
        return '_'; # unique at depth 3
      } 
      return 'p';
    } 
    if ($att{'L1'} eq 'O') { 
      if ($att{'R1'} eq '-') { 
        return '_'; # unique at depth 3
      } 
      if ($att{'R1'} eq 'H') { 
        return '_'; # unique at depth 3
      } 
      if ($att{'R1'} eq 'P') { 
        if ($att{'R3'} eq 'R') { 
          if ($att{'R2'} eq 'E') { 
            if ($att{'L2'} eq 'L') { 
              if ($att{'L3'} eq 'E') { 
                return '_'; # depth limit (1/2; 2 classes) at depth 7
              } 
              return 'p';
            } 
            return '_';
          } 
          return 'p';
        } 
        return 'p';
      } 
      return 'p';
    } 
    if ($att{'L1'} eq '1') { 
      if ($att{'R1'} eq 'H') { 
        return '_'; # unique at depth 3
      } 
      return 'p';
    } 
    if ($att{'L1'} eq '-') { 
      if ($att{'R1'} eq 'H') { 
        return '_'; # unique at depth 3
      } 
      return 'p';
    } 
    if ($att{'L1'} eq 'L') { 
      if ($att{'R1'} eq 'A') { 
        return 'p'; # unique at depth 3
      } 
      return '_';
    } 
    if ($att{'L1'} eq 'E') { 
      if ($att{'L2'} eq 'S') { 
        if ($att{'L3'} eq 'S') { 
          return 'p'; # unique at depth 4
        } 
        return '_';
      } 
      return 'p';
    } 
    if ($att{'L1'} eq 'S') { 
      if ($att{'L3'} eq '-') { 
        if ($att{'R1'} eq 'H') { 
          return '_'; # unique at depth 4
        } 
        return 'p';
      } 
      if ($att{'L3'} eq 'X') { 
        return 's'; # unique at depth 3
      } 
      return 'p';
    } 
    if ($att{'L1'} eq 'M') { 
      if ($att{'R1'} eq 'H') { 
        return '_'; # unique at depth 3
      } 
      if ($att{'R1'} eq 'T') { 
        if ($att{'R3'} eq '3') { 
          return 'p'; # unique at depth 4
        } 
        if ($att{'R3'} eq '-') { 
          if ($att{'R2'} eq '-') { 
            if ($att{'L2'} eq 'O') { 
              return '_';
            } 
            return 'p';
          } 
          return '_';
        } 
        return '_';
      } 
      return 'p';
    } 
    return 'p';
  } 
  if ($att{'L'} eq '4') { 
    if ($att{'L3'} eq 'B') { 
      return 'j'; # unique at depth 2
    } 
    if ($att{'L3'} eq '-') { 
      return 'j'; # unique at depth 2
    } 
    if ($att{'L3'} eq 'F') { 
      return 'j'; # unique at depth 2
    } 
    return 'i';
  } 
  if ($att{'L'} eq 'I') { 
    if ($att{'R1'} eq 'P') { 
      if ($att{'L1'} eq 'P') { 
        if ($att{'R2'} eq 'I') { 
          return 'i'; # unique at depth 4
        } 
        return '_';
      } 
      return 'i';
    } 
    if ($att{'R1'} eq 'Q') { 
      if ($att{'L3'} eq 'X') { 
        return 'l'; # unique at depth 3
      } 
      return 'i';
    } 
    if ($att{'R1'} eq '3') { 
      if ($att{'L1'} eq 'G') { 
        return 'i'; # unique at depth 3
      } 
      if ($att{'L1'} eq 'O') { 
        return 'a'; # unique at depth 3
      } 
      if ($att{'L1'} eq 'V') { 
        return 'i'; # unique at depth 3
      } 
      if ($att{'L1'} eq 'B') { 
        return 'i'; # unique at depth 3
      } 
      if ($att{'L1'} eq 'D') { 
        return 'i'; # unique at depth 3
      } 
      if ($att{'L1'} eq 'R') { 
        return 'i'; # unique at depth 3
      } 
      if ($att{'L1'} eq 'F') { 
        return 'i'; # unique at depth 3
      } 
      return '_';
    } 
    if ($att{'R1'} eq 'F') { 
      if ($att{'L1'} eq 'O') { 
        return 'a'; # unique at depth 3
      } 
      return 'i';
    } 
    if ($att{'R1'} eq 'R') { 
      if ($att{'L1'} eq 'A') { 
        return 'E'; # unique at depth 3
      } 
      if ($att{'L1'} eq 'O') { 
        if ($att{'L2'} eq 'L') { 
          if ($att{'L3'} eq 'U') { 
            return 'A'; # unique at depth 5
          } 
          return 'a';
        } 
        return 'a';
      } 
      return 'i';
    } 
    if ($att{'R1'} eq '4') { 
      return '_'; # unique at depth 2
    } 
    if ($att{'R1'} eq 'N') { 
      if ($att{'R2'} eq 'I') { 
        return 'i'; # unique at depth 3
      } 
      if ($att{'R2'} eq 'N') { 
        return 'i'; # unique at depth 3
      } 
      if ($att{'R2'} eq 'E') { 
        if ($att{'L1'} eq 'E') { 
          return '_'; # unique at depth 4
        } 
        if ($att{'L1'} eq 'M') { 
          if ($att{'L3'} eq 'X') { 
            return 'm'; # unique at depth 5
          } 
          return 'i';
        } 
        if ($att{'L1'} eq 'A') { 
          return 'E'; # unique at depth 4
        } 
        if ($att{'L1'} eq 'O') { 
          return 'a'; # unique at depth 4
        } 
        return 'i';
      } 
      if ($att{'R2'} eq 'A') { 
        if ($att{'L3'} eq 'O') { 
          if ($att{'L1'} eq 'D') { 
            return 'd';
          } 
          return 'i';
        } 
        if ($att{'L3'} eq 'X') { 
          return '_'; # unique at depth 4
        } 
        return 'i';
      } 
      if ($att{'R2'} eq 'G') { 
        if ($att{'L3'} eq 'A') { 
          return 'i'; # unique at depth 4
        } 
        if ($att{'L3'} eq 'M') { 
          return 'i'; # unique at depth 4
        } 
        return 'E~';
      } 
      if ($att{'R2'} eq 'U') { 
        return 'i'; # unique at depth 3
      } 
      if ($att{'R2'} eq 'O') { 
        return 'i'; # unique at depth 3
      } 
      return 'E~';
    } 
    if ($att{'R1'} eq 'B') { 
      if ($att{'L2'} eq 'E') { 
        return 's'; # unique at depth 3
      } 
      if ($att{'L2'} eq 'F') { 
        return 'E'; # unique at depth 3
      } 
      return 'i';
    } 
    if ($att{'R1'} eq 'L') { 
      if ($att{'L1'} eq 'U') { 
        if ($att{'L3'} eq 'O') { 
          return 'i'; # unique at depth 4
        } 
        if ($att{'L3'} eq '-') { 
          return 'i'; # unique at depth 4
        } 
        if ($att{'L3'} eq 'A') { 
          return 'i'; # unique at depth 4
        } 
        if ($att{'L3'} eq 'B') { 
          if ($att{'R3'} eq 'O') { 
            return '_'; # unique at depth 5
          } 
          return 'j';
        } 
        return 'j';
      } 
      if ($att{'L1'} eq 'A') { 
        return 'j'; # unique at depth 3
      } 
      if ($att{'L1'} eq 'O') { 
        return 'a'; # unique at depth 3
      } 
      if ($att{'L1'} eq 'E') { 
        return 'j'; # unique at depth 3
      } 
      return 'i';
    } 
    if ($att{'R1'} eq 'E') { 
      if ($att{'L1'} eq 'R') { 
        if ($att{'R2'} eq 'R') { 
          if ($att{'L3'} eq 'R') { 
            return 'j'; # unique at depth 5
          } 
          if ($att{'L3'} eq 'E') { 
            return 'j'; # unique at depth 5
          } 
          return 'i';
        } 
        if ($att{'R2'} eq 'Z') { 
          if ($att{'L3'} eq 'U') { 
            return 'i'; # unique at depth 5
          } 
          return 'j';
        } 
        if ($att{'R2'} eq '1') { 
          return 'j'; # unique at depth 4
        } 
        if ($att{'R2'} eq 'U') { 
          if ($att{'L3'} eq '-') { 
            return 'i'; # unique at depth 5
          } 
          return 'j';
        } 
        if ($att{'R2'} eq 'L') { 
          return 'j'; # unique at depth 4
        } 
        if ($att{'R2'} eq '2') { 
          if ($att{'L3'} eq 'A') { 
            return 'j'; # unique at depth 5
          } 
          if ($att{'L3'} eq 'E') { 
            return 'j'; # unique at depth 5
          } 
          return 'i';
        } 
        if ($att{'R2'} eq 'N') { 
          if ($att{'R3'} eq 'T') { 
            return 'i'; # unique at depth 5
          } 
          return 'j';
        } 
        return 'i';
      } 
      if ($att{'L1'} eq 'F') { 
        if ($att{'L3'} eq 'O') { 
          return 'i'; # unique at depth 4
        } 
        if ($att{'L3'} eq 'E') { 
          return 'i'; # unique at depth 4
        } 
        return 'j';
      } 
      if ($att{'L1'} eq 'X') { 
        return 's'; # unique at depth 3
      } 
      if ($att{'L1'} eq 'P') { 
        if ($att{'R2'} eq '-') { 
          return 'i'; # unique at depth 4
        } 
        return 'j';
      } 
      if ($att{'L1'} eq 'V') { 
        if ($att{'R2'} eq '-') { 
          return 'i'; # unique at depth 4
        } 
        if ($att{'R2'} eq 'N') { 
          if ($att{'L3'} eq 'R') { 
            return '_'; # unique at depth 5
          } 
          return 'j';
        } 
        return 'j';
      } 
      if ($att{'L1'} eq 'O') { 
        return 'a'; # unique at depth 3
      } 
      if ($att{'L1'} eq 'G') { 
        if ($att{'L3'} eq 'L') { 
          return 'i'; # unique at depth 4
        } 
        return 'j';
      } 
      if ($att{'L1'} eq 'U') { 
        if ($att{'L2'} eq 'O') { 
          return 'i'; # unique at depth 4
        } 
        if ($att{'L2'} eq 'S') { 
          return 'i'; # unique at depth 4
        } 
        return 'j';
      } 
      if ($att{'L1'} eq 'A') { 
        if ($att{'L2'} eq 'M') { 
          if ($att{'L3'} eq 'I') { 
            return 'i'; # unique at depth 5
          } 
          return '_';
        } 
        if ($att{'L2'} eq 'Y') { 
          if ($att{'L3'} eq 'U') { 
            return 'j'; # unique at depth 5
          } 
          return '_';
        } 
        if ($att{'L2'} eq 'T') { 
          if ($att{'L3'} eq 'S') { 
            return 'i'; # unique at depth 5
          } 
          return '_';
        } 
        if ($att{'L2'} eq 'I') { 
          return 'j'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'L1'} eq 'C') { 
        if ($att{'R2'} eq '-') { 
          return 'i'; # unique at depth 4
        } 
        return 'j';
      } 
      if ($att{'L1'} eq 'D') { 
        if ($att{'L3'} eq 'L') { 
          return 'i'; # unique at depth 4
        } 
        return 'j';
      } 
      if ($att{'L1'} eq 'T') { 
        if ($att{'R2'} eq 'S') { 
          return 'i'; # unique at depth 4
        } 
        if ($att{'R2'} eq '-') { 
          return 'i'; # unique at depth 4
        } 
        return 'j';
      } 
      if ($att{'L1'} eq 'M') { 
        if ($att{'R2'} eq 'S') { 
          return 'i'; # unique at depth 4
        } 
        if ($att{'R2'} eq '-') { 
          return 'i'; # unique at depth 4
        } 
        return 'j';
      } 
      if ($att{'L1'} eq 'S') { 
        if ($att{'R2'} eq '-') { 
          return 'i'; # unique at depth 4
        } 
        return 'j';
      } 
      if ($att{'L1'} eq 'L') { 
        if ($att{'L2'} eq 'P') { 
          return 'i'; # unique at depth 4
        } 
        if ($att{'L2'} eq 'O') { 
          if ($att{'L3'} eq 'C') { 
            return 'j'; # unique at depth 5
          } 
          return 'i';
        } 
        if ($att{'L2'} eq '-') { 
          if ($att{'R3'} eq '-') { 
            return 'i'; # unique at depth 5
          } 
          return 'j';
        } 
        if ($att{'L2'} eq 'B') { 
          return 'i'; # unique at depth 4
        } 
        if ($att{'L2'} eq 'L') { 
          if ($att{'L3'} eq 'I') { 
            return 'i'; # unique at depth 5
          } 
          return 'j';
        } 
        return 'j';
      } 
      if ($att{'L1'} eq 'H') { 
        if ($att{'L3'} eq '-') { 
          return 'j'; # unique at depth 4
        } 
        return 'i';
      } 
      if ($att{'L1'} eq 'N') { 
        if ($att{'R2'} eq 'N') { 
          return 'j'; # unique at depth 4
        } 
        if ($att{'R2'} eq '2') { 
          if ($att{'L3'} eq 'R') { 
            return '_'; # unique at depth 5
          } 
          return 'j';
        } 
        if ($att{'R2'} eq 'R') { 
          return 'j'; # unique at depth 4
        } 
        return 'i';
      } 
      return 'j';
    } 
    if ($att{'R1'} eq 'S') { 
      if ($att{'L1'} eq 'A') { 
        if ($att{'L2'} eq 'R') { 
          if ($att{'R3'} eq 'S') { 
            return '_'; # unique at depth 5
          } 
          return 'E';
        } 
        if ($att{'L2'} eq 'I') { 
          return 'j'; # unique at depth 4
        } 
        if ($att{'L2'} eq 'P') { 
          if ($att{'L3'} eq '-') { 
            return 'e'; # unique at depth 5
          } 
          return 'E';
        } 
        if ($att{'L2'} eq 'G') { 
          return '_'; # unique at depth 4
        } 
        if ($att{'L2'} eq 'L') { 
          if ($att{'R3'} eq 'S') { 
            return '_'; # unique at depth 5
          } 
          return 'E';
        } 
        if ($att{'L2'} eq 'E') { 
          return '_'; # unique at depth 4
        } 
        if ($att{'L2'} eq 'S') { 
          if ($att{'R3'} eq '-') { 
            return 'E'; # unique at depth 5
          } 
          if ($att{'R3'} eq 'R') { 
            return '_'; # unique at depth 5
          } 
          return 'e';
        } 
        if ($att{'L2'} eq 'T') { 
          if ($att{'L3'} eq 'T') { 
            return '_'; # unique at depth 5
          } 
          return 'E';
        } 
        return 'E';
      } 
      if ($att{'L1'} eq 'X') { 
        if ($att{'R3'} eq 'E') { 
          if ($att{'R2'} eq 'T') { 
            if ($att{'L2'} eq 'E') { 
              if ($att{'L3'} eq '-') { 
                return '_'; # depth limit (1/2; 2 classes) at depth 7
              } 
              return 'z';
            } 
            return '_';
          } 
          return '_';
        } 
        if ($att{'R3'} eq '-') { 
          return 's'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'L1'} eq 'T') { 
        if ($att{'L3'} eq 'I') { 
          return 't'; # unique at depth 4
        } 
        return 'i';
      } 
      if ($att{'L1'} eq 'O') { 
        if ($att{'R2'} eq 'S') { 
          return '_'; # unique at depth 4
        } 
        if ($att{'R2'} eq '-') { 
          return '_'; # unique at depth 4
        } 
        if ($att{'R2'} eq 'A') { 
          if ($att{'R3'} eq '-') { 
            return 'a'; # unique at depth 5
          } 
          return '_';
        } 
        return 'a';
      } 
      return 'i';
    } 
    if ($att{'R1'} eq 'M') { 
      if ($att{'R2'} eq 'I') { 
        if ($att{'L1'} eq 'A') { 
          return 'E'; # unique at depth 4
        } 
        return 'i';
      } 
      if ($att{'R2'} eq 'O') { 
        return 'E'; # unique at depth 3
      } 
      if ($att{'R2'} eq 'B') { 
        return 'E~'; # unique at depth 3
      } 
      if ($att{'R2'} eq 'P') { 
        return 'E~'; # unique at depth 3
      } 
      if ($att{'R2'} eq 'A') { 
        if ($att{'R3'} eq 'I') { 
          if ($att{'L3'} eq 'X') { 
            return 's'; # unique at depth 5
          } 
          return 'i';
        } 
        if ($att{'R3'} eq 'B') { 
          if ($att{'L3'} eq 'X') { 
            return 'R'; # unique at depth 5
          } 
          return 'E';
        } 
        return 'i';
      } 
      if ($att{'R2'} eq 'E') { 
        if ($att{'L1'} eq 'R') { 
          if ($att{'L3'} eq 'X') { 
            return 'R'; # unique at depth 5
          } 
          return 'i';
        } 
        if ($att{'L1'} eq 'A') { 
          return 'E'; # unique at depth 4
        } 
        return 'i';
      } 
      return 'i';
    } 
    if ($att{'R1'} eq 'D') { 
      if ($att{'L1'} eq 'O') { 
        return '_'; # unique at depth 3
      } 
      if ($att{'L1'} eq 'A') { 
        return 'E'; # unique at depth 3
      } 
      return 'i';
    } 
    if ($att{'R1'} eq 'T') { 
      if ($att{'L1'} eq 'F') { 
        return 'i'; # unique at depth 3
      } 
      if ($att{'L1'} eq 'B') { 
        return 'i'; # unique at depth 3
      } 
      if ($att{'L1'} eq 'C') { 
        return 'i'; # unique at depth 3
      } 
      if ($att{'L1'} eq 'T') { 
        if ($att{'L2'} eq 'C') { 
          return 't'; # unique at depth 4
        } 
        return 'i';
      } 
      if ($att{'L1'} eq 'M') { 
        return 'i'; # unique at depth 3
      } 
      if ($att{'L1'} eq 'S') { 
        return 'i'; # unique at depth 3
      } 
      if ($att{'L1'} eq 'U') { 
        return 'i'; # unique at depth 3
      } 
      if ($att{'L1'} eq '-') { 
        return 'i'; # unique at depth 3
      } 
      if ($att{'L1'} eq 'V') { 
        return 'i'; # unique at depth 3
      } 
      if ($att{'L1'} eq 'O') { 
        if ($att{'R2'} eq 'S') { 
          if ($att{'L3'} eq 'P') { 
            return 'w'; # unique at depth 5
          } 
          return '_';
        } 
        if ($att{'R2'} eq '-') { 
          return '_'; # unique at depth 4
        } 
        if ($att{'R2'} eq 'A') { 
          return 'w'; # unique at depth 4
        } 
        return 'a';
      } 
      if ($att{'L1'} eq 'P') { 
        return 'i'; # unique at depth 3
      } 
      if ($att{'L1'} eq 'X') { 
        return 's'; # unique at depth 3
      } 
      if ($att{'L1'} eq 'R') { 
        return 'i'; # unique at depth 3
      } 
      if ($att{'L1'} eq 'L') { 
        return 'i'; # unique at depth 3
      } 
      if ($att{'L1'} eq 'H') { 
        return 'i'; # unique at depth 3
      } 
      if ($att{'L1'} eq 'N') { 
        return 'i'; # unique at depth 3
      } 
      if ($att{'L1'} eq 'D') { 
        return 'i'; # unique at depth 3
      } 
      if ($att{'L1'} eq 'G') { 
        return 'i'; # unique at depth 3
      } 
      if ($att{'L1'} eq 'A') { 
        if ($att{'L2'} eq 'F') { 
          if ($att{'L3'} eq 'S') { 
            return 'E'; # unique at depth 5
          } 
          return '_';
        } 
        if ($att{'L2'} eq 'I') { 
          if ($att{'L3'} eq 'L') { 
            return 'j'; # unique at depth 5
          } 
          if ($att{'L3'} eq 'R') { 
            return 'j'; # unique at depth 5
          } 
          return '_';
        } 
        if ($att{'L2'} eq 'R') { 
          if ($att{'R2'} eq 'E') { 
            if ($att{'R3'} eq '-') { 
              if ($att{'L3'} eq 'T') { 
                return 'E'; # depth limit (1/2; 2 classes) at depth 7
              } 
              return 'e';
            } 
            return 'E';
          } 
          return '_';
        } 
        if ($att{'L2'} eq 'H') { 
          if ($att{'R2'} eq 'A') { 
            return 'E'; # unique at depth 5
          } 
          return '_';
        } 
        if ($att{'L2'} eq 'Y') { 
          if ($att{'L3'} eq 'A') { 
            return '_'; # unique at depth 5
          } 
          return 'j';
        } 
        if ($att{'L2'} eq 'T') { 
          if ($att{'L3'} eq 'L') { 
            return 't'; # unique at depth 5
          } 
          return '_';
        } 
        return '_';
      } 
      return '_';
    } 
    if ($att{'R1'} eq 'A') { 
      if ($att{'L2'} eq 'P') { 
        if ($att{'R2'} eq '-') { 
          return 'j'; # unique at depth 4
        } 
        return 'i';
      } 
      if ($att{'L2'} eq 'U') { 
        if ($att{'L1'} eq 'R') { 
          return 'i'; # unique at depth 4
        } 
        return 'j';
      } 
      if ($att{'L2'} eq 'B') { 
        if ($att{'R2'} eq '-') { 
          return 'j'; # unique at depth 4
        } 
        return 'i';
      } 
      if ($att{'L2'} eq 'C') { 
        if ($att{'L3'} eq 'Y') { 
          return 'j'; # unique at depth 4
        } 
        return 'i';
      } 
      if ($att{'L2'} eq 'T') { 
        return 'i'; # unique at depth 3
      } 
      return 'j';
    } 
    if ($att{'R1'} eq 'G') { 
      if ($att{'L1'} eq 'O') { 
        return '_'; # unique at depth 3
      } 
      if ($att{'L1'} eq 'A') { 
        if ($att{'R2'} eq 'U') { 
          return 'e'; # unique at depth 4
        } 
        return 'E';
      } 
      if ($att{'L1'} eq 'E') { 
        return '_'; # unique at depth 3
      } 
      if ($att{'L1'} eq 'X') { 
        return 'z'; # unique at depth 3
      } 
      return 'i';
    } 
    if ($att{'R1'} eq 'U') { 
      return 'j'; # unique at depth 2
    } 
    if ($att{'R1'} eq 'O') { 
      if ($att{'L1'} eq 'V') { 
        if ($att{'L3'} eq 'D') { 
          return '_'; # unique at depth 4
        } 
        if ($att{'L3'} eq 'V') { 
          return '_'; # unique at depth 4
        } 
        if ($att{'L3'} eq 'O') { 
          return '_'; # unique at depth 4
        } 
        return 'j';
      } 
      if ($att{'L1'} eq 'T') { 
        if ($att{'R3'} eq 'S') { 
          if ($att{'L2'} eq 'S') { 
            return '_'; # unique at depth 5
          } 
          return 's';
        } 
        if ($att{'R3'} eq 'A') { 
          return 'j'; # unique at depth 4
        } 
        if ($att{'R3'} eq 'N') { 
          return 'j'; # unique at depth 4
        } 
        return 's';
      } 
      if ($att{'L1'} eq 'M') { 
        if ($att{'L3'} eq 'C') { 
          return 'j'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'L1'} eq 'S') { 
        if ($att{'R3'} eq 'S') { 
          if ($att{'L2'} eq 'O') { 
            if ($att{'L3'} eq '-') { 
              return '_'; # unique at depth 6
            } 
            return 'z';
          } 
          return '_';
        } 
        if ($att{'R3'} eq 'N') { 
          return 'j'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'L1'} eq 'K') { 
        return 'j'; # unique at depth 3
      } 
      if ($att{'L1'} eq 'G') { 
        return '_'; # unique at depth 3
      } 
      if ($att{'L1'} eq 'H') { 
        return '_'; # unique at depth 3
      } 
      if ($att{'L1'} eq 'L') { 
        return '_'; # unique at depth 3
      } 
      if ($att{'L1'} eq 'N') { 
        return '_'; # unique at depth 3
      } 
      if ($att{'L1'} eq 'D') { 
        if ($att{'R2'} eq 'C') { 
          return 'j'; # unique at depth 4
        } 
        if ($att{'R2'} eq 'S') { 
          return 'j'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'L1'} eq 'Y') { 
        return 'j'; # unique at depth 3
      } 
      if ($att{'L1'} eq 'R') { 
        if ($att{'L2'} eq 'T') { 
          return 'i'; # unique at depth 4
        } 
        return 'j';
      } 
      if ($att{'L1'} eq 'P') { 
        if ($att{'L3'} eq '-') { 
          return 'j'; # unique at depth 4
        } 
        return '_';
      } 
      return 's';
    } 
    if ($att{'R1'} eq 'V') { 
      if ($att{'L1'} eq 'O') { 
        return 'a'; # unique at depth 3
      } 
      if ($att{'L1'} eq 'S') { 
        if ($att{'L3'} eq 'L') { 
          return 'z'; # unique at depth 4
        } 
        return 'i';
      } 
      return 'i';
    } 
    if ($att{'R1'} eq '-') { 
      if ($att{'L1'} eq 'O') { 
        return 'a'; # unique at depth 3
      } 
      if ($att{'L1'} eq 'A') { 
        if ($att{'L3'} eq 'R') { 
          if ($att{'L2'} eq 'R') { 
            return '_'; # unique at depth 5
          } 
          return 'e';
        } 
        if ($att{'L3'} eq 'S') { 
          return '_'; # unique at depth 4
        } 
        if ($att{'L3'} eq 'V') { 
          return 'E'; # unique at depth 4
        } 
        if ($att{'L3'} eq '1') { 
          return 'E'; # unique at depth 4
        } 
        return 'e';
      } 
      return 'i';
    } 
    return 'i';
  } 
  if ($att{'L'} eq 'R') { 
    if ($att{'L1'} eq 'O') { 
      if ($att{'L2'} eq 'X') { 
        return 'O'; # unique at depth 3
      } 
      if ($att{'L2'} eq 'A') { 
        return 'O'; # unique at depth 3
      } 
      if ($att{'L2'} eq 'H') { 
        if ($att{'R3'} eq 'U') { 
          return '_'; # unique at depth 4
        } 
        if ($att{'R3'} eq 'B') { 
          if ($att{'R2'} eq 'I') { 
            if ($att{'R1'} eq 'R') { 
              return '_';
            } 
            return 'R';
          } 
          return '_';
        } 
        return 'R';
      } 
      if ($att{'L2'} eq 'L') { 
        if ($att{'L3'} eq 'P') { 
          return 'O'; # unique at depth 4
        } 
        return 'R';
      } 
      return 'R';
    } 
    if ($att{'L1'} eq 'T') { 
      if ($att{'L2'} eq 'X') { 
        return 't'; # unique at depth 3
      } 
      return 'R';
    } 
    if ($att{'L1'} eq 'A') { 
      if ($att{'R1'} eq 'R') { 
        if ($att{'L3'} eq 'C') { 
          if ($att{'R2'} eq 'U') { 
            return '_'; # unique at depth 5
          } 
          return 'R';
        } 
        if ($att{'L3'} eq '1') { 
          return '_'; # unique at depth 4
        } 
        return 'R';
      } 
      return 'R';
    } 
    if ($att{'L1'} eq 'E') { 
      if ($att{'R1'} eq '-') { 
        if ($att{'L3'} eq 'R') { 
          if ($att{'L2'} eq 'I') { 
            if ($att{'R3'} eq '-') { 
              if ($att{'R2'} eq '-') { 
                return 'e'; # depth limit (2/4; 2 classes) at depth 7
              } 
              return '_';
            } 
            return '_';
          } 
          return '_';
        } 
        if ($att{'L3'} eq 'T') { 
          if ($att{'L2'} eq 'H') { 
            return 'R'; # unique at depth 5
          } 
          return '_';
        } 
        if ($att{'L3'} eq 'O') { 
          if ($att{'L2'} eq 'R') { 
            if ($att{'R3'} eq '-') { 
              if ($att{'R2'} eq '-') { 
                return '_'; # depth limit (1/2; 2 classes) at depth 7
              } 
              return 'e';
            } 
            return '_';
          } 
          if ($att{'L2'} eq 'Y') { 
            return 'e'; # unique at depth 5
          } 
          return '_';
        } 
        if ($att{'L3'} eq '-') { 
          return 'R'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'R1'} eq 'V') { 
        return 'R'; # unique at depth 3
      } 
      if ($att{'R1'} eq 'O') { 
        return 'R'; # unique at depth 3
      } 
      if ($att{'R1'} eq 'B') { 
        return 'R'; # unique at depth 3
      } 
      if ($att{'R1'} eq 'C') { 
        if ($att{'L2'} eq 'X') { 
          return 'E'; # unique at depth 4
        } 
        return 'R';
      } 
      if ($att{'R1'} eq 'T') { 
        return 'R'; # unique at depth 3
      } 
      if ($att{'R1'} eq 'M') { 
        return 'R'; # unique at depth 3
      } 
      if ($att{'R1'} eq 'S') { 
        if ($att{'L2'} eq 'I') { 
          return '_';
        } 
        if ($att{'L2'} eq 'G') { 
          return '_'; # unique at depth 4
        } 
        if ($att{'L2'} eq 'L') { 
          return '_'; # unique at depth 4
        } 
        return 'R';
      } 
      if ($att{'R1'} eq 'I') { 
        return 'R'; # unique at depth 3
      } 
      if ($att{'R1'} eq 'F') { 
        return 'R'; # unique at depth 3
      } 
      if ($att{'R1'} eq 'G') { 
        return 'R'; # unique at depth 3
      } 
      if ($att{'R1'} eq 'A') { 
        return 'R'; # unique at depth 3
      } 
      if ($att{'R1'} eq 'L') { 
        return 'R'; # unique at depth 3
      } 
      if ($att{'R1'} eq 'N') { 
        return 'R'; # unique at depth 3
      } 
      if ($att{'R1'} eq 'D') { 
        return 'R'; # unique at depth 3
      } 
      if ($att{'R1'} eq 'E') { 
        return 'R'; # unique at depth 3
      } 
      if ($att{'R1'} eq 'R') { 
        if ($att{'R3'} eq 'M') { 
          return '_';
        } 
        if ($att{'R3'} eq 'I') { 
          if ($att{'L2'} eq 'V') { 
            if ($att{'L3'} eq 'E') { 
              return 'R'; # unique at depth 6
            } 
            return '_';
          } 
          return 'R';
        } 
        if ($att{'R3'} eq 'E') { 
          if ($att{'L3'} eq '-') { 
            return '_'; # unique at depth 5
          } 
          return 'R';
        } 
        if ($att{'R3'} eq 'N') { 
          return '_'; # unique at depth 4
        } 
        if ($att{'R3'} eq 'R') { 
          if ($att{'L3'} eq 'N') { 
            return '_'; # unique at depth 5
          } 
          return 'R';
        } 
        if ($att{'R3'} eq 'P') { 
          return '_'; # unique at depth 4
        } 
        return 'R';
      } 
      if ($att{'R1'} eq 'P') { 
        return 'R'; # unique at depth 3
      } 
      return '_';
    } 
    if ($att{'L1'} eq 'R') { 
      if ($att{'L3'} eq 'B') { 
        if ($att{'R3'} eq 'S') { 
          return 'R'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'L3'} eq 'H') { 
        if ($att{'R3'} eq 'T') { 
          return '_'; # unique at depth 4
        } 
        if ($att{'R3'} eq 'L') { 
          if ($att{'R2'} eq 'B') { 
            if ($att{'R1'} eq 'I') { 
              return 'R';
            } 
            return '_';
          } 
          return '_';
        } 
        return 'R';
      } 
      if ($att{'L3'} eq 'T') { 
        if ($att{'R2'} eq 'M') { 
          return 'R';
        } 
        if ($att{'R2'} eq 'G') { 
          if ($att{'R3'} eq 'A') { 
            if ($att{'R1'} eq 'O') { 
              if ($att{'L2'} eq 'E') { 
                return 'R'; # depth limit (1/2; 2 classes) at depth 7
              } 
              return '_';
            } 
            return 'R';
          } 
          return '_';
        } 
        if ($att{'R2'} eq 'R') { 
          return 'R'; # unique at depth 4
        } 
        if ($att{'R2'} eq 'P') { 
          return 'R'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'L3'} eq 'V') { 
        if ($att{'R3'} eq '-') { 
          if ($att{'R1'} eq 'O') { 
            return '_'; # unique at depth 5
          } 
          return 'e';
        } 
        return 'R';
      } 
      if ($att{'L3'} eq 'O') { 
        if ($att{'R1'} eq 'A') { 
          return 'R'; # unique at depth 4
        } 
        return '_';
      } 
      return '_';
    } 
    if ($att{'L1'} eq 'P') { 
      if ($att{'L2'} eq 'X') { 
        if ($att{'R3'} eq 'A') { 
          if ($att{'R2'} eq 'M') { 
            if ($att{'R1'} eq 'I') { 
              return 'p';
            } 
            return '_';
          } 
          return '_';
        } 
        return 'p';
      } 
      return 'R';
    } 
    return 'R';
  } 
  if ($att{'L'} eq 'F') { 
    if ($att{'L1'} eq 'U') { 
      if ($att{'L3'} eq 'H') { 
        if ($att{'R3'} eq 'R') { 
          if ($att{'R2'} eq 'E') { 
            if ($att{'R1'} eq 'F') { 
              return '_';
            } 
            return 'O';
          } 
          return '_';
        } 
        return '_';
      } 
      if ($att{'L3'} eq 'S') { 
        return '_';
      } 
      return 'f';
    } 
    if ($att{'L1'} eq 'O') { 
      if ($att{'R2'} eq 'I') { 
        if ($att{'R3'} eq 'C') { 
          if ($att{'R1'} eq 'F') { 
            if ($att{'L2'} eq '-') { 
              return '_';
            } 
            return 'f';
          } 
          return 'f';
        } 
        return 'f';
      } 
      if ($att{'R2'} eq 'R') { 
        return '_'; # unique at depth 3
      } 
      if ($att{'R2'} eq 'E') { 
        return '_'; # unique at depth 3
      } 
      return 'f';
    } 
    if ($att{'L1'} eq 'I') { 
      if ($att{'R3'} eq 'N') { 
        return '_'; # unique at depth 3
      } 
      if ($att{'R3'} eq '1') { 
        if ($att{'L3'} eq 'N') { 
          return '_'; # unique at depth 4
        } 
        return 'f';
      } 
      return 'f';
    } 
    if ($att{'L1'} eq 'F') { 
      if ($att{'R3'} eq 'R') { 
        if ($att{'R2'} eq '1') { 
          if ($att{'R1'} eq 'E') { 
            return 'f';
          } 
          return '_';
        } 
        if ($att{'R2'} eq 'U') { 
          return 'f'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'R3'} eq 'E') { 
        if ($att{'L3'} eq 'S') { 
          return '_'; # unique at depth 4
        } 
        return 'f';
      } 
      if ($att{'R3'} eq 'N') { 
        return 'f'; # unique at depth 3
      } 
      if ($att{'R3'} eq 'I') { 
        if ($att{'R1'} eq 'R') { 
          return 'f'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'R3'} eq '1') { 
        if ($att{'R2'} eq 'E') { 
          if ($att{'R1'} eq 'L') { 
            if ($att{'L2'} eq 'U') { 
              if ($att{'L3'} eq 'O') { 
                return '_'; # depth limit (1/2; 2 classes) at depth 7
              } 
              return 'f';
            } 
            return 'f';
          } 
          return '_';
        } 
        return '_';
      } 
      if ($att{'R3'} eq '-') { 
        if ($att{'L3'} eq '-') { 
          return 'f'; # unique at depth 4
        } 
        if ($att{'L3'} eq 'H') { 
          return 'f'; # unique at depth 4
        } 
        if ($att{'L3'} eq 'A') { 
          return 'f'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'R3'} eq 'S') { 
        return 'f'; # unique at depth 3
      } 
      return '_';
    } 
    return 'f';
  } 
  if ($att{'L'} eq 'Z') { 
    if ($att{'L1'} eq 'A') { 
      if ($att{'L2'} eq 'J') { 
        return 'a'; # unique at depth 3
      } 
      return 'z';
    } 
    if ($att{'L1'} eq 'N') { 
      return 'z'; # unique at depth 2
    } 
    if ($att{'L1'} eq 'Z') { 
      return 'z'; # unique at depth 2
    } 
    if ($att{'L1'} eq '-') { 
      return 'z'; # unique at depth 2
    } 
    if ($att{'L1'} eq '1') { 
      return 'z'; # unique at depth 2
    } 
    if ($att{'L1'} eq 'I') { 
      return 'z'; # unique at depth 2
    } 
    return 'e';
  } 
  if ($att{'L'} eq '3') { 
    if ($att{'L1'} eq 'A') { 
      if ($att{'L2'} eq 'P') { 
        if ($att{'R3'} eq 'T') { 
          return '_'; # unique at depth 4
        } 
        return 'A';
      } 
      if ($att{'L2'} eq 'H') { 
        if ($att{'R3'} eq 'V') { 
          return '_'; # unique at depth 4
        } 
        return 'A';
      } 
      if ($att{'L2'} eq 'L') { 
        return '_'; # unique at depth 3
      } 
      if ($att{'L2'} eq 'N') { 
        if ($att{'L3'} eq 'U') { 
          return 'A'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'L2'} eq 'D') { 
        return '_'; # unique at depth 3
      } 
      if ($att{'L2'} eq 'G') { 
        if ($att{'L3'} eq '1') { 
          return '_'; # unique at depth 4
        } 
        return 'A';
      } 
      if ($att{'L2'} eq 'T') { 
        if ($att{'R3'} eq '-') { 
          return '_'; # unique at depth 4
        } 
        if ($att{'R3'} eq 'E') { 
          return '_'; # unique at depth 4
        } 
        return 'A';
      } 
      if ($att{'L2'} eq 'S') { 
        if ($att{'L3'} eq 'S') { 
          return '_'; # unique at depth 4
        } 
        return 'A';
      } 
      if ($att{'L2'} eq 'U') { 
        return '_'; # unique at depth 3
      } 
      if ($att{'L2'} eq '-') { 
        if ($att{'R1'} eq 'T') { 
          return 'A'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'L2'} eq 'V') { 
        return '_'; # unique at depth 3
      } 
      return 'A';
    } 
    if ($att{'L1'} eq 'E') { 
      if ($att{'R3'} eq 'R') { 
        return '_'; # unique at depth 3
      } 
      if ($att{'R3'} eq 'N') { 
        if ($att{'R1'} eq 'L') { 
          if ($att{'R2'} eq 'A') { 
            return '_'; # unique at depth 5
          } 
          return 'E';
        } 
        if ($att{'R1'} eq 'T') { 
          return '_'; # unique at depth 4
        } 
        return 'E';
      } 
      if ($att{'R3'} eq 'I') { 
        if ($att{'L3'} eq 'P') { 
          return '_'; # unique at depth 4
        } 
        return 'E';
      } 
      if ($att{'R3'} eq '1') { 
        if ($att{'R1'} eq 'L') { 
          if ($att{'R2'} eq 'E') { 
            if ($att{'L2'} eq 'M') { 
              if ($att{'L3'} eq '-') { 
                return 'E'; # depth limit (1/2; 2 classes) at depth 7
              } 
              return '_';
            } 
            return '_';
          } 
          return 'E';
        } 
        return '_';
      } 
      if ($att{'R3'} eq '-') { 
        if ($att{'R2'} eq 'S') { 
          return '_'; # unique at depth 4
        } 
        return 'E';
      } 
      return 'E';
    } 
    if ($att{'L1'} eq 'I') { 
      if ($att{'R3'} eq 'E') { 
        if ($att{'L3'} eq 'L') { 
          return '_'; # unique at depth 4
        } 
        return 'E';
      } 
      if ($att{'R3'} eq 'N') { 
        if ($att{'R2'} eq 'E') { 
          return 'E'; # unique at depth 4
        } 
        return 'e';
      } 
      if ($att{'R3'} eq 'I') { 
        if ($att{'R2'} eq 'R') { 
          if ($att{'R1'} eq 'T') { 
            return 'e';
          } 
          return 'E';
        } 
        return 'E';
      } 
      if ($att{'R3'} eq '1') { 
        if ($att{'L2'} eq 'D') { 
          return '_'; # unique at depth 4
        } 
        return 'e';
      } 
      if ($att{'R3'} eq '-') { 
        if ($att{'L3'} eq 'F') { 
          return 'E'; # unique at depth 4
        } 
        if ($att{'L3'} eq 'R') { 
          return 'E'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'R3'} eq 'M') { 
        return 'E'; # unique at depth 3
      } 
      return '_';
    } 
    return '_';
  } 
  if ($att{'L'} eq 'X') { 
    if ($att{'L2'} eq 'L') { 
      if ($att{'L1'} eq 'U') { 
        return '_'; # unique at depth 3
      } 
      return 'k';
    } 
    if ($att{'L2'} eq 'N') { 
      if ($att{'R1'} eq 'O') { 
        return 'g'; # unique at depth 3
      } 
      return 'k';
    } 
    if ($att{'L2'} eq 'D') { 
      return 'z'; # unique at depth 2
    } 
    if ($att{'L2'} eq 'E') { 
      return '2'; # unique at depth 2
    } 
    if ($att{'L2'} eq 'A') { 
      if ($att{'L3'} eq '-') { 
        return 'k'; # unique at depth 3
      } 
      if ($att{'L3'} eq 'I') { 
        if ($att{'R3'} eq '-') { 
          if ($att{'R2'} eq '-') { 
            if ($att{'R1'} eq '-') { 
              if ($att{'L1'} eq 'U') { 
                return 'O'; # depth limit (1/2; 2 classes) at depth 7
              } 
              return 'o';
            } 
            return 'o';
          } 
          return 'O';
        } 
        return 'O';
      } 
      if ($att{'L3'} eq 'P') { 
        return 'O'; # unique at depth 3
      } 
      return 'o';
    } 
    if ($att{'L2'} eq 'F') { 
      if ($att{'L3'} eq 'I') { 
        return '_'; # unique at depth 3
      } 
      return 'k';
    } 
    if ($att{'L2'} eq 'S') { 
      return '_'; # unique at depth 2
    } 
    if ($att{'L2'} eq '-') { 
      if ($att{'R1'} eq 'E') { 
        if ($att{'L1'} eq 'A') { 
          return 'k'; # unique at depth 4
        } 
        return 'g';
      } 
      if ($att{'R1'} eq 'A') { 
        return 'g'; # unique at depth 3
      } 
      if ($att{'R1'} eq 'I') { 
        return 'g'; # unique at depth 3
      } 
      return 'k';
    } 
    if ($att{'L2'} eq 'O') { 
      return '_'; # unique at depth 2
    } 
    return 'k';
  } 
  if ($att{'L'} eq 'e') { 
    return 'lex0.txt...'; # unique at depth 1
  } 
  if ($att{'L'} eq 'C') { 
    if ($att{'R1'} eq 'T') { 
      if ($att{'L2'} eq 'P') { 
        if ($att{'R2'} eq 'S') { 
          return '_'; # unique at depth 4
        } 
        return 'k';
      } 
      if ($att{'L2'} eq 'X') { 
        return 'a'; # unique at depth 3
      } 
      if ($att{'L2'} eq 'I') { 
        if ($att{'R2'} eq 'I') { 
          return 'k'; # unique at depth 4
        } 
        return '_';
      } 
      return 'k';
    } 
    if ($att{'R1'} eq 'S') { 
      if ($att{'L2'} eq 'R') { 
        if ($att{'L3'} eq 'G') { 
          return 'k'; # unique at depth 4
        } 
        return '_';
      } 
      return 'k';
    } 
    if ($att{'R1'} eq '-') { 
      if ($att{'L3'} eq 'M') { 
        return '_'; # unique at depth 3
      } 
      if ($att{'L3'} eq 'P') { 
        return '_'; # unique at depth 3
      } 
      if ($att{'L3'} eq 'L') { 
        return '_'; # unique at depth 3
      } 
      return 'k';
    } 
    if ($att{'R1'} eq 'O') { 
      if ($att{'L1'} eq 'E') { 
        if ($att{'R3'} eq 'D') { 
          return '_'; # unique at depth 4
        } 
        return 'k';
      } 
      if ($att{'L1'} eq 'C') { 
        return '_'; # unique at depth 3
      } 
      return 'k';
    } 
    if ($att{'R1'} eq 'U') { 
      if ($att{'L1'} eq 'X') { 
        return 's'; # unique at depth 3
      } 
      if ($att{'L1'} eq 'C') { 
        return '_'; # unique at depth 3
      } 
      return 'k';
    } 
    if ($att{'R1'} eq '5') { 
      if ($att{'L3'} eq 'X') { 
        return 'R'; # unique at depth 3
      } 
      return '_';
    } 
    if ($att{'R1'} eq 'K') { 
      return '_'; # unique at depth 2
    } 
    if ($att{'R1'} eq 'I') { 
      if ($att{'L1'} eq 'S') { 
        return '_'; # unique at depth 3
      } 
      return 's';
    } 
    if ($att{'R1'} eq 'Y') { 
      return 's'; # unique at depth 2
    } 
    if ($att{'R1'} eq 'E') { 
      if ($att{'R2'} eq 'S') { 
        if ($att{'R3'} eq 'S') { 
          return 's'; # unique at depth 4
        } 
        if ($att{'R3'} eq '-') { 
          if ($att{'L2'} eq '-') { 
            return 's'; # unique at depth 5
          } 
          return '_';
        } 
        return '_';
      } 
      if ($att{'R2'} eq '-') { 
        if ($att{'L3'} eq 'X') { 
          return 'R'; # unique at depth 4
        } 
        return 's';
      } 
      if ($att{'R2'} eq '2') { 
        if ($att{'L3'} eq 'O') { 
          return '_'; # unique at depth 4
        } 
        return 's';
      } 
      if ($att{'R2'} eq 'N') { 
        if ($att{'L3'} eq 'L') { 
          return '_'; # unique at depth 4
        } 
        if ($att{'L3'} eq 'D') { 
          return '_'; # unique at depth 4
        } 
        return 's';
      } 
      if ($att{'R2'} eq 'A') { 
        if ($att{'L3'} eq 'A') { 
          return '_'; # unique at depth 4
        } 
        return 's';
      } 
      if ($att{'R2'} eq 'P') { 
        if ($att{'L2'} eq '-') { 
          return '_'; # unique at depth 4
        } 
        if ($att{'L2'} eq 'U') { 
          return '_'; # unique at depth 4
        } 
        return 's';
      } 
      if ($att{'R2'} eq 'R') { 
        if ($att{'L3'} eq 'D') { 
          return '_'; # unique at depth 4
        } 
        return 's';
      } 
      return 's';
    } 
    if ($att{'R1'} eq 'H') { 
      if ($att{'R2'} eq '-') { 
        if ($att{'L3'} eq 'D') { 
          return 't'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'R2'} eq 'O') { 
        if ($att{'L3'} eq 'P') { 
          return 'k'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'R2'} eq 'I') { 
        if ($att{'L3'} eq 'P') { 
          return 'k'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'R2'} eq 'E') { 
        if ($att{'L3'} eq 'G') { 
          if ($att{'L1'} eq 'U') { 
            return 'O'; # unique at depth 5
          } 
          return '_';
        } 
        return '_';
      } 
      if ($att{'R2'} eq 'N') { 
        return 'k'; # unique at depth 3
      } 
      if ($att{'R2'} eq 'A') { 
        if ($att{'R3'} eq 'O') { 
          return 'k'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'R2'} eq 'R') { 
        return 'k'; # unique at depth 3
      } 
      return '_';
    } 
    if ($att{'R1'} eq 'L') { 
      if ($att{'L1'} eq 'X') { 
        return 's'; # unique at depth 3
      } 
      if ($att{'L1'} eq '-') { 
        if ($att{'R3'} eq 'R') { 
          if ($att{'R2'} eq 'E') { 
            return 'k'; # unique at depth 5
          } 
          return 'c';
        } 
        return 'k';
      } 
      return 'k';
    } 
    if ($att{'R1'} eq 'A') { 
      if ($att{'L1'} eq 'C') { 
        return '_'; # unique at depth 3
      } 
      return 'k';
    } 
    if ($att{'R1'} eq 'R') { 
      if ($att{'L2'} eq 'A') { 
        return '_'; # unique at depth 3
      } 
      return 'k';
    } 
    return 'k';
  } 
  if ($att{'L'} eq 'D') { 
    if ($att{'R1'} eq 'I') { 
      if ($att{'L1'} eq 'R') { 
        if ($att{'L3'} eq 'A') { 
          return 'R'; # unique at depth 4
        } 
        return 'd';
      } 
      if ($att{'L1'} eq 'D') { 
        return '_'; # unique at depth 3
      } 
      return 'd';
    } 
    if ($att{'R1'} eq '-') { 
      if ($att{'L3'} eq 'L') { 
        if ($att{'L2'} eq 'O') { 
          return 'd'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'L3'} eq 'B') { 
        return 'd'; # unique at depth 3
      } 
      return '_';
    } 
    if ($att{'R1'} eq 'S') { 
      if ($att{'L1'} eq 'I') { 
        return 'a'; # unique at depth 3
      } 
      return '_';
    } 
    return 'd';
  } 
  if ($att{'L'} eq 'T') { 
    if ($att{'R1'} eq 'R') { 
      if ($att{'L1'} eq 'X') { 
        return 's'; # unique at depth 3
      } 
      if ($att{'L1'} eq 'T') { 
        if ($att{'L3'} eq '-') { 
          return '_'; # unique at depth 4
        } 
        if ($att{'L3'} eq 'B') { 
          return '_'; # unique at depth 4
        } 
        return 't';
      } 
      return 't';
    } 
    if ($att{'R1'} eq 'A') { 
      if ($att{'L1'} eq 'L') { 
        if ($att{'L3'} eq 'X') { 
          return '_'; # unique at depth 4
        } 
        return 't';
      } 
      if ($att{'L1'} eq 'I') { 
        if ($att{'L3'} eq 'L') { 
          return 'a'; # unique at depth 4
        } 
        return 't';
      } 
      if ($att{'L1'} eq 'T') { 
        if ($att{'L3'} eq 'L') { 
          if ($att{'L2'} eq 'A') { 
            return '_'; # unique at depth 5
          } 
          return 'E';
        } 
        if ($att{'L3'} eq 'R') { 
          if ($att{'R2'} eq '-') { 
            if ($att{'L2'} eq 'E') { 
              return 't'; # unique at depth 6
            } 
            return '_';
          } 
          if ($att{'R2'} eq 'I') { 
            if ($att{'L2'} eq 'O') { 
              return 'E'; # unique at depth 6
            } 
            return '_';
          } 
          if ($att{'R2'} eq 'N') { 
            return 'A~'; # unique at depth 5
          } 
          return '_';
        } 
        if ($att{'L3'} eq 'U') { 
          if ($att{'R3'} eq 'E') { 
            return 'E'; # unique at depth 5
          } 
          if ($att{'R3'} eq '-') { 
            return '_'; # unique at depth 5
          } 
          return 'A~';
        } 
        if ($att{'L3'} eq 'B') { 
          if ($att{'R2'} eq 'N') { 
            if ($att{'R3'} eq 'T') { 
              if ($att{'L2'} eq 'A') { 
                return 't'; # depth limit (1/2; 2 classes) at depth 7
              } 
              return '_';
            } 
            return '_';
          } 
          return 'E';
        } 
        if ($att{'L3'} eq 'M') { 
          if ($att{'R3'} eq 'S') { 
            return 'E'; # unique at depth 5
          } 
          return 't';
        } 
        return '_';
      } 
      if ($att{'L1'} eq 'S') { 
        if ($att{'L3'} eq 'X') { 
          return '_'; # unique at depth 4
        } 
        return 't';
      } 
      return 't';
    } 
    if ($att{'R1'} eq 'E') { 
      if ($att{'L1'} eq 'A') { 
        if ($att{'R2'} eq 'N') { 
          return '_'; # unique at depth 4
        } 
        return 't';
      } 
      if ($att{'L1'} eq 'N') { 
        if ($att{'L3'} eq 'H') { 
          if ($att{'R2'} eq 'N') { 
            return 'A~'; # unique at depth 5
          } 
          return 't';
        } 
        return 't';
      } 
      if ($att{'L1'} eq 'X') { 
        return 's'; # unique at depth 3
      } 
      if ($att{'L1'} eq 'P') { 
        if ($att{'R2'} eq 'N') { 
          return '_'; # unique at depth 4
        } 
        return 't';
      } 
      if ($att{'L1'} eq 'S') { 
        if ($att{'L3'} eq 'X') { 
          if ($att{'R2'} eq 'N') { 
            return 'i'; # unique at depth 5
          } 
          return 's';
        } 
        return 't';
      } 
      if ($att{'L1'} eq 'T') { 
        if ($att{'L2'} eq 'A') { 
          if ($att{'L3'} eq 'B') { 
            return 't'; # unique at depth 5
          } 
          if ($att{'L3'} eq '-') { 
            if ($att{'R2'} eq 'I') { 
              return '_'; # unique at depth 6
            } 
            return 'A~';
          } 
          if ($att{'L3'} eq 'N') { 
            return '_'; # unique at depth 5
          } 
          if ($att{'L3'} eq 'L') { 
            return '_'; # unique at depth 5
          } 
          if ($att{'L3'} eq 'R') { 
            if ($att{'R2'} eq 'R') { 
              return 't'; # unique at depth 6
            } 
            return '_';
          } 
          return 'A~';
        } 
        if ($att{'L2'} eq 'E') { 
          if ($att{'R2'} eq 'R') { 
            return '_'; # unique at depth 5
          } 
          if ($att{'R2'} eq 'N') { 
            if ($att{'L3'} eq 'J') { 
              return '_'; # unique at depth 6
            } 
            return 't';
          } 
          if ($att{'R2'} eq '1') { 
            return '_'; # unique at depth 5
          } 
          return 't';
        } 
        if ($att{'L2'} eq 'O') { 
          return '_'; # unique at depth 4
        } 
        if ($att{'L2'} eq 'U') { 
          return '_'; # unique at depth 4
        } 
        if ($att{'L2'} eq 'I') { 
          return '_'; # unique at depth 4
        } 
        return 't';
      } 
      if ($att{'L1'} eq 'I') { 
        if ($att{'L2'} eq 'X') { 
          return 'i'; # unique at depth 4
        } 
        if ($att{'L2'} eq 'B') { 
          if ($att{'R2'} eq 'N') { 
            return '_'; # unique at depth 5
          } 
          return 't';
        } 
        return 't';
      } 
      if ($att{'L1'} eq '3') { 
        if ($att{'R2'} eq 'N') { 
          return 'E'; # unique at depth 4
        } 
        return 't';
      } 
      return 't';
    } 
    if ($att{'R1'} eq 'I') { 
      if ($att{'R2'} eq 'R') { 
        if ($att{'L1'} eq 'T') { 
          return '_'; # unique at depth 4
        } 
        return 't';
      } 
      if ($att{'R2'} eq 'E') { 
        if ($att{'L2'} eq 'R') { 
          if ($att{'L3'} eq 'T') { 
            return 't'; # unique at depth 5
          } 
          if ($att{'L3'} eq '-') { 
            return 't'; # unique at depth 5
          } 
          return 's';
        } 
        if ($att{'L2'} eq 'P') { 
          return 's'; # unique at depth 4
        } 
        if ($att{'L2'} eq 'E') { 
          if ($att{'R3'} eq 'L') { 
            return 's'; # unique at depth 5
          } 
          if ($att{'R3'} eq '-') { 
            if ($att{'L3'} eq 'S') { 
              return 't'; # unique at depth 6
            } 
            return 's';
          } 
          return 't';
        } 
        if ($att{'L2'} eq 'N') { 
          return 's'; # unique at depth 4
        } 
        if ($att{'L2'} eq 'U') { 
          return '_'; # unique at depth 4
        } 
        if ($att{'L2'} eq 'B') { 
          return 's'; # unique at depth 4
        } 
        return 't';
      } 
      if ($att{'R2'} eq 'N') { 
        if ($att{'L3'} eq 'B') { 
          return '_'; # unique at depth 4
        } 
        return 't';
      } 
      if ($att{'R2'} eq 'A') { 
        if ($att{'L3'} eq 'M') { 
          return 's'; # unique at depth 4
        } 
        if ($att{'L3'} eq 'I') { 
          return 's'; # unique at depth 4
        } 
        return 't';
      } 
      if ($att{'R2'} eq 'T') { 
        if ($att{'L1'} eq 'C') { 
          return 'k'; # unique at depth 4
        } 
        if ($att{'L1'} eq 'T') { 
          if ($att{'R3'} eq '-') { 
            if ($att{'L2'} eq 'A') { 
              if ($att{'L3'} eq 'B') { 
                return 't'; # depth limit (1/2; 2 classes) at depth 7
              } 
              return '_';
            } 
            return '_';
          } 
          return 't';
        } 
        return 't';
      } 
      if ($att{'R2'} eq 'S') { 
        if ($att{'L2'} eq 'I') { 
          return 'O'; # unique at depth 4
        } 
        if ($att{'L2'} eq 'O') { 
          return '_'; # unique at depth 4
        } 
        return 't';
      } 
      if ($att{'R2'} eq 'O') { 
        if ($att{'L1'} eq 'A') { 
          if ($att{'L3'} eq 'A') { 
            return 'a'; # unique at depth 5
          } 
          if ($att{'L3'} eq 'R') { 
            if ($att{'L2'} eq 'N') { 
              return 's'; # unique at depth 6
            } 
            return '_';
          } 
          return '_';
        } 
        if ($att{'L1'} eq 'N') { 
          if ($att{'L3'} eq 'T') { 
            if ($att{'R3'} eq 'N') { 
              if ($att{'L2'} eq 'E') { 
                return '_'; # depth limit (1/2; 2 classes) at depth 7
              } 
              return 'A~';
            } 
            return '_';
          } 
          if ($att{'L3'} eq 'S') { 
            return 't'; # unique at depth 5
          } 
          return 'A~';
        } 
        if ($att{'L1'} eq 'S') { 
          return 't'; # unique at depth 4
        } 
        if ($att{'L1'} eq 'C') { 
          if ($att{'L2'} eq 'N') { 
            return 's'; # unique at depth 5
          } 
          return '_';
        } 
        return '_';
      } 
      return 't';
    } 
    if ($att{'R1'} eq '-') { 
      if ($att{'L1'} eq 'A') { 
        if ($att{'L3'} eq '-') { 
          return 't'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'L1'} eq 'E') { 
        if ($att{'L3'} eq '-') { 
          return 't'; # unique at depth 4
        } 
        return 'E';
      } 
      if ($att{'L1'} eq 'N') { 
        if ($att{'L3'} eq 'G') { 
          if ($att{'L2'} eq 'A') { 
            return 'A~'; # unique at depth 5
          } 
          return '_';
        } 
        if ($att{'L3'} eq 'N') { 
          if ($att{'L2'} eq 'E') { 
            return '_';
          } 
          return 'A~';
        } 
        if ($att{'L3'} eq 'L') { 
          if ($att{'L2'} eq 'E') { 
            return '_'; # unique at depth 5
          } 
          return 'A~';
        } 
        if ($att{'L3'} eq 'H') { 
          if ($att{'L2'} eq 'E') { 
            return '_'; # unique at depth 5
          } 
          return 'A~';
        } 
        if ($att{'L3'} eq 'E') { 
          if ($att{'L2'} eq 'I') { 
            return '_'; # unique at depth 5
          } 
          return 'A~';
        } 
        if ($att{'L3'} eq 'D') { 
          if ($att{'L2'} eq 'A') { 
            return 'A~'; # unique at depth 5
          } 
          return '_';
        } 
        if ($att{'L3'} eq 'R') { 
          if ($att{'L2'} eq 'A') { 
            return 'A~';
          } 
          return '_';
        } 
        if ($att{'L3'} eq 'P') { 
          if ($att{'L2'} eq 'E') { 
            return '_'; # unique at depth 5
          } 
          return 'A~';
        } 
        if ($att{'L3'} eq 'U') { 
          if ($att{'L2'} eq 'E') { 
            return '_'; # unique at depth 5
          } 
          return 'A~';
        } 
        if ($att{'L3'} eq 'V') { 
          if ($att{'L2'} eq 'E') { 
            return '_'; # unique at depth 5
          } 
          if ($att{'L2'} eq 'I') { 
            return '_'; # unique at depth 5
          } 
          return 'A~';
        } 
        if ($att{'L3'} eq 'O') { 
          return '_'; # unique at depth 4
        } 
        if ($att{'L3'} eq 'M') { 
          if ($att{'L2'} eq 'O') { 
            return '_'; # unique at depth 5
          } 
          return 'A~';
        } 
        if ($att{'L3'} eq 'S') { 
          if ($att{'L2'} eq 'E') { 
            return '_';
          } 
          return 'A~';
        } 
        if ($att{'L3'} eq 'T') { 
          if ($att{'L2'} eq 'E') { 
            if ($att{'R3'} eq '-') { 
              if ($att{'R2'} eq '-') { 
                return '_'; # depth limit (7/15; 3 classes) at depth 7
              } 
              return 't';
            } 
            return '_';
          } 
          if ($att{'L2'} eq 'I') { 
            return '_'; # unique at depth 5
          } 
          return 'A~';
        } 
        if ($att{'L3'} eq 'I') { 
          if ($att{'L2'} eq 'A') { 
            return 'A~'; # unique at depth 5
          } 
          return 'E';
        } 
        return 'A~';
      } 
      if ($att{'L1'} eq 'R') { 
        if ($att{'L3'} eq 'H') { 
          return 't'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'L1'} eq 'P') { 
        if ($att{'R3'} eq '-') { 
          if ($att{'R2'} eq '-') { 
            if ($att{'L2'} eq 'M') { 
              if ($att{'L3'} eq 'O') { 
                return '_'; # depth limit (1/2; 2 classes) at depth 7
              } 
              return 't';
            } 
            return 't';
          } 
          return '_';
        } 
        return 't';
      } 
      if ($att{'L1'} eq 'O') { 
        if ($att{'L2'} eq 'D') { 
          return 't'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'L1'} eq 'U') { 
        if ($att{'L3'} eq '-') { 
          return 't'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'L1'} eq 'C') { 
        return 't'; # unique at depth 3
      } 
      if ($att{'L1'} eq 'I') { 
        if ($att{'L2'} eq 'R') { 
          return '_'; # unique at depth 4
        } 
        if ($att{'L2'} eq 'D') { 
          return '_'; # unique at depth 4
        } 
        if ($att{'L2'} eq 'N') { 
          if ($att{'L3'} eq 'A') { 
            return 't'; # unique at depth 5
          } 
          return '_';
        } 
        if ($att{'L2'} eq 'H') { 
          return '_'; # unique at depth 4
        } 
        if ($att{'L2'} eq 'L') { 
          return '_'; # unique at depth 4
        } 
        if ($att{'L2'} eq 'V') { 
          return '_'; # unique at depth 4
        } 
        if ($att{'L2'} eq 'O') { 
          return 'a'; # unique at depth 4
        } 
        if ($att{'L2'} eq 'U') { 
          if ($att{'L3'} eq 'H') { 
            return 't'; # unique at depth 5
          } 
          return '_';
        } 
        if ($att{'L2'} eq 'M') { 
          return '_'; # unique at depth 4
        } 
        if ($att{'L2'} eq 'S') { 
          return '_'; # unique at depth 4
        } 
        if ($att{'L2'} eq 'T') { 
          return '_'; # unique at depth 4
        } 
        if ($att{'L2'} eq 'B') { 
          return '_'; # unique at depth 4
        } 
        return 'E';
      } 
      if ($att{'L1'} eq '3') { 
        if ($att{'L3'} eq 'A') { 
          return 'E'; # unique at depth 4
        } 
        return '_';
      } 
      return 'E';
    } 
    if ($att{'R1'} eq 'O') { 
      if ($att{'L1'} eq 'T') { 
        if ($att{'L3'} eq 'P') { 
          return '_'; # unique at depth 4
        } 
        return 't';
      } 
      return 't';
    } 
    if ($att{'R1'} eq 'U') { 
      if ($att{'L3'} eq 'C') { 
        if ($att{'L2'} eq 'T') { 
          return 'i'; # unique at depth 4
        } 
        return 't';
      } 
      return 't';
    } 
    if ($att{'R1'} eq 'T') { 
      if ($att{'L1'} eq 'A') { 
        if ($att{'L2'} eq 'R') { 
          if ($att{'R3'} eq 'R') { 
            return '_'; # unique at depth 5
          } 
          return 't';
        } 
        if ($att{'L2'} eq 'B') { 
          if ($att{'L3'} eq 'A') { 
            return 't'; # unique at depth 5
          } 
          if ($att{'L3'} eq '1') { 
            return 't'; # unique at depth 5
          } 
          if ($att{'L3'} eq 'M') { 
            return 't'; # unique at depth 5
          } 
          return '_';
        } 
        return 't';
      } 
      if ($att{'L1'} eq 'E') { 
        if ($att{'R3'} eq 'R') { 
          return 't'; # unique at depth 4
        } 
        if ($att{'R3'} eq 'N') { 
          if ($att{'L3'} eq 'G') { 
            return 't'; # unique at depth 5
          } 
          return 'E';
        } 
        if ($att{'R3'} eq 'I') { 
          if ($att{'L3'} eq '-') { 
            return 't'; # unique at depth 5
          } 
          return 'E';
        } 
        if ($att{'R3'} eq '1') { 
          return 't'; # unique at depth 4
        } 
        return 'E';
      } 
      return 't';
    } 
    if ($att{'R1'} eq 'S') { 
      if ($att{'L1'} eq 'A') { 
        return '_'; # unique at depth 3
      } 
      if ($att{'L1'} eq 'G') { 
        return '_'; # unique at depth 3
      } 
      if ($att{'L1'} eq 'E') { 
        return 'E'; # unique at depth 3
      } 
      if ($att{'L1'} eq 'N') { 
        if ($att{'L2'} eq 'I') { 
          return '_'; # unique at depth 4
        } 
        if ($att{'L2'} eq 'O') { 
          return '_'; # unique at depth 4
        } 
        return 'A~';
      } 
      if ($att{'L1'} eq 'R') { 
        return '_'; # unique at depth 3
      } 
      if ($att{'L1'} eq 'O') { 
        return '_'; # unique at depth 3
      } 
      if ($att{'L1'} eq 'U') { 
        if ($att{'L3'} eq 'S') { 
          return '_'; # unique at depth 4
        } 
        return 't';
      } 
      if ($att{'L1'} eq 'C') { 
        if ($att{'L3'} eq 'P') { 
          return 'E'; # unique at depth 4
        } 
        if ($att{'L3'} eq 'T') { 
          return 't'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'L1'} eq 'I') { 
        if ($att{'L3'} eq 'L') { 
          return 'a'; # unique at depth 4
        } 
        if ($att{'L3'} eq 'R') { 
          return 'a'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'L1'} eq '3') { 
        if ($att{'L3'} eq 'G') { 
          return '_'; # unique at depth 4
        } 
        return 'E';
      } 
      return 'A~';
    } 
    return 't';
  } 
  if ($att{'L'} eq 'Y') { 
    if ($att{'L1'} eq 'A') { 
      if ($att{'L2'} eq 'P') { 
        if ($att{'R1'} eq 'S') { 
          return 'i'; # unique at depth 4
        } 
        return 'j';
      } 
      if ($att{'L2'} eq 'W') { 
        return 'E'; # unique at depth 3
      } 
      if ($att{'L2'} eq '-') { 
        return 'E'; # unique at depth 3
      } 
      if ($att{'L2'} eq 'B') { 
        return 'i'; # unique at depth 3
      } 
      return 'j';
    } 
    if ($att{'L1'} eq 'E') { 
      if ($att{'L3'} eq 'C') { 
        return 'E'; # unique at depth 3
      } 
      return 'j';
    } 
    if ($att{'L1'} eq 'O') { 
      if ($att{'R3'} eq 'C') { 
        if ($att{'R2'} eq 'N') { 
          if ($att{'R1'} eq 'A') { 
            if ($att{'L2'} eq 'R') { 
              if ($att{'L3'} eq 'C') { 
                return 'w'; # depth limit (1/2; 2 classes) at depth 7
              } 
              return 'a';
            } 
            return 'a';
          } 
          return 'a';
        } 
        return 'a';
      } 
      if ($att{'R3'} eq 'T') { 
        return 'w'; # unique at depth 3
      } 
      if ($att{'R3'} eq '-') { 
        if ($att{'R1'} eq '-') { 
          return 'j'; # unique at depth 4
        } 
        return 'a';
      } 
      if ($att{'R3'} eq 'X') { 
        return 'w'; # unique at depth 3
      } 
      return 'a';
    } 
    if ($att{'L1'} eq 'S') { 
      if ($att{'R1'} eq 'N') { 
        return '_'; # unique at depth 3
      } 
      if ($att{'R1'} eq 'L') { 
        return 'i'; # unique at depth 3
      } 
      if ($att{'R1'} eq 'C') { 
        return 'i'; # unique at depth 3
      } 
      return 'E~';
    } 
    return 'i';
  } 
  if ($att{'L'} eq 'M') { 
    if ($att{'R1'} eq 'P') { 
      if ($att{'L3'} eq 'E') { 
        return 'A~'; # unique at depth 3
      } 
      return '_';
    } 
    if ($att{'R1'} eq 'E') { 
      if ($att{'L1'} eq 'M') { 
        if ($att{'L3'} eq 'G') { 
          if ($att{'L2'} eq 'E') { 
            return 'm'; # unique at depth 5
          } 
          return '_';
        } 
        if ($att{'L3'} eq 'Y') { 
          return 'm'; # unique at depth 4
        } 
        if ($att{'L3'} eq 'D') { 
          if ($att{'L2'} eq 'A') { 
            return '_'; # unique at depth 5
          } 
          return 'm';
        } 
        if ($att{'L3'} eq 'I') { 
          return 'm'; # unique at depth 4
        } 
        if ($att{'L3'} eq 'U') { 
          return 'm'; # unique at depth 4
        } 
        if ($att{'L3'} eq 'S') { 
          if ($att{'L2'} eq 'O') { 
            return '_'; # unique at depth 5
          } 
          return 'm';
        } 
        if ($att{'L3'} eq 'T') { 
          return 'm'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'L1'} eq 'S') { 
        if ($att{'L3'} eq 'T') { 
          if ($att{'R3'} eq '-') { 
            if ($att{'R2'} eq '-') { 
              return 's';
            } 
            return 'm';
          } 
          return 'm';
        } 
        return 'm';
      } 
      if ($att{'L1'} eq 'I') { 
        if ($att{'R2'} eq '1') { 
          if ($att{'R3'} eq '-') { 
            if ($att{'L2'} eq 'R') { 
              if ($att{'L3'} eq 'P') { 
                return 'i'; # depth limit (1/2; 2 classes) at depth 7
              } 
              return 'm';
            } 
            return 'i';
          } 
          return 'm';
        } 
        return 'm';
      } 
      return 'm';
    } 
    if ($att{'R1'} eq 'N') { 
      if ($att{'L2'} eq 'H') { 
        return 'm'; # unique at depth 3
      } 
      if ($att{'L2'} eq 'G') { 
        return 'm'; # unique at depth 3
      } 
      if ($att{'L2'} eq 'S') { 
        return 'm'; # unique at depth 3
      } 
      return '_';
    } 
    if ($att{'R1'} eq 'A') { 
      if ($att{'L1'} eq 'A') { 
        if ($att{'L2'} eq 'L') { 
          if ($att{'R2'} eq 'I') { 
            return 'm'; # unique at depth 5
          } 
          return 'a';
        } 
        return 'm';
      } 
      if ($att{'L1'} eq 'M') { 
        return '_'; # unique at depth 3
      } 
      if ($att{'L1'} eq 'I') { 
        if ($att{'L3'} eq 'P') { 
          if ($att{'R2'} eq 'I') { 
            return 'p'; # unique at depth 5
          } 
          return 'i';
        } 
        return 'm';
      } 
      return 'm';
    } 
    if ($att{'R1'} eq 'I') { 
      if ($att{'L3'} eq 'E') { 
        return 'a'; # unique at depth 3
      } 
      if ($att{'L3'} eq 'S') { 
        if ($att{'L1'} eq 'M') { 
          return '_'; # unique at depth 4
        } 
        return 'm';
      } 
      if ($att{'L3'} eq 'C') { 
        if ($att{'L2'} eq 'H') { 
          return 'm'; # unique at depth 4
        } 
        if ($att{'L2'} eq 'R') { 
          return 'm'; # unique at depth 4
        } 
        return '_';
      } 
      return 'm';
    } 
    if ($att{'R1'} eq 'T') { 
      return '_'; # unique at depth 2
    } 
    if ($att{'R1'} eq 'M') { 
      if ($att{'L2'} eq 'Y') { 
        return 'a'; # unique at depth 3
      } 
      if ($att{'L2'} eq 'D') { 
        if ($att{'L3'} eq 'N') { 
          return 'm'; # unique at depth 4
        } 
        return 'a';
      } 
      if ($att{'L2'} eq 'G') { 
        if ($att{'L3'} eq '-') { 
          return 'm'; # unique at depth 4
        } 
        return 'a';
      } 
      if ($att{'L2'} eq 'P') { 
        return '_'; # unique at depth 3
      } 
      if ($att{'L2'} eq 'S') { 
        if ($att{'L3'} eq 'E') { 
          return '_'; # unique at depth 4
        } 
        return 'm';
      } 
      if ($att{'L2'} eq 'T') { 
        return '_'; # unique at depth 3
      } 
      if ($att{'L2'} eq 'U') { 
        return 'a'; # unique at depth 3
      } 
      if ($att{'L2'} eq 'I') { 
        return 'a'; # unique at depth 3
      } 
      return 'm';
    } 
    if ($att{'R1'} eq 'S') { 
      return '_'; # unique at depth 2
    } 
    if ($att{'R1'} eq 'B') { 
      return '_'; # unique at depth 2
    } 
    if ($att{'R1'} eq '-') { 
      if ($att{'L3'} eq '-') { 
        return '_'; # unique at depth 3
      } 
      return 'm';
    } 
    if ($att{'R1'} eq 'O') { 
      if ($att{'L2'} eq 'I') { 
        return '_'; # unique at depth 3
      } 
      return 'm';
    } 
    if ($att{'R1'} eq 'U') { 
      if ($att{'L1'} eq 'M') { 
        return '_'; # unique at depth 3
      } 
      return 'm';
    } 
    return 'm';
  } 
  if ($att{'L'} eq 'E') { 
    if ($att{'R1'} eq 'J') { 
      return '@'; # unique at depth 2
    } 
    if ($att{'R1'} eq 'P') { 
      if ($att{'L1'} eq 'S') { 
        if ($att{'L3'} eq 'A') { 
          return '_'; # unique at depth 4
        } 
        return 'E';
      } 
      if ($att{'L1'} eq 'C') { 
        return 'E'; # unique at depth 3
      } 
      if ($att{'L1'} eq 'T') { 
        return 'E'; # unique at depth 3
      } 
      return '@';
    } 
    if ($att{'R1'} eq 'R') { 
      if ($att{'R2'} eq 'P') { 
        return 'E'; # unique at depth 3
      } 
      if ($att{'R2'} eq 'R') { 
        if ($att{'R3'} eq 'E') { 
          if ($att{'L1'} eq 'S') { 
            if ($att{'L2'} eq '-') { 
              if ($att{'L3'} eq '-') { 
                return 'E'; # depth limit (1/2; 2 classes) at depth 7
              } 
              return 'e';
            } 
            return 'e';
          } 
          if ($att{'L1'} eq 'T') { 
            if ($att{'L2'} eq 'N') { 
              if ($att{'L3'} eq 'E') { 
                return 'E'; # depth limit (1/2; 2 classes) at depth 7
              } 
              return 'e';
            } 
            return 'E';
          } 
          return 'E';
        } 
        if ($att{'R3'} eq 'O') { 
          if ($att{'L1'} eq 'V') { 
            if ($att{'L2'} eq '-') { 
              if ($att{'L3'} eq '-') { 
                return 'e'; # depth limit (1/2; 2 classes) at depth 7
              } 
              return 'E';
            } 
            return 'e';
          } 
          if ($att{'L1'} eq 'T') { 
            if ($att{'L2'} eq 'N') { 
              return 'e';
            } 
            return 'E';
          } 
          return 'e';
        } 
        return 'E';
      } 
      if ($att{'R2'} eq 'D') { 
        return 'E'; # unique at depth 3
      } 
      if ($att{'R2'} eq 'E') { 
        if ($att{'R3'} eq 'U') { 
          if ($att{'L1'} eq 'G') { 
            if ($att{'L2'} eq 'N') { 
              if ($att{'L3'} eq 'A') { 
                return '@'; # depth limit (1/2; 2 classes) at depth 7
              } 
              return '_';
            } 
            return '_';
          } 
          return '@';
        } 
        return '@';
      } 
      if ($att{'R2'} eq 'L') { 
        return 'E'; # unique at depth 3
      } 
      if ($att{'R2'} eq 'N') { 
        return 'E'; # unique at depth 3
      } 
      if ($att{'R2'} eq 'G') { 
        return 'E'; # unique at depth 3
      } 
      if ($att{'R2'} eq 'A') { 
        if ($att{'L1'} eq 'I') { 
          return '_'; # unique at depth 4
        } 
        return '@';
      } 
      if ($att{'R2'} eq 'I') { 
        if ($att{'L2'} eq 'R') { 
          return '@'; # unique at depth 4
        } 
        if ($att{'L2'} eq 'Q') { 
          return '@'; # unique at depth 4
        } 
        if ($att{'L2'} eq '-') { 
          return '@'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'R2'} eq 'F') { 
        return 'E'; # unique at depth 3
      } 
      if ($att{'R2'} eq 'C') { 
        if ($att{'L1'} eq 'X') { 
          return 'z'; # unique at depth 4
        } 
        return 'E';
      } 
      if ($att{'R2'} eq 'T') { 
        return 'E'; # unique at depth 3
      } 
      if ($att{'R2'} eq 'M') { 
        return 'E'; # unique at depth 3
      } 
      if ($att{'R2'} eq 'S') { 
        if ($att{'L1'} eq 'G') { 
          return 'e'; # unique at depth 4
        } 
        if ($att{'L1'} eq 'L') { 
          return 'e'; # unique at depth 4
        } 
        if ($att{'L1'} eq 'I') { 
          if ($att{'L3'} eq 'P') { 
            return 'j'; # unique at depth 5
          } 
          return 'e';
        } 
        return 'E';
      } 
      if ($att{'R2'} eq 'B') { 
        return 'E'; # unique at depth 3
      } 
      if ($att{'R2'} eq '-') { 
        if ($att{'L3'} eq 'T') { 
          if ($att{'L2'} eq 'O') { 
            return 'j'; # unique at depth 5
          } 
          return 'e';
        } 
        if ($att{'L3'} eq 'B') { 
          if ($att{'L2'} eq 'L') { 
            return 'j'; # unique at depth 5
          } 
          return 'e';
        } 
        if ($att{'L3'} eq 'V') { 
          if ($att{'L1'} eq 'Y') { 
            return 'j'; # unique at depth 5
          } 
          return 'e';
        } 
        if ($att{'L3'} eq 'O') { 
          if ($att{'L2'} eq 'R') { 
            if ($att{'L1'} eq 'T') { 
              if ($att{'R3'} eq '-') { 
                return 'E'; # depth limit (1/2; 2 classes) at depth 7
              } 
              return 'e';
            } 
            return 'e';
          } 
          return 'e';
        } 
        if ($att{'L3'} eq '-') { 
          if ($att{'L2'} eq 'F') { 
            return 'e'; # unique at depth 5
          } 
          if ($att{'L2'} eq 'L') { 
            return 'j'; # unique at depth 5
          } 
          return 'E';
        } 
        if ($att{'L3'} eq '1') { 
          if ($att{'L2'} eq 'T') { 
            return 'E'; # unique at depth 5
          } 
          return 'e';
        } 
        if ($att{'L3'} eq 'Y') { 
          return 'Z'; # unique at depth 4
        } 
        if ($att{'L3'} eq 'D') { 
          if ($att{'L1'} eq 'I') { 
            return 'j';
          } 
          return 'e';
        } 
        if ($att{'L3'} eq 'N') { 
          if ($att{'L1'} eq 'Y') { 
            return 'j'; # unique at depth 5
          } 
          return 'e';
        } 
        if ($att{'L3'} eq 'L') { 
          if ($att{'L1'} eq 'R') { 
            return 'R'; # unique at depth 5
          } 
          if ($att{'L1'} eq 'Y') { 
            if ($att{'L2'} eq 'A') { 
              return 'e'; # unique at depth 6
            } 
            return 'j';
          } 
          return 'e';
        } 
        if ($att{'L3'} eq 'A') { 
          if ($att{'L1'} eq 'C') { 
            if ($att{'R3'} eq '-') { 
              return 'e';
            } 
            return 'E';
          } 
          return 'e';
        } 
        if ($att{'L3'} eq 'P') { 
          if ($att{'L2'} eq 'L') { 
            return 'j'; # unique at depth 5
          } 
          return 'e';
        } 
        if ($att{'L3'} eq 'X') { 
          return 'Z'; # unique at depth 4
        } 
        return 'e';
      } 
      if ($att{'R2'} eq 'V') { 
        return 'E'; # unique at depth 3
      } 
      if ($att{'R2'} eq 'O') { 
        if ($att{'L3'} eq 'A') { 
          return '_'; # unique at depth 4
        } 
        return '@';
      } 
      return 'e';
    } 
    if ($att{'R1'} eq 'Z') { 
      if ($att{'L3'} eq 'D') { 
        return 'j'; # unique at depth 3
      } 
      return '_';
    } 
    if ($att{'R1'} eq 'X') { 
      return 'E';
    } 
    if ($att{'R1'} eq 'D') { 
      if ($att{'L2'} eq 'B') { 
        return 'E'; # unique at depth 3
      } 
      if ($att{'L2'} eq 'S') { 
        return 'e'; # unique at depth 3
      } 
      return '@';
    } 
    if ($att{'R1'} eq 'Y') { 
      if ($att{'L3'} eq 'O') { 
        return '_'; # unique at depth 3
      } 
      return 'E';
    } 
    if ($att{'R1'} eq 'L') { 
      if ($att{'R2'} eq 'I') { 
        if ($att{'L3'} eq 'U') { 
          return '_'; # unique at depth 4
        } 
        return '@';
      } 
      if ($att{'R2'} eq 'O') { 
        if ($att{'L3'} eq '-') { 
          return '@'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'R2'} eq 'A') { 
        if ($att{'L3'} eq 'A') { 
          if ($att{'R3'} eq 'I') { 
            if ($att{'L1'} eq 'P') { 
              if ($att{'L2'} eq 'P') { 
                return '@'; # depth limit (2/4; 2 classes) at depth 7
              } 
              return '_';
            } 
            return '_';
          } 
          return '_';
        } 
        return '@';
      } 
      if ($att{'R2'} eq 'E') { 
        if ($att{'L3'} eq 'M') { 
          return '_'; # unique at depth 4
        } 
        if ($att{'L3'} eq 'S') { 
          return '_'; # unique at depth 4
        } 
        if ($att{'L3'} eq 'O') { 
          return '_'; # unique at depth 4
        } 
        if ($att{'L3'} eq 'R') { 
          return '_'; # unique at depth 4
        } 
        return '@';
      } 
      if ($att{'R2'} eq 'L') { 
        if ($att{'L1'} eq 'O') { 
          if ($att{'R3'} eq 'E') { 
            if ($att{'L2'} eq 'M') { 
              return 'E';
            } 
            return '_';
          } 
          return '_';
        } 
        if ($att{'L1'} eq 'C') { 
          if ($att{'L2'} eq '-') { 
            if ($att{'R3'} eq 'U') { 
              return 'e'; # unique at depth 6
            } 
            return '@';
          } 
          return 'E';
        } 
        if ($att{'L1'} eq 'T') { 
          if ($att{'L3'} eq 'E') { 
            return 'E'; # unique at depth 5
          } 
          if ($att{'L3'} eq 'R') { 
            return 'E'; # unique at depth 5
          } 
          return 'e';
        } 
        return 'E';
      } 
      return 'E';
    } 
    if ($att{'R1'} eq '2') { 
      if ($att{'L3'} eq 'B') { 
        if ($att{'L2'} eq 'R') { 
          return 'j'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'L3'} eq 'V') { 
        return 'j'; # unique at depth 3
      } 
      if ($att{'L3'} eq 'X') { 
        if ($att{'L2'} eq 'A') { 
          return 'Z'; # unique at depth 4
        } 
        return 'R';
      } 
      return '_';
    } 
    if ($att{'R1'} eq 'N') { 
      if ($att{'R2'} eq 'I') { 
        if ($att{'L3'} eq 'O') { 
          return '_'; # unique at depth 4
        } 
        if ($att{'L3'} eq 'D') { 
          return '_'; # unique at depth 4
        } 
        return '@';
      } 
      if ($att{'R2'} eq 'O') { 
        if ($att{'L1'} eq 'G') { 
          if ($att{'R3'} eq 'U') { 
            if ($att{'L2'} eq 'A') { 
              if ($att{'L3'} eq '-') { 
                return '_'; # depth limit (1/2; 2 classes) at depth 7
              } 
              return '@';
            } 
            return '@';
          } 
          return '@';
        } 
        return '@';
      } 
      if ($att{'R2'} eq '-') { 
        if ($att{'L3'} eq 'T') { 
          return 'j'; # unique at depth 4
        } 
        if ($att{'L3'} eq 'D') { 
          return 'j'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'R2'} eq 'U') { 
        if ($att{'L2'} eq 'A') { 
          return '_'; # unique at depth 4
        } 
        if ($att{'L2'} eq 'N') { 
          if ($att{'R3'} eq '-') { 
            return '_'; # unique at depth 5
          } 
          return '@';
        } 
        return '@';
      } 
      if ($att{'R2'} eq 'S') { 
        if ($att{'L3'} eq 'T') { 
          return 'j'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'R2'} eq 'T') { 
        if ($att{'L3'} eq 'I') { 
          if ($att{'L1'} eq 'T') { 
            return 's'; # unique at depth 5
          } 
          return '_';
        } 
        if ($att{'L3'} eq 'E') { 
          if ($att{'L1'} eq 'N') { 
            if ($att{'L2'} eq 'N') { 
              if ($att{'R3'} eq '-') { 
                return '_'; # depth limit (1/2; 2 classes) at depth 7
              } 
              return 'E';
            } 
            return '_';
          } 
          return '_';
        } 
        return '_';
      } 
      if ($att{'R2'} eq 'A') { 
        if ($att{'L2'} eq 'N') { 
          return '_'; # unique at depth 4
        } 
        if ($att{'L2'} eq 'E') { 
          if ($att{'L1'} eq 'V') { 
            if ($att{'L3'} eq 'D') { 
              return '@'; # unique at depth 6
            } 
            return '_';
          } 
          return '@';
        } 
        if ($att{'L2'} eq 'U') { 
          return '_'; # unique at depth 4
        } 
        if ($att{'L2'} eq '-') { 
          if ($att{'R3'} eq 'I') { 
            if ($att{'L1'} eq 'M') { 
              return '_'; # unique at depth 6
            } 
            return '@';
          } 
          return '@';
        } 
        if ($att{'L2'} eq 'O') { 
          if ($att{'R3'} eq 'I') { 
            return '_'; # unique at depth 5
          } 
          return '@';
        } 
        return '@';
      } 
      if ($att{'R2'} eq 'E') { 
        if ($att{'L2'} eq 'E') { 
          return '_'; # unique at depth 4
        } 
        if ($att{'L2'} eq 'O') { 
          return '_'; # unique at depth 4
        } 
        return '@';
      } 
      if ($att{'R2'} eq 'N') { 
        if ($att{'L1'} eq 'Y') { 
          return 'j'; # unique at depth 4
        } 
        if ($att{'L1'} eq 'L') { 
          return '_'; # unique at depth 4
        } 
        if ($att{'L1'} eq '-') { 
          if ($att{'R3'} eq 'U') { 
            return '_'; # unique at depth 5
          } 
          return 'E';
        } 
        if ($att{'L1'} eq 'I') { 
          if ($att{'L2'} eq 'T') { 
            if ($att{'L3'} eq '-') { 
              return 'E'; # unique at depth 6
            } 
            return '_';
          } 
          return 'E';
        } 
        return 'E';
      } 
      return '_';
    } 
    if ($att{'R1'} eq 'G') { 
      return '@'; # unique at depth 2
    } 
    if ($att{'R1'} eq 'A') { 
      if ($att{'R3'} eq 'S') { 
        return 'E'; # unique at depth 3
      } 
      if ($att{'R3'} eq '-') { 
        if ($att{'L3'} eq '-') { 
          return 'Z'; # unique at depth 4
        } 
        return '_';
      } 
      return '_';
    } 
    if ($att{'R1'} eq 'I') { 
      if ($att{'L2'} eq 'P') { 
        if ($att{'L3'} eq '-') { 
          return 'E'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'L2'} eq 'G') { 
        return '_'; # unique at depth 3
      } 
      if ($att{'L2'} eq 'N') { 
        if ($att{'R3'} eq 'L') { 
          if ($att{'R2'} eq 'L') { 
            if ($att{'L1'} eq 'S') { 
              return 'E';
            } 
            return 'e';
          } 
          return 'e';
        } 
        return 'E';
      } 
      if ($att{'L2'} eq 'F') { 
        return '_'; # unique at depth 3
      } 
      if ($att{'L2'} eq '-') { 
        if ($att{'R3'} eq 'T') { 
          return '_'; # unique at depth 4
        } 
        if ($att{'R3'} eq 'D') { 
          return '_'; # unique at depth 4
        } 
        if ($att{'R3'} eq 'L') { 
          if ($att{'R2'} eq 'L') { 
            return 'E';
          } 
          return 'e';
        } 
        return 'E';
      } 
      if ($att{'L2'} eq '1') { 
        if ($att{'R3'} eq 'T') { 
          return '_'; # unique at depth 4
        } 
        return 'E';
      } 
      if ($att{'L2'} eq 'V') { 
        return 'e'; # unique at depth 3
      } 
      if ($att{'L2'} eq 'C') { 
        return '_'; # unique at depth 3
      } 
      if ($att{'L2'} eq 'T') { 
        return '_'; # unique at depth 3
      } 
      if ($att{'L2'} eq 'S') { 
        return '_'; # unique at depth 3
      } 
      return 'E';
    } 
    if ($att{'R1'} eq 'F') { 
      if ($att{'R2'} eq 'O') { 
        return '_'; # unique at depth 3
      } 
      if ($att{'R2'} eq '-') { 
        return 'E'; # unique at depth 3
      } 
      if ($att{'R2'} eq 'U') { 
        return '@'; # unique at depth 3
      } 
      if ($att{'R2'} eq 'R') { 
        return '@'; # unique at depth 3
      } 
      if ($att{'R2'} eq 'A') { 
        return '@'; # unique at depth 3
      } 
      if ($att{'R2'} eq 'E') { 
        return '@'; # unique at depth 3
      } 
      if ($att{'R2'} eq 'L') { 
        return '@'; # unique at depth 3
      } 
      return 'e';
    } 
    if ($att{'R1'} eq '3') { 
      if ($att{'L1'} eq 'G') { 
        if ($att{'R3'} eq 'A') { 
          return '_'; # unique at depth 4
        } 
        return 'e';
      } 
      if ($att{'L1'} eq 'R') { 
        if ($att{'L3'} eq 'P') { 
          return 'e'; # unique at depth 4
        } 
        if ($att{'L3'} eq 'X') { 
          return 'R'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'L1'} eq 'M') { 
        if ($att{'R3'} eq 'E') { 
          if ($att{'L2'} eq '1') { 
            return 'e'; # unique at depth 5
          } 
          return '_';
        } 
        return 'e';
      } 
      if ($att{'L1'} eq 'F') { 
        return 'e'; # unique at depth 3
      } 
      return '_';
    } 
    if ($att{'R1'} eq 'C') { 
      if ($att{'R2'} eq 'I') { 
        return '_'; # unique at depth 3
      } 
      if ($att{'R2'} eq '5') { 
        return '@'; # unique at depth 3
      } 
      if ($att{'R2'} eq 'O') { 
        if ($att{'L1'} eq 'S') { 
          if ($att{'R3'} eq 'N') { 
            if ($att{'L2'} eq '-') { 
              if ($att{'L3'} eq '-') { 
                return '_'; # depth limit (1/2; 2 classes) at depth 7
              } 
              return '@';
            } 
            return '@';
          } 
          if ($att{'R3'} eq 'U') { 
            if ($att{'L2'} eq '-') { 
              if ($att{'L3'} eq '-') { 
                return '_'; # depth limit (1/2; 2 classes) at depth 7
              } 
              return '@';
            } 
            return '@';
          } 
          return '_';
        } 
        return '@';
      } 
      if ($att{'R2'} eq 'U') { 
        return '@'; # unique at depth 3
      } 
      if ($att{'R2'} eq 'T') { 
        if ($att{'R3'} eq 'S') { 
          return '_'; # unique at depth 4
        } 
        return 'E';
      } 
      if ($att{'R2'} eq 'E') { 
        return '@'; # unique at depth 3
      } 
      if ($att{'R2'} eq 'H') { 
        if ($att{'L1'} eq 'T') { 
          return 'E'; # unique at depth 4
        } 
        return '@';
      } 
      return 'E';
    } 
    if ($att{'R1'} eq 'T') { 
      if ($att{'R2'} eq 'I') { 
        if ($att{'L3'} eq 'U') { 
          return '_'; # unique at depth 4
        } 
        if ($att{'L3'} eq 'I') { 
          return '_'; # unique at depth 4
        } 
        return '@';
      } 
      if ($att{'R2'} eq 'O') { 
        return '@'; # unique at depth 3
      } 
      if ($att{'R2'} eq '-') { 
        if ($att{'L2'} eq '-') { 
          return 'E'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'R2'} eq 'S') { 
        if ($att{'L3'} eq '-') { 
          return 'Z'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'R2'} eq 'T') { 
        if ($att{'L2'} eq 'G') { 
          if ($att{'L3'} eq '-') { 
            if ($att{'R3'} eq 'E') { 
              if ($att{'L1'} eq 'U') { 
                return '_'; # depth limit (1/2; 2 classes) at depth 7
              } 
              return 'e';
            } 
            return 'e';
          } 
          if ($att{'L3'} eq 'E') { 
            if ($att{'R3'} eq 'A') { 
              return '_'; # unique at depth 6
            } 
            return 'e';
          } 
          return '_';
        } 
        if ($att{'L2'} eq '-') { 
          if ($att{'R3'} eq 'A') { 
            return 'E'; # unique at depth 5
          } 
          return '_';
        } 
        return '_';
      } 
      if ($att{'R2'} eq 'R') { 
        if ($att{'R3'} eq 'O') { 
          if ($att{'L1'} eq 'R') { 
            if ($att{'L2'} eq '-') { 
              if ($att{'L3'} eq '-') { 
                return 'e'; # depth limit (3/6; 2 classes) at depth 7
              } 
              return '@';
            } 
            return 'e';
          } 
          return 'e';
        } 
        return '@';
      } 
      if ($att{'R2'} eq 'A') { 
        if ($att{'L2'} eq 'A') { 
          if ($att{'R3'} eq 'N') { 
            if ($att{'L1'} eq 'L') { 
              if ($att{'L3'} eq 'H') { 
                return '@'; # depth limit (1/2; 2 classes) at depth 7
              } 
              return '_';
            } 
            return '@';
          } 
          return '_';
        } 
        if ($att{'L2'} eq 'E') { 
          if ($att{'R3'} eq '-') { 
            return '@'; # unique at depth 5
          } 
          return '_';
        } 
        if ($att{'L2'} eq 'C') { 
          if ($att{'R3'} eq 'I') { 
            return '@'; # unique at depth 5
          } 
          return '_';
        } 
        return '@';
      } 
      if ($att{'R2'} eq 'E') { 
        if ($att{'L3'} eq 'O') { 
          return '@'; # unique at depth 4
        } 
        if ($att{'L3'} eq '-') { 
          return '@'; # unique at depth 4
        } 
        if ($att{'L3'} eq 'N') { 
          return '@'; # unique at depth 4
        } 
        if ($att{'L3'} eq 'R') { 
          if ($att{'R3'} eq '1') { 
            if ($att{'L1'} eq 'J') { 
              if ($att{'L2'} eq 'E') { 
                return '_'; # depth limit (1/2; 2 classes) at depth 7
              } 
              return '@';
            } 
            return '_';
          } 
          return '_';
        } 
        return '_';
      } 
      return '_';
    } 
    if ($att{'R1'} eq 'M') { 
      if ($att{'L2'} eq 'R') { 
        if ($att{'R2'} eq 'M') { 
          return '_'; # unique at depth 4
        } 
        return '@';
      } 
      if ($att{'L2'} eq 'G') { 
        if ($att{'L3'} eq 'O') { 
          return '@'; # unique at depth 4
        } 
        if ($att{'L3'} eq '2') { 
          return '@'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'L2'} eq 'A') { 
        if ($att{'L3'} eq 'H') { 
          return 'E'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'L2'} eq 'L') { 
        if ($att{'L3'} eq 'A') { 
          return '@'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'L2'} eq 'N') { 
        if ($att{'R3'} eq 'N') { 
          if ($att{'L1'} eq 'G') { 
            return '@'; # unique at depth 5
          } 
          return '_';
        } 
        if ($att{'R3'} eq 'L') { 
          return 'A~'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'L2'} eq 'E') { 
        return 'z'; # unique at depth 3
      } 
      if ($att{'L2'} eq 'I') { 
        if ($att{'R3'} eq 'N') { 
          if ($att{'L3'} eq 'S') { 
            if ($att{'R2'} eq 'E') { 
              if ($att{'L1'} eq 'V') { 
                return '_'; # depth limit (1/2; 2 classes) at depth 7
              } 
              return 'v';
            } 
            return 'v';
          } 
          return '_';
        } 
        if ($att{'R3'} eq 'L') { 
          return 'A~'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'L2'} eq 'F') { 
        return '@'; # unique at depth 3
      } 
      if ($att{'L2'} eq 'Q') { 
        if ($att{'L3'} eq 'R') { 
          return '@'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'L2'} eq 'U') { 
        if ($att{'L3'} eq 'J') { 
          return '@'; # unique at depth 4
        } 
        if ($att{'L3'} eq 'M') { 
          return '@'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'L2'} eq '-') { 
        if ($att{'R2'} eq 'E') { 
          return '@'; # unique at depth 4
        } 
        if ($att{'R2'} eq 'A') { 
          return '@'; # unique at depth 4
        } 
        if ($att{'R2'} eq 'I') { 
          return '@'; # unique at depth 4
        } 
        if ($att{'R2'} eq 'O') { 
          return '@'; # unique at depth 4
        } 
        if ($att{'R2'} eq 'U') { 
          return '@'; # unique at depth 4
        } 
        return 'A~';
      } 
      if ($att{'L2'} eq 'B') { 
        return '@'; # unique at depth 3
      } 
      if ($att{'L2'} eq 'C') { 
        if ($att{'L3'} eq 'E') { 
          return '@'; # unique at depth 4
        } 
        if ($att{'L3'} eq 'I') { 
          return '@'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'L2'} eq 'T') { 
        return 'A~'; # unique at depth 3
      } 
      if ($att{'L2'} eq 'S') { 
        if ($att{'L3'} eq 'A') { 
          return 'A~'; # unique at depth 4
        } 
        return '_';
      } 
      return '_';
    } 
    if ($att{'R1'} eq 'S') { 
      if ($att{'R2'} eq 'E') { 
        return '@'; # unique at depth 3
      } 
      if ($att{'R2'} eq 'A') { 
        return '@'; # unique at depth 3
      } 
      if ($att{'R2'} eq 'P') { 
        return 'E'; # unique at depth 3
      } 
      if ($att{'R2'} eq 'B') { 
        return 'E'; # unique at depth 3
      } 
      if ($att{'R2'} eq 'S') { 
        if ($att{'L2'} eq 'O') { 
          if ($att{'L1'} eq 'C') { 
            return 'e'; # unique at depth 5
          } 
          return 'E';
        } 
        if ($att{'L2'} eq '-') { 
          if ($att{'L1'} eq 'C') { 
            return 'E'; # unique at depth 5
          } 
          if ($att{'L1'} eq 'F') { 
            return 'E'; # unique at depth 5
          } 
          if ($att{'L1'} eq 'R') { 
            return '@'; # unique at depth 5
          } 
          return 'e';
        } 
        if ($att{'L2'} eq '1') { 
          if ($att{'L1'} eq 'C') { 
            return 'e'; # unique at depth 5
          } 
          return 'E';
        } 
        if ($att{'L2'} eq 'U') { 
          return 'E'; # unique at depth 4
        } 
        if ($att{'L2'} eq 'S') { 
          return 'E'; # unique at depth 4
        } 
        if ($att{'L2'} eq 'C') { 
          if ($att{'L3'} eq 'I') { 
            return '_'; # unique at depth 5
          } 
          return 'E';
        } 
        if ($att{'L2'} eq 'T') { 
          return 'E'; # unique at depth 4
        } 
        if ($att{'L2'} eq 'B') { 
          if ($att{'L3'} eq '-') { 
            return 'e';
          } 
          return 'E';
        } 
        if ($att{'L2'} eq '3') { 
          return 'E'; # unique at depth 4
        } 
        if ($att{'L2'} eq 'A') { 
          if ($att{'L3'} eq 'P') { 
            return 'E'; # unique at depth 5
          } 
          return 'e';
        } 
        if ($att{'L2'} eq 'G') { 
          if ($att{'L3'} eq 'O') { 
            return 'e'; # unique at depth 5
          } 
          return 'E';
        } 
        if ($att{'L2'} eq 'E') { 
          return 'E'; # unique at depth 4
        } 
        if ($att{'L2'} eq 'D') { 
          if ($att{'R3'} eq 'E') { 
            if ($att{'L3'} eq 'A') { 
              if ($att{'L1'} eq 'R') { 
                return 'e'; # depth limit (1/2; 2 classes) at depth 7
              } 
              return 'E';
            } 
            if ($att{'L3'} eq 'E') { 
              return 'e';
            } 
            return 'E';
          } 
          return 'e';
        } 
        if ($att{'L2'} eq 'N') { 
          if ($att{'L1'} eq 'C') { 
            return 'e'; # unique at depth 5
          } 
          return 'E';
        } 
        if ($att{'L2'} eq 'L') { 
          return 'E'; # unique at depth 4
        } 
        if ($att{'L2'} eq 'X') { 
          if ($att{'R3'} eq 'I') { 
            if ($att{'L1'} eq 'C') { 
              if ($att{'L3'} eq 'E') { 
                return 'E'; # depth limit (1/2; 2 classes) at depth 7
              } 
              return 'e';
            } 
            return 'E';
          } 
          return 'e';
        } 
        if ($att{'L2'} eq 'P') { 
          if ($att{'R3'} eq 'I') { 
            if ($att{'L3'} eq '1') { 
              return 'E'; # unique at depth 6
            } 
            return 'e';
          } 
          return 'E';
        } 
        return 'e';
      } 
      if ($att{'R2'} eq 'C') { 
        if ($att{'L2'} eq 'O') { 
          return 'e'; # unique at depth 4
        } 
        if ($att{'L2'} eq 'E') { 
          return 'e'; # unique at depth 4
        } 
        if ($att{'L2'} eq 'L') { 
          return '_'; # unique at depth 4
        } 
        return 'E';
      } 
      if ($att{'R2'} eq 'T') { 
        return 'E'; # unique at depth 3
      } 
      if ($att{'R2'} eq 'U') { 
        return '@'; # unique at depth 3
      } 
      if ($att{'R2'} eq 'O') { 
        return '@'; # unique at depth 3
      } 
      if ($att{'R2'} eq '-') { 
        if ($att{'L2'} eq '-') { 
          return 'e'; # unique at depth 4
        } 
        if ($att{'L2'} eq 'I') { 
          if ($att{'L1'} eq 'S') { 
            if ($att{'L3'} eq 'A') { 
              return 'E'; # unique at depth 6
            } 
            return '_';
          } 
          if ($att{'L1'} eq 'P') { 
            if ($att{'L3'} eq 'P') { 
              return 'j'; # unique at depth 6
            } 
            return '_';
          } 
          return '_';
        } 
        if ($att{'L2'} eq 'A') { 
          if ($att{'L1'} eq 'I') { 
            return 'E'; # unique at depth 5
          } 
          return '_';
        } 
        if ($att{'L2'} eq 'X') { 
          return 't'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'R2'} eq 'Q') { 
        return 'E'; # unique at depth 3
      } 
      return '_';
    } 
    if ($att{'R1'} eq 'B') { 
      if ($att{'L3'} eq '-') { 
        return '@'; # unique at depth 3
      } 
      return '_';
    } 
    if ($att{'R1'} eq '-') { 
      if ($att{'L1'} eq 'X') { 
        return 's'; # unique at depth 3
      } 
      if ($att{'L1'} eq 'L') { 
        if ($att{'L2'} eq '-') { 
          return '@'; # unique at depth 4
        } 
        if ($att{'L2'} eq 'G') { 
          if ($att{'L3'} eq 'I') { 
            return '@'; # unique at depth 5
          } 
          return '_';
        } 
        return '_';
      } 
      if ($att{'L1'} eq 'I') { 
        if ($att{'L2'} eq 'A') { 
          return 'E'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'L1'} eq 'C') { 
        if ($att{'L2'} eq '-') { 
          return '@'; # unique at depth 4
        } 
        if ($att{'L2'} eq 'R') { 
          if ($att{'L3'} eq 'E') { 
            return 's'; # unique at depth 5
          } 
          return '_';
        } 
        return '_';
      } 
      return '_';
    } 
    if ($att{'R1'} eq '1') { 
      if ($att{'L1'} eq 'P') { 
        if ($att{'L2'} eq 'O') { 
          return 'j'; # unique at depth 4
        } 
        if ($att{'L2'} eq 'S') { 
          if ($att{'L3'} eq 'A') { 
            return 'p'; # unique at depth 5
          } 
          return '_';
        } 
        return '_';
      } 
      if ($att{'L1'} eq 'R') { 
        if ($att{'L3'} eq 'X') { 
          return 'R'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'L1'} eq 'X') { 
        if ($att{'L3'} eq '-') { 
          return 'z'; # unique at depth 4
        } 
        return 's';
      } 
      if ($att{'L1'} eq 'Y') { 
        if ($att{'L2'} eq 'A') { 
          return '_'; # unique at depth 4
        } 
        return 'j';
      } 
      if ($att{'L1'} eq 'G') { 
        if ($att{'L3'} eq 'Y') { 
          return 'Z'; # unique at depth 4
        } 
        if ($att{'L3'} eq 'X') { 
          return 'Z'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'L1'} eq 'I') { 
        if ($att{'L3'} eq 'P') { 
          return 'j'; # unique at depth 4
        } 
        if ($att{'L3'} eq 'B') { 
          return 'j'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'L1'} eq 'T') { 
        if ($att{'L2'} eq 'I') { 
          if ($att{'L3'} eq 'X') { 
            return 't'; # unique at depth 5
          } 
          return '_';
        } 
        if ($att{'L2'} eq 'X') { 
          return 't'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'L1'} eq 'M') { 
        if ($att{'L3'} eq 'R') { 
          if ($att{'R3'} eq '-') { 
            if ($att{'R2'} eq '-') { 
              if ($att{'L2'} eq 'I') { 
                return '_'; # depth limit (1/2; 2 classes) at depth 7
              } 
              return 'm';
            } 
            return 'm';
          } 
          return '_';
        } 
        return '_';
      } 
      return '_';
    } 
    if ($att{'R1'} eq 'V') { 
      if ($att{'R3'} eq 'R') { 
        if ($att{'L3'} eq '-') { 
          return '@'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'R3'} eq 'L') { 
        if ($att{'R2'} eq 'A') { 
          return '@'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'R3'} eq 'U') { 
        return '_'; # unique at depth 3
      } 
      if ($att{'R3'} eq 'B') { 
        return '_'; # unique at depth 3
      } 
      return '@';
    } 
    if ($att{'R1'} eq 'U') { 
      if ($att{'L3'} eq 'N') { 
        if ($att{'L2'} eq 'X') { 
          return 'j'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'L3'} eq 'P') { 
        return 'j'; # unique at depth 3
      } 
      return '_';
    } 
    return '_';
  } 
  if ($att{'L'} eq 'S') { 
    if ($att{'R1'} eq 'L') { 
      if ($att{'L3'} eq 'L') { 
        return '_'; # unique at depth 3
      } 
      return 's';
    } 
    if ($att{'R1'} eq 'H') { 
      if ($att{'L3'} eq 'D') { 
        return 'z'; # unique at depth 3
      } 
      return '_';
    } 
    if ($att{'R1'} eq 'Y') { 
      return 's'; # unique at depth 2
    } 
    if ($att{'R1'} eq 'E') { 
      if ($att{'L1'} eq 'R') { 
        return 's'; # unique at depth 3
      } 
      if ($att{'L1'} eq 'L') { 
        return 's'; # unique at depth 3
      } 
      if ($att{'L1'} eq 'N') { 
        return 's'; # unique at depth 3
      } 
      if ($att{'L1'} eq 'I') { 
        if ($att{'R2'} eq 'M') { 
          if ($att{'L3'} eq 'N') { 
            return 'z'; # unique at depth 5
          } 
          if ($att{'L3'} eq 'P') { 
            return 'z'; # unique at depth 5
          } 
          return 's';
        } 
        if ($att{'R2'} eq 'S') { 
          if ($att{'L3'} eq 'L') { 
            return '_'; # unique at depth 5
          } 
          if ($att{'L3'} eq 'R') { 
            return '_'; # unique at depth 5
          } 
          if ($att{'L3'} eq 'T') { 
            return '_'; # unique at depth 5
          } 
          return 'z';
        } 
        return 'z';
      } 
      if ($att{'L1'} eq 'S') { 
        if ($att{'L3'} eq 'A') { 
          if ($att{'R2'} eq '-') { 
            if ($att{'L2'} eq 'I') { 
              if ($att{'R3'} eq '-') { 
                return '_'; # depth limit (1/2; 2 classes) at depth 7
              } 
              return 's';
            } 
            return '_';
          } 
          if ($att{'R2'} eq 'M') { 
            return 's'; # unique at depth 5
          } 
          return '_';
        } 
        if ($att{'L3'} eq 'L') { 
          if ($att{'L2'} eq 'E') { 
            if ($att{'R2'} eq 'R') { 
              return 's'; # unique at depth 6
            } 
            return '_';
          } 
          if ($att{'L2'} eq 'O') { 
            return 's'; # unique at depth 5
          } 
          return '_';
        } 
        if ($att{'L3'} eq 'R') { 
          if ($att{'R3'} eq 'B') { 
            return 's';
          } 
          return '_';
        } 
        if ($att{'L3'} eq 'P') { 
          if ($att{'R2'} eq '-') { 
            return 's'; # unique at depth 5
          } 
          if ($att{'R2'} eq '1') { 
            if ($att{'R3'} eq 'D') { 
              if ($att{'L2'} eq 'O') { 
                return '_'; # depth limit (1/2; 2 classes) at depth 7
              } 
              return 's';
            } 
            return '_';
          } 
          if ($att{'R2'} eq '2') { 
            return 's'; # unique at depth 5
          } 
          return '_';
        } 
        if ($att{'L3'} eq 'O') { 
          if ($att{'L2'} eq 'U') { 
            if ($att{'R2'} eq 'L') { 
              return 's'; # unique at depth 6
            } 
            return '_';
          } 
          if ($att{'L2'} eq 'I') { 
            return 's'; # unique at depth 5
          } 
          return '_';
        } 
        if ($att{'L3'} eq 'T') { 
          if ($att{'R2'} eq '-') { 
            if ($att{'L2'} eq 'I') { 
              return 's'; # unique at depth 6
            } 
            return '_';
          } 
          return '_';
        } 
        if ($att{'L3'} eq 'S') { 
          return 's'; # unique at depth 4
        } 
        if ($att{'L3'} eq 'F') { 
          if ($att{'L2'} eq 'O') { 
            return 's'; # unique at depth 5
          } 
          return '_';
        } 
        return '_';
      } 
      if ($att{'L1'} eq 'B') { 
        return 's'; # unique at depth 3
      } 
      if ($att{'L1'} eq '-') { 
        return 's'; # unique at depth 3
      } 
      if ($att{'L1'} eq 'O') { 
        if ($att{'L3'} eq 'X') { 
          return 'O'; # unique at depth 4
        } 
        return 'z';
      } 
      if ($att{'L1'} eq 'U') { 
        if ($att{'R2'} eq 'S') { 
          if ($att{'L3'} eq 'N') { 
            if ($att{'L2'} eq 'F') { 
              return 'z'; # unique at depth 6
            } 
            return '_';
          } 
          if ($att{'L3'} eq 'I') { 
            return '_';
          } 
          return 'z';
        } 
        return 'z';
      } 
      return 'z';
    } 
    if ($att{'R1'} eq 'A') { 
      if ($att{'L1'} eq 'R') { 
        return 's'; # unique at depth 3
      } 
      if ($att{'L1'} eq 'Y') { 
        return 'z'; # unique at depth 3
      } 
      if ($att{'L1'} eq 'E') { 
        if ($att{'L3'} eq 'B') { 
          return 's'; # unique at depth 4
        } 
        return 'z';
      } 
      if ($att{'L1'} eq 'N') { 
        return 's'; # unique at depth 3
      } 
      if ($att{'L1'} eq 'A') { 
        return 'z'; # unique at depth 3
      } 
      if ($att{'L1'} eq 'I') { 
        if ($att{'L2'} eq 'O') { 
          if ($att{'R2'} eq '-') { 
            return 'z'; # unique at depth 5
          } 
          return '_';
        } 
        return 'z';
      } 
      if ($att{'L1'} eq 'S') { 
        if ($att{'R3'} eq 'L') { 
          if ($att{'L3'} eq 'A') { 
            return 's'; # unique at depth 5
          } 
          return '_';
        } 
        if ($att{'R3'} eq 'E') { 
          if ($att{'L3'} eq '-') { 
            return 'E'; # unique at depth 5
          } 
          return '_';
        } 
        if ($att{'R3'} eq 'A') { 
          return 'E'; # unique at depth 4
        } 
        if ($att{'R3'} eq 'S') { 
          if ($att{'L2'} eq 'E') { 
            if ($att{'L3'} eq '-') { 
              return 's'; # unique at depth 6
            } 
            return 'e';
          } 
          return '_';
        } 
        if ($att{'R3'} eq 'T') { 
          if ($att{'L3'} eq 'N') { 
            if ($att{'R2'} eq 'I') { 
              if ($att{'L2'} eq 'I') { 
                return '_'; # depth limit (1/2; 2 classes) at depth 7
              } 
              return 's';
            } 
            return 's';
          } 
          return '_';
        } 
        if ($att{'R3'} eq '-') { 
          if ($att{'L3'} eq 'A') { 
            return 'e'; # unique at depth 5
          } 
          return '_';
        } 
        return '_';
      } 
      if ($att{'L1'} eq '-') { 
        return 's'; # unique at depth 3
      } 
      if ($att{'L1'} eq '1') { 
        return 'z'; # unique at depth 3
      } 
      if ($att{'L1'} eq 'O') { 
        return 'z'; # unique at depth 3
      } 
      if ($att{'L1'} eq 'U') { 
        if ($att{'L3'} eq 'X') { 
          return 'y'; # unique at depth 4
        } 
        return 'z';
      } 
      return '_';
    } 
    if ($att{'R1'} eq 'G') { 
      return 's'; # unique at depth 2
    } 
    if ($att{'R1'} eq 'P') { 
      if ($att{'L3'} eq 'E') { 
        return 'a'; # unique at depth 3
      } 
      return 's';
    } 
    if ($att{'R1'} eq 'B') { 
      return 's'; # unique at depth 2
    } 
    if ($att{'R1'} eq 'M') { 
      if ($att{'L2'} eq 'T') { 
        if ($att{'L3'} eq 'O') { 
          return 'i'; # unique at depth 4
        } 
        return 's';
      } 
      return 's';
    } 
    if ($att{'R1'} eq 'S') { 
      if ($att{'L3'} eq 'G') { 
        if ($att{'R3'} eq 'S') { 
          if ($att{'L2'} eq 'O') { 
            return 'a'; # unique at depth 5
          } 
          return '_';
        } 
        return 's';
      } 
      if ($att{'L3'} eq 'A') { 
        if ($att{'R3'} eq 'N') { 
          if ($att{'L2'} eq 'R') { 
            return '_'; # unique at depth 5
          } 
          return 's';
        } 
        return 's';
      } 
      if ($att{'L3'} eq 'L') { 
        if ($att{'R3'} eq '1') { 
          return 'e'; # unique at depth 4
        } 
        return 's';
      } 
      if ($att{'L3'} eq 'H') { 
        if ($att{'R3'} eq 'M') { 
          return '_'; # unique at depth 4
        } 
        return 's';
      } 
      if ($att{'L3'} eq 'N') { 
        if ($att{'R3'} eq 'B') { 
          if ($att{'L2'} eq 'L') { 
            return 's'; # unique at depth 5
          } 
          return '_';
        } 
        return 's';
      } 
      if ($att{'L3'} eq 'R') { 
        if ($att{'L2'} eq 'N') { 
          return '_'; # unique at depth 4
        } 
        if ($att{'L2'} eq 'O') { 
          if ($att{'R3'} eq 'N') { 
            return '_'; # unique at depth 5
          } 
          if ($att{'R3'} eq 'M') { 
            return 'a'; # unique at depth 5
          } 
          if ($att{'R3'} eq '1') { 
            return 'a'; # unique at depth 5
          } 
          return 's';
        } 
        return 's';
      } 
      if ($att{'L3'} eq '-') { 
        if ($att{'R3'} eq '2') { 
          return '_'; # unique at depth 4
        } 
        if ($att{'R3'} eq 'Y') { 
          if ($att{'R2'} eq 'U') { 
            return '_'; # unique at depth 5
          } 
          return 's';
        } 
        if ($att{'R3'} eq 'P') { 
          if ($att{'L2'} eq 'D') { 
            return '_'; # unique at depth 5
          } 
          return 's';
        } 
        if ($att{'R3'} eq 'R') { 
          if ($att{'R2'} eq 'U') { 
            if ($att{'L2'} eq '-') { 
              return 's'; # unique at depth 6
            } 
            return '_';
          } 
          return 's';
        } 
        if ($att{'R3'} eq 'B') { 
          return '_'; # unique at depth 4
        } 
        if ($att{'R3'} eq 'M') { 
          if ($att{'R2'} eq 'I') { 
            if ($att{'L1'} eq 'I') { 
              if ($att{'L2'} eq 'D') { 
                return 's'; # depth limit (1/2; 2 classes) at depth 7
              } 
              return '_';
            } 
            return 's';
          } 
          return '_';
        } 
        if ($att{'R3'} eq 'U') { 
          if ($att{'L2'} eq '-') { 
            return 's'; # unique at depth 5
          } 
          return '_';
        } 
        if ($att{'R3'} eq '1') { 
          if ($att{'L2'} eq 'P') { 
            if ($att{'R2'} eq 'E') { 
              if ($att{'L1'} eq 'O') { 
                return '_'; # depth limit (1/2; 2 classes) at depth 7
              } 
              return 's';
            } 
            return '_';
          } 
          if ($att{'L2'} eq 'F') { 
            return '_'; # unique at depth 5
          } 
          return 's';
        } 
        if ($att{'R3'} eq 'I') { 
          if ($att{'R2'} eq 'A') { 
            if ($att{'L2'} eq '-') { 
              return '_'; # unique at depth 6
            } 
            return 's';
          } 
          return 's';
        } 
        return 's';
      } 
      if ($att{'L3'} eq 'O') { 
        if ($att{'L2'} eq 'L') { 
          return '_'; # unique at depth 4
        } 
        return 's';
      } 
      if ($att{'L3'} eq 'C') { 
        if ($att{'R3'} eq 'S') { 
          if ($att{'L1'} eq 'E') { 
            return '_'; # unique at depth 5
          } 
          return 's';
        } 
        return 's';
      } 
      if ($att{'L3'} eq 'M') { 
        if ($att{'R2'} eq 'E') { 
          return '_'; # unique at depth 4
        } 
        if ($att{'R2'} eq 'O') { 
          return 'a'; # unique at depth 4
        } 
        return 's';
      } 
      if ($att{'L3'} eq 'S') { 
        if ($att{'L1'} eq 'E') { 
          if ($att{'L2'} eq 'T') { 
            return 's'; # unique at depth 5
          } 
          return '_';
        } 
        return 's';
      } 
      if ($att{'L3'} eq 'B') { 
        if ($att{'R3'} eq 'N') { 
          if ($att{'L2'} eq 'R') { 
            return 's'; # unique at depth 5
          } 
          return 'a';
        } 
        if ($att{'R3'} eq 'R') { 
          if ($att{'L2'} eq 'L') { 
            return '_'; # unique at depth 5
          } 
          return 's';
        } 
        if ($att{'R3'} eq 'S') { 
          return '_'; # unique at depth 4
        } 
        if ($att{'R3'} eq '-') { 
          return '_'; # unique at depth 4
        } 
        return 's';
      } 
      if ($att{'L3'} eq 'F') { 
        if ($att{'L2'} eq 'A') { 
          return '_'; # unique at depth 4
        } 
        return 's';
      } 
      if ($att{'L3'} eq '3') { 
        if ($att{'R3'} eq '-') { 
          if ($att{'L1'} eq 'I') { 
            return '_'; # unique at depth 5
          } 
          return 's';
        } 
        return 's';
      } 
      return 's';
    } 
    if ($att{'R1'} eq 'C') { 
      return 's'; # unique at depth 2
    } 
    if ($att{'R1'} eq 'T') { 
      if ($att{'L2'} eq 'X') { 
        if ($att{'R3'} eq '1') { 
          return 'i'; # unique at depth 4
        } 
        return 'z';
      } 
      return 's';
    } 
    if ($att{'R1'} eq 'U') { 
      if ($att{'L1'} eq 'E') { 
        return 'z'; # unique at depth 3
      } 
      if ($att{'L1'} eq 'A') { 
        return 'z'; # unique at depth 3
      } 
      if ($att{'L1'} eq 'S') { 
        if ($att{'L3'} eq 'R') { 
          return 's'; # unique at depth 4
        } 
        if ($att{'L3'} eq '-') { 
          if ($att{'R2'} eq 'Y') { 
            return 's'; # unique at depth 5
          } 
          return '_';
        } 
        return '_';
      } 
      if ($att{'L1'} eq '1') { 
        return 'z'; # unique at depth 3
      } 
      if ($att{'L1'} eq 'U') { 
        return 'z'; # unique at depth 3
      } 
      return 's';
    } 
    if ($att{'R1'} eq 'O') { 
      if ($att{'L1'} eq 'E') { 
        return 'z'; # unique at depth 3
      } 
      if ($att{'L1'} eq 'I') { 
        return 'z'; # unique at depth 3
      } 
      if ($att{'L1'} eq 'S') { 
        if ($att{'L3'} eq 'D') { 
          return 's'; # unique at depth 4
        } 
        if ($att{'L3'} eq 'R') { 
          if ($att{'R2'} eq 'U') { 
            return 's'; # unique at depth 5
          } 
          return '_';
        } 
        if ($att{'L3'} eq 'O') { 
          return 's'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'L1'} eq '1') { 
        return 'z'; # unique at depth 3
      } 
      if ($att{'L1'} eq 'O') { 
        return 'z'; # unique at depth 3
      } 
      return 's';
    } 
    if ($att{'R1'} eq '-') { 
      if ($att{'L2'} eq 'O') { 
        if ($att{'L1'} eq 'I') { 
          return 'a'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'L2'} eq 'S') { 
        if ($att{'L3'} eq 'A') { 
          if ($att{'L1'} eq 'I') { 
            return 's'; # unique at depth 5
          } 
          return '_';
        } 
        return '_';
      } 
      if ($att{'L2'} eq 'C') { 
        if ($att{'L1'} eq 'U') { 
          return '_'; # unique at depth 4
        } 
        if ($att{'L1'} eq 'T') { 
          return '_'; # unique at depth 4
        } 
        if ($att{'L1'} eq 'I') { 
          return '_'; # unique at depth 4
        } 
        if ($att{'L1'} eq 'E') { 
          if ($att{'L3'} eq '-') { 
            return '_'; # unique at depth 5
          } 
          return 's';
        } 
        return 's';
      } 
      if ($att{'L2'} eq 'T') { 
        if ($att{'L3'} eq 'C') { 
          return 's'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'L2'} eq 'B') { 
        if ($att{'L3'} eq '-') { 
          return 's'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'L2'} eq 'I') { 
        if ($att{'L1'} eq '4') { 
          return 's'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'L2'} eq 'A') { 
        if ($att{'L3'} eq 'G') { 
          return 'e'; # unique at depth 4
        } 
        if ($att{'L3'} eq 'I') { 
          return 'E'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'L2'} eq 'E') { 
        if ($att{'L3'} eq 'J') { 
          return 't'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'L2'} eq 'N') { 
        if ($att{'L3'} eq '1') { 
          return 's'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'L2'} eq 'L') { 
        if ($att{'L3'} eq '-') { 
          if ($att{'L1'} eq 'I') { 
            return 's'; # unique at depth 5
          } 
          return '_';
        } 
        return '_';
      } 
      if ($att{'L2'} eq 'R') { 
        if ($att{'L1'} eq 'I') { 
          if ($att{'L3'} eq 'I') { 
            return 's'; # unique at depth 5
          } 
          return '_';
        } 
        return '_';
      } 
      if ($att{'L2'} eq 'X') { 
        if ($att{'L3'} eq 'E') { 
          return 's'; # unique at depth 4
        } 
        return 'i';
      } 
      return '_';
    } 
    if ($att{'R1'} eq 'Q') { 
      if ($att{'L3'} eq 'R') { 
        return '_'; # unique at depth 3
      } 
      return 's';
    } 
    if ($att{'R1'} eq 'F') { 
      return 's'; # unique at depth 2
    } 
    if ($att{'R1'} eq 'I') { 
      if ($att{'L1'} eq 'R') { 
        return 's'; # unique at depth 3
      } 
      if ($att{'L1'} eq 'L') { 
        return 's'; # unique at depth 3
      } 
      if ($att{'L1'} eq 'N') { 
        if ($att{'L3'} eq 'R') { 
          return 'z'; # unique at depth 4
        } 
        return 's';
      } 
      if ($att{'L1'} eq 'S') { 
        if ($att{'R2'} eq 'P') { 
          return 's'; # unique at depth 4
        } 
        if ($att{'R2'} eq 'M') { 
          if ($att{'R3'} eq 'U') { 
            if ($att{'L2'} eq 'I') { 
              return 's';
            } 
            return '_';
          } 
          return 's';
        } 
        return '_';
      } 
      if ($att{'L1'} eq '-') { 
        return 's'; # unique at depth 3
      } 
      if ($att{'L1'} eq 'O') { 
        if ($att{'L2'} eq 'L') { 
          return 'O'; # unique at depth 4
        } 
        return 'z';
      } 
      if ($att{'L1'} eq 'U') { 
        if ($att{'R2'} eq 'V') { 
          return 'y'; # unique at depth 4
        } 
        return 'z';
      } 
      return 'z';
    } 
    return '_';
  } 
  if ($att{'L'} eq 'L') { 
    if ($att{'L1'} eq 'P') { 
      if ($att{'L2'} eq 'X') { 
        return 'p'; # unique at depth 3
      } 
      if ($att{'L2'} eq 'P') { 
        if ($att{'R3'} eq '-') { 
          return 'i'; # unique at depth 4
        } 
        return 'l';
      } 
      return 'l';
    } 
    if ($att{'L1'} eq 'E') { 
      if ($att{'L2'} eq 'O') { 
        if ($att{'R3'} eq '-') { 
          return 'a'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'L2'} eq 'U') { 
        if ($att{'R3'} eq 'S') { 
          if ($att{'L3'} eq 'T') { 
            return 'l'; # unique at depth 5
          } 
          return '_';
        } 
        return 'l';
      } 
      if ($att{'L2'} eq 'C') { 
        if ($att{'L3'} eq 'N') { 
          return '_'; # unique at depth 4
        } 
        if ($att{'L3'} eq 'R') { 
          if ($att{'R1'} eq 'L') { 
            return '_'; # unique at depth 5
          } 
          return 'l';
        } 
        return 'l';
      } 
      if ($att{'L2'} eq 'T') { 
        if ($att{'R3'} eq 'G') { 
          return '_'; # unique at depth 4
        } 
        if ($att{'R3'} eq 'C') { 
          return '_'; # unique at depth 4
        } 
        return 'l';
      } 
      if ($att{'L2'} eq 'B') { 
        if ($att{'L3'} eq 'U') { 
          return '_'; # unique at depth 4
        } 
        return 'l';
      } 
      if ($att{'L2'} eq 'I') { 
        if ($att{'R2'} eq 'E') { 
          if ($att{'L3'} eq 'C') { 
            return 'l'; # unique at depth 5
          } 
          return '_';
        } 
        return 'l';
      } 
      if ($att{'L2'} eq 'N') { 
        if ($att{'L3'} eq 'A') { 
          return '_'; # unique at depth 4
        } 
        if ($att{'L3'} eq 'N') { 
          if ($att{'R2'} eq 'E') { 
            if ($att{'R3'} eq '-') { 
              if ($att{'R1'} eq 'L') { 
                return 'l'; # depth limit (1/2; 2 classes) at depth 7
              } 
              return '_';
            } 
            return 'l';
          } 
          return 'l';
        } 
        return 'l';
      } 
      return 'l';
    } 
    if ($att{'L1'} eq 'L') { 
      if ($att{'L3'} eq 'N') { 
        if ($att{'R2'} eq '-') { 
          if ($att{'R3'} eq '-') { 
            if ($att{'R1'} eq 'E') { 
              return '_';
            } 
            return 'l';
          } 
          return 'l';
        } 
        return '_';
      } 
      if ($att{'L3'} eq '-') { 
        if ($att{'R2'} eq 'M') { 
          return '_'; # unique at depth 4
        } 
        if ($att{'R2'} eq 'S') { 
          if ($att{'L2'} eq 'I') { 
            return '_'; # unique at depth 5
          } 
          return 'l';
        } 
        return 'l';
      } 
      if ($att{'L3'} eq 'V') { 
        if ($att{'R1'} eq 'A') { 
          return 'l'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'L3'} eq 'O') { 
        return 'l'; # unique at depth 3
      } 
      if ($att{'L3'} eq 'U') { 
        if ($att{'R2'} eq 'G') { 
          if ($att{'R3'} eq 'E') { 
            if ($att{'R1'} eq 'A') { 
              if ($att{'L2'} eq 'I') { 
                return 'j'; # depth limit (1/2; 2 classes) at depth 7
              } 
              return '_';
            } 
            return '_';
          } 
          return '_';
        } 
        if ($att{'R2'} eq 'S') { 
          if ($att{'L2'} eq 'E') { 
            if ($att{'R3'} eq '-') { 
              if ($att{'R1'} eq 'E') { 
                return 'l'; # depth limit (1/2; 2 classes) at depth 7
              } 
              return '_';
            } 
            return 'l';
          } 
          return '_';
        } 
        return '_';
      } 
      if ($att{'L3'} eq 'C') { 
        if ($att{'R3'} eq 'L') { 
          return 'l'; # unique at depth 4
        } 
        if ($att{'R3'} eq '-') { 
          if ($att{'L2'} eq 'E') { 
            return 'l';
          } 
          return '_';
        } 
        return '_';
      } 
      if ($att{'L3'} eq 'T') { 
        if ($att{'R2'} eq 'G') { 
          return 'l'; # unique at depth 4
        } 
        if ($att{'R2'} eq 'C') { 
          return 'l'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'L3'} eq 'S') { 
        if ($att{'L2'} eq 'Y') { 
          return 'l'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'L3'} eq 'B') { 
        if ($att{'L2'} eq 'E') { 
          return 'l'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'L3'} eq 'I') { 
        if ($att{'R3'} eq 'E') { 
          if ($att{'R2'} eq 'M') { 
            if ($att{'R1'} eq 'E') { 
              return 'l';
            } 
            return '_';
          } 
          return '_';
        } 
        return 'l';
      } 
      return '_';
    } 
    if ($att{'L1'} eq 'A') { 
      if ($att{'L2'} eq '-') { 
        if ($att{'R3'} eq '2') { 
          return '_'; # unique at depth 4
        } 
        if ($att{'R3'} eq 'N') { 
          if ($att{'R1'} eq 'I') { 
            return 'l'; # unique at depth 5
          } 
          return '_';
        } 
        if ($att{'R3'} eq 'E') { 
          if ($att{'R1'} eq 'L') { 
            return '_'; # unique at depth 5
          } 
          return 'l';
        } 
        if ($att{'R3'} eq 'R') { 
          if ($att{'R1'} eq 'T') { 
            return 'l'; # unique at depth 5
          } 
          return '_';
        } 
        if ($att{'R3'} eq 'S') { 
          return '_'; # unique at depth 4
        } 
        return 'l';
      } 
      if ($att{'L2'} eq 'X') { 
        return 'a'; # unique at depth 3
      } 
      return 'l';
    } 
    if ($att{'L1'} eq 'I') { 
      if ($att{'L2'} eq 'V') { 
        if ($att{'L3'} eq 'A') { 
          return '_'; # unique at depth 4
        } 
        if ($att{'L3'} eq 'E') { 
          return 'j'; # unique at depth 4
        } 
        return 'l';
      } 
      if ($att{'L2'} eq 'O') { 
        return 'l'; # unique at depth 3
      } 
      if ($att{'L2'} eq '-') { 
        return 'l'; # unique at depth 3
      } 
      if ($att{'L2'} eq 'U') { 
        if ($att{'L3'} eq 'C') { 
          return 'j'; # unique at depth 4
        } 
        if ($att{'L3'} eq 'Q') { 
          if ($att{'R3'} eq 'G') { 
            if ($att{'R2'} eq 'A') { 
              if ($att{'R1'} eq 'L') { 
                return '_'; # depth limit (1/2; 2 classes) at depth 7
              } 
              return 'j';
            } 
            return 'j';
          } 
          return '_';
        } 
        return '_';
      } 
      if ($att{'L2'} eq 'M') { 
        return 'l'; # unique at depth 3
      } 
      if ($att{'L2'} eq 'S') { 
        if ($att{'R2'} eq 'N') { 
          return 'l'; # unique at depth 4
        } 
        if ($att{'R2'} eq 'O') { 
          return '_'; # unique at depth 4
        } 
        return 'j';
      } 
      if ($att{'L2'} eq 'C') { 
        if ($att{'L3'} eq 'R') { 
          return '_'; # unique at depth 4
        } 
        return 'l';
      } 
      if ($att{'L2'} eq 'T') { 
        if ($att{'R1'} eq '-') { 
          return '_'; # unique at depth 4
        } 
        if ($att{'R1'} eq 'H') { 
          return 'j'; # unique at depth 4
        } 
        if ($att{'R1'} eq 'L') { 
          return 'j'; # unique at depth 4
        } 
        return 'l';
      } 
      if ($att{'L2'} eq 'B') { 
        if ($att{'R2'} eq 'E') { 
          if ($att{'L3'} eq 'O') { 
            return 'l'; # unique at depth 5
          } 
          return 'j';
        } 
        if ($att{'R2'} eq 'A') { 
          if ($att{'L3'} eq 'A') { 
            return '_'; # unique at depth 5
          } 
          return 'j';
        } 
        if ($att{'R2'} eq 'O') { 
          return '_'; # unique at depth 4
        } 
        return 'l';
      } 
      if ($att{'L2'} eq 'F') { 
        if ($att{'R1'} eq 'L') { 
          return 'j'; # unique at depth 4
        } 
        return 'l';
      } 
      if ($att{'L2'} eq 'K') { 
        return 'l'; # unique at depth 3
      } 
      if ($att{'L2'} eq 'G') { 
        return 'l'; # unique at depth 3
      } 
      if ($att{'L2'} eq 'D') { 
        return 'j'; # unique at depth 3
      } 
      if ($att{'L2'} eq 'H') { 
        return 'l'; # unique at depth 3
      } 
      if ($att{'L2'} eq 'L') { 
        return 'l'; # unique at depth 3
      } 
      if ($att{'L2'} eq 'R') { 
        if ($att{'R1'} eq 'I') { 
          return 'l'; # unique at depth 4
        } 
        if ($att{'R1'} eq 'E') { 
          return 'l'; # unique at depth 4
        } 
        return 'j';
      } 
      if ($att{'L2'} eq 'P') { 
        if ($att{'L3'} eq 'A') { 
          return '_'; # unique at depth 4
        } 
        return 'l';
      } 
      return '_';
    } 
    if ($att{'L1'} eq 'C') { 
      if ($att{'L2'} eq 'X') { 
        return 'k'; # unique at depth 3
      } 
      return 'l';
    } 
    if ($att{'L1'} eq 'S') { 
      if ($att{'L3'} eq 'L') { 
        return '_'; # unique at depth 3
      } 
      return 'l';
    } 
    if ($att{'L1'} eq 'B') { 
      if ($att{'L3'} eq 'Y') { 
        return 'b'; # unique at depth 3
      } 
      if ($att{'L3'} eq 'X') { 
        return 'b'; # unique at depth 3
      } 
      if ($att{'L3'} eq 'O') { 
        if ($att{'R2'} eq 'A') { 
          if ($att{'R3'} eq '-') { 
            return 'i'; # unique at depth 5
          } 
          return 'l';
        } 
        return 'l';
      } 
      if ($att{'L3'} eq 'M') { 
        if ($att{'R2'} eq 'S') { 
          return 'l'; # unique at depth 4
        } 
        return 'b';
      } 
      return 'l';
    } 
    if ($att{'L1'} eq 'U') { 
      if ($att{'R1'} eq 'S') { 
        if ($att{'L3'} eq 'P') { 
          return '_'; # unique at depth 4
        } 
        return 'l';
      } 
      return 'l';
    } 
    return 'l';
  } 
  if ($att{'L'} eq 'H') { 
    if ($att{'L1'} eq '1') { 
      return '_'; # unique at depth 2
    } 
    if ($att{'L1'} eq '-') { 
      if ($att{'R2'} eq 'I') { 
        if ($att{'R3'} eq 'N') { 
          return 'h'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'R2'} eq 'L') { 
        if ($att{'R3'} eq 'O') { 
          return '_'; # unique at depth 4
        } 
        if ($att{'R3'} eq 'E') { 
          if ($att{'R1'} eq 'A') { 
            if ($att{'L2'} eq '-') { 
              return 'h';
            } 
            return '_';
          } 
          return 'h';
        } 
        return 'h';
      } 
      if ($att{'R2'} eq 'N') { 
        if ($att{'R3'} eq 'T') { 
          if ($att{'R1'} eq 'O') { 
            return 'h'; # unique at depth 5
          } 
          return '_';
        } 
        return '_';
      } 
      return '_';
    } 
    if ($att{'L1'} eq 'O') { 
      return '_'; # unique at depth 2
    } 
    if ($att{'L1'} eq 'U') { 
      return '_'; # unique at depth 2
    } 
    if ($att{'L1'} eq 'T') { 
      return '_'; # unique at depth 2
    } 
    if ($att{'L1'} eq 'C') { 
      if ($att{'R2'} eq 'O') { 
        if ($att{'L3'} eq 'A') { 
          return 'S'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'R2'} eq 'I') { 
        if ($att{'R1'} eq 'N') { 
          return '_'; # unique at depth 4
        } 
        if ($att{'R1'} eq 'R') { 
          return '_'; # unique at depth 4
        } 
        return 'S';
      } 
      if ($att{'R2'} eq 'A') { 
        return '_'; # unique at depth 3
      } 
      if ($att{'R2'} eq 'L') { 
        if ($att{'L3'} eq 'S') { 
          return '_'; # unique at depth 4
        } 
        return 'S';
      } 
      if ($att{'R2'} eq 'E') { 
        if ($att{'R1'} eq 'R') { 
          return '_'; # unique at depth 4
        } 
        return 'S';
      } 
      return 'S';
    } 
    if ($att{'L1'} eq 'S') { 
      if ($att{'L3'} eq 'E') { 
        return '_'; # unique at depth 3
      } 
      return 'S';
    } 
    if ($att{'L1'} eq 'K') { 
      return '_'; # unique at depth 2
    } 
    if ($att{'L1'} eq 'A') { 
      return '_'; # unique at depth 2
    } 
    if ($att{'L1'} eq 'E') { 
      return '_'; # unique at depth 2
    } 
    if ($att{'L1'} eq 'L') { 
      return '_'; # unique at depth 2
    } 
    if ($att{'L1'} eq 'N') { 
      return '_'; # unique at depth 2
    } 
    if ($att{'L1'} eq 'R') { 
      return '_'; # unique at depth 2
    } 
    if ($att{'L1'} eq 'P') { 
      return 'f'; # unique at depth 2
    } 
    return 'S';
  } 
  if ($att{'L'} eq '2') { 
    if ($att{'L1'} eq 'A') { 
      return '_'; # unique at depth 2
    } 
    return 'E';
  } 
  if ($att{'L'} eq 'N') { 
    if ($att{'L1'} eq 'G') { 
      if ($att{'L3'} eq 'P') { 
        if ($att{'L2'} eq 'I') { 
          return 'O~'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'L3'} eq 'O') { 
        if ($att{'R1'} eq 'A') { 
          if ($att{'R2'} eq 'N') { 
            return '_';
          } 
          return 'J';
        } 
        if ($att{'R1'} eq 'O') { 
          if ($att{'L2'} eq 'I') { 
            return 'O~'; # unique at depth 5
          } 
          return '_';
        } 
        return 'J';
      } 
      return '_';
    } 
    if ($att{'L1'} eq 'A') { 
      if ($att{'R1'} eq 'E') { 
        return 'n'; # unique at depth 3
      } 
      if ($att{'R1'} eq 'N') { 
        return 'n'; # unique at depth 3
      } 
      if ($att{'R1'} eq 'A') { 
        return 'n'; # unique at depth 3
      } 
      if ($att{'R1'} eq 'I') { 
        return 'n'; # unique at depth 3
      } 
      if ($att{'R1'} eq 'C') { 
        if ($att{'L2'} eq 'Y') { 
          if ($att{'R3'} eq 'S') { 
            return 'j'; # unique at depth 5
          } 
          return 'A~';
        } 
        return 'A~';
      } 
      if ($att{'R1'} eq 'T') { 
        if ($att{'R2'} eq 'E') { 
          if ($att{'R3'} eq 'N') { 
            return '_'; # unique at depth 5
          } 
          return 'A~';
        } 
        if ($att{'R2'} eq 'H') { 
          return 'A~'; # unique at depth 4
        } 
        if ($att{'R2'} eq 'A') { 
          return 'A~'; # unique at depth 4
        } 
        if ($att{'R2'} eq 'I') { 
          return 'A~'; # unique at depth 4
        } 
        if ($att{'R2'} eq 'S') { 
          if ($att{'L3'} eq 'S') { 
            return 's'; # unique at depth 5
          } 
          return '_';
        } 
        if ($att{'R2'} eq '-') { 
          if ($att{'L2'} eq 'N') { 
            if ($att{'L3'} eq 'N') { 
              return 'n'; # unique at depth 6
            } 
            return '_';
          } 
          if ($att{'L2'} eq 'Y') { 
            if ($att{'L3'} eq 'E') { 
              return '_'; # unique at depth 6
            } 
            return 'j';
          } 
          if ($att{'L2'} eq 'R') { 
            if ($att{'L3'} eq '1') { 
              return 'A~';
            } 
            return '_';
          } 
          if ($att{'L2'} eq 'I') { 
            if ($att{'L3'} eq 'L') { 
              return 'j'; # unique at depth 6
            } 
            return '_';
          } 
          return '_';
        } 
        if ($att{'R2'} eq 'O') { 
          return 'A~'; # unique at depth 4
        } 
        if ($att{'R2'} eq 'U') { 
          return 'A~'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'R1'} eq '-') { 
        if ($att{'L3'} eq 'J') { 
          return 'n'; # unique at depth 4
        } 
        if ($att{'L3'} eq 'R') { 
          return 'n'; # unique at depth 4
        } 
        return 'A~';
      } 
      if ($att{'R1'} eq 'O') { 
        return 'n'; # unique at depth 3
      } 
      if ($att{'R1'} eq 'U') { 
        return 'n'; # unique at depth 3
      } 
      return 'A~';
    } 
    if ($att{'L1'} eq 'Y') { 
      if ($att{'L2'} eq 'S') { 
        return 'E~'; # unique at depth 3
      } 
      return 'n';
    } 
    if ($att{'L1'} eq 'E') { 
      if ($att{'R2'} eq 'I') { 
        if ($att{'R1'} eq 'D') { 
          if ($att{'L3'} eq 'T') { 
            return '_'; # unique at depth 5
          } 
          return 'A~';
        } 
        if ($att{'R1'} eq 'N') { 
          return 'a'; # unique at depth 4
        } 
        if ($att{'R1'} eq 'A') { 
          if ($att{'R3'} eq 'E') { 
            if ($att{'L2'} eq 'R') { 
              if ($att{'L3'} eq 'P') { 
                return 'n'; # depth limit (1/2; 2 classes) at depth 7
              } 
              return '_';
            } 
            if ($att{'L2'} eq 'V') { 
              return 'n'; # unique at depth 6
            } 
            return '_';
          } 
          return 'n';
        } 
        if ($att{'R1'} eq 'T') { 
          if ($att{'L2'} eq 'M') { 
            return '_'; # unique at depth 5
          } 
          if ($att{'L2'} eq 'T') { 
            return '_'; # unique at depth 5
          } 
          if ($att{'L2'} eq 'V') { 
            return '_'; # unique at depth 5
          } 
          return 'A~';
        } 
        return 'A~';
      } 
      if ($att{'R2'} eq '5') { 
        return 'A~'; # unique at depth 3
      } 
      if ($att{'R2'} eq '1') { 
        return 'n'; # unique at depth 3
      } 
      if ($att{'R2'} eq '-') { 
        if ($att{'R1'} eq 'D') { 
          return 'A~'; # unique at depth 4
        } 
        if ($att{'R1'} eq 'A') { 
          return 'n'; # unique at depth 4
        } 
        if ($att{'R1'} eq 'T') { 
          if ($att{'L3'} eq 'N') { 
            if ($att{'L2'} eq 'N') { 
              if ($att{'R3'} eq '-') { 
                return 'n'; # depth limit (1/2; 2 classes) at depth 7
              } 
              return '_';
            } 
            return '_';
          } 
          if ($att{'L3'} eq 'P') { 
            if ($att{'L2'} eq 'P') { 
              return '_'; # unique at depth 6
            } 
            return 'O~';
          } 
          if ($att{'L3'} eq 'T') { 
            if ($att{'L2'} eq 'I') { 
              if ($att{'R3'} eq '-') { 
                return 'E~'; # depth limit (2/4; 2 classes) at depth 7
              } 
              return '_';
            } 
            return '_';
          } 
          return '_';
        } 
        if ($att{'R1'} eq 'S') { 
          if ($att{'L3'} eq '-') { 
            return 'A~'; # unique at depth 5
          } 
          if ($att{'L3'} eq '1') { 
            return 'A~'; # unique at depth 5
          } 
          if ($att{'L3'} eq 'N') { 
            return 'A~'; # unique at depth 5
          } 
          return 'E~';
        } 
        if ($att{'R1'} eq '-') { 
          return 'E~'; # unique at depth 4
        } 
        if ($att{'R1'} eq 'U') { 
          return 'n'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'R2'} eq 'O') { 
        if ($att{'L2'} eq 'V') { 
          return 'n'; # unique at depth 4
        } 
        if ($att{'L2'} eq 'M') { 
          return 'E~'; # unique at depth 4
        } 
        if ($att{'L2'} eq 'T') { 
          if ($att{'L3'} eq 'T') { 
            return '_'; # unique at depth 5
          } 
          return 'A~';
        } 
        return 'A~';
      } 
      if ($att{'R2'} eq 'U') { 
        if ($att{'L2'} eq 'M') { 
          return 'n'; # unique at depth 4
        } 
        if ($att{'L2'} eq 'T') { 
          if ($att{'L3'} eq 'T') { 
            return '_'; # unique at depth 5
          } 
          return 'A~';
        } 
        if ($att{'L2'} eq 'R') { 
          return 'n'; # unique at depth 4
        } 
        if ($att{'L2'} eq 'G') { 
          return 'n'; # unique at depth 4
        } 
        return 'A~';
      } 
      if ($att{'R2'} eq 'T') { 
        return 'n'; # unique at depth 3
      } 
      if ($att{'R2'} eq 'C') { 
        return 'n'; # unique at depth 3
      } 
      if ($att{'R2'} eq 'S') { 
        if ($att{'R1'} eq 'D') { 
          return 'A~'; # unique at depth 4
        } 
        if ($att{'R1'} eq 'U') { 
          return 'n'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'R2'} eq 'B') { 
        return 'n'; # unique at depth 3
      } 
      if ($att{'R2'} eq 'R') { 
        if ($att{'L3'} eq 'T') { 
          if ($att{'L2'} eq 'I') { 
            return 'E~'; # unique at depth 5
          } 
          return '_';
        } 
        if ($att{'L3'} eq 'V') { 
          return 'E~'; # unique at depth 4
        } 
        if ($att{'L3'} eq 'R') { 
          return 'n'; # unique at depth 4
        } 
        if ($att{'L3'} eq 'E') { 
          return 'n'; # unique at depth 4
        } 
        if ($att{'L3'} eq 'N') { 
          if ($att{'L2'} eq 'V') { 
            return 'n'; # unique at depth 5
          } 
          return 'A~';
        } 
        return 'A~';
      } 
      if ($att{'R2'} eq 'Z') { 
        return 'n'; # unique at depth 3
      } 
      if ($att{'R2'} eq 'A') { 
        if ($att{'L3'} eq 'T') { 
          return '_'; # unique at depth 4
        } 
        return 'A~';
      } 
      if ($att{'R2'} eq 'D') { 
        return 'n'; # unique at depth 3
      } 
      if ($att{'R2'} eq 'E') { 
        if ($att{'R1'} eq 'N') { 
          if ($att{'L3'} eq 'S') { 
            return '_'; # unique at depth 5
          } 
          if ($att{'L3'} eq 'T') { 
            if ($att{'R3'} eq '-') { 
              return 'n'; # unique at depth 6
            } 
            return '_';
          } 
          if ($att{'L3'} eq 'O') { 
            if ($att{'L2'} eq 'L') { 
              return 'a'; # unique at depth 6
            } 
            return 'E';
          } 
          return 'n';
        } 
        if ($att{'R1'} eq 'U') { 
          return 'n'; # unique at depth 4
        } 
        if ($att{'R1'} eq 'V') { 
          if ($att{'L3'} eq 'B') { 
            return 'E~'; # unique at depth 5
          } 
          return 'A~';
        } 
        if ($att{'R1'} eq 'I') { 
          return 'n'; # unique at depth 4
        } 
        return 'A~';
      } 
      if ($att{'R2'} eq 'H') { 
        return 'A~'; # unique at depth 3
      } 
      if ($att{'R2'} eq 'L') { 
        if ($att{'L3'} eq '-') { 
          return 'A~'; # unique at depth 4
        } 
        return 'n';
      } 
      if ($att{'R2'} eq 'N') { 
        return 'n'; # unique at depth 3
      } 
      return '_';
    } 
    if ($att{'L1'} eq 'L') { 
      return 'n'; # unique at depth 2
    } 
    if ($att{'L1'} eq 'H') { 
      return 'n'; # unique at depth 2
    } 
    if ($att{'L1'} eq '2') { 
      return 'n'; # unique at depth 2
    } 
    if ($att{'L1'} eq 'N') { 
      if ($att{'R3'} eq 'E') { 
        if ($att{'L2'} eq 'E') { 
          return 'n'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'R3'} eq 'L') { 
        if ($att{'L3'} eq 'L') { 
          return 'n'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'R3'} eq '-') { 
        if ($att{'L3'} eq 'I') { 
          if ($att{'R2'} eq 'R') { 
            return 'n'; # unique at depth 5
          } 
          if ($att{'R2'} eq '-') { 
            if ($att{'L2'} eq 'O') { 
              return 'n'; # unique at depth 6
            } 
            return '_';
          } 
          if ($att{'R2'} eq '1') { 
            return 'n'; # unique at depth 5
          } 
          return '_';
        } 
        if ($att{'L3'} eq 'S') { 
          if ($att{'R2'} eq '-') { 
            return '_'; # unique at depth 5
          } 
          if ($att{'R2'} eq '1') { 
            return '_'; # unique at depth 5
          } 
          return 'n';
        } 
        if ($att{'L3'} eq 'Y') { 
          return 'n'; # unique at depth 4
        } 
        if ($att{'L3'} eq 'D') { 
          if ($att{'R2'} eq '1') { 
            return '_';
          } 
          return 'n';
        } 
        return '_';
      } 
      if ($att{'R3'} eq 'C') { 
        return 'O~'; # unique at depth 3
      } 
      return '_';
    } 
    if ($att{'L1'} eq '4') { 
      return 'n'; # unique at depth 2
    } 
    if ($att{'L1'} eq 'R') { 
      return 'n'; # unique at depth 2
    } 
    if ($att{'L1'} eq 'X') { 
      return 'n'; # unique at depth 2
    } 
    if ($att{'L1'} eq 'P') { 
      return 'n'; # unique at depth 2
    } 
    if ($att{'L1'} eq '-') { 
      return 'n'; # unique at depth 2
    } 
    if ($att{'L1'} eq '1') { 
      return 'n'; # unique at depth 2
    } 
    if ($att{'L1'} eq 'O') { 
      if ($att{'R1'} eq 'A') { 
        return 'n'; # unique at depth 3
      } 
      if ($att{'R1'} eq 'N') { 
        if ($att{'L3'} eq 'I') { 
          if ($att{'R3'} eq 'R') { 
            return '_'; # unique at depth 5
          } 
          return 'n';
        } 
        if ($att{'L3'} eq 'S') { 
          if ($att{'R3'} eq 'L') { 
            return 'n'; # unique at depth 5
          } 
          return '_';
        } 
        if ($att{'L3'} eq 'T') { 
          if ($att{'R3'} eq 'R') { 
            return '_'; # unique at depth 5
          } 
          if ($att{'R3'} eq '-') { 
            return '_'; # unique at depth 5
          } 
          return 'n';
        } 
        if ($att{'L3'} eq 'R') { 
          if ($att{'L2'} eq 'D') { 
            if ($att{'R3'} eq '1') { 
              if ($att{'R2'} eq 'E') { 
                return '_'; # depth limit (1/2; 2 classes) at depth 7
              } 
              return 'n';
            } 
            return '_';
          } 
          return 'n';
        } 
        if ($att{'L3'} eq 'N') { 
          if ($att{'R2'} eq 'A') { 
            return '_'; # unique at depth 5
          } 
          return 'n';
        } 
        return 'n';
      } 
      if ($att{'R1'} eq 'H') { 
        return 'n'; # unique at depth 3
      } 
      if ($att{'R1'} eq 'E') { 
        return 'n'; # unique at depth 3
      } 
      if ($att{'R1'} eq 'U') { 
        return 'n'; # unique at depth 3
      } 
      if ($att{'R1'} eq 'O') { 
        return 'n'; # unique at depth 3
      } 
      if ($att{'R1'} eq 'S') { 
        if ($att{'L3'} eq 'G') { 
          return '_'; # unique at depth 4
        } 
        return 'O~';
      } 
      if ($att{'R1'} eq 'C') { 
        if ($att{'R3'} eq 'A') { 
          if ($att{'L2'} eq 'N') { 
            if ($att{'L3'} eq '-') { 
              return 'O~'; # unique at depth 6
            } 
            return '_';
          } 
          return 'O~';
        } 
        return 'O~';
      } 
      if ($att{'R1'} eq 'I') { 
        return 'n'; # unique at depth 3
      } 
      return 'O~';
    } 
    if ($att{'L1'} eq 'U') { 
      if ($att{'R1'} eq 'G') { 
        if ($att{'L2'} eq 'J') { 
          return 'O~'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'R1'} eq '-') { 
        return '_'; # unique at depth 3
      } 
      if ($att{'R1'} eq 'S') { 
        return '_'; # unique at depth 3
      } 
      if ($att{'R1'} eq 'T') { 
        return '_'; # unique at depth 3
      } 
      return 'n';
    } 
    if ($att{'L1'} eq 'M') { 
      return 'n'; # unique at depth 2
    } 
    if ($att{'L1'} eq 'I') { 
      if ($att{'R1'} eq 'A') { 
        if ($att{'L2'} eq 'M') { 
          if ($att{'L3'} eq 'A') { 
            return 'm'; # unique at depth 5
          } 
          return 'n';
        } 
        if ($att{'L2'} eq 'D') { 
          return 'i';
        } 
        return 'n';
      } 
      if ($att{'R1'} eq 'N') { 
        return 'n'; # unique at depth 3
      } 
      if ($att{'R1'} eq 'E') { 
        if ($att{'L3'} eq 'A') { 
          if ($att{'L2'} eq 'M') { 
            return 'i'; # unique at depth 5
          } 
          return 'n';
        } 
        return 'n';
      } 
      if ($att{'R1'} eq 'U') { 
        return 'n'; # unique at depth 3
      } 
      if ($att{'R1'} eq 'O') { 
        return 'n'; # unique at depth 3
      } 
      if ($att{'R1'} eq 'I') { 
        if ($att{'L3'} eq 'C') { 
          return 'J'; # unique at depth 4
        } 
        return 'n';
      } 
      return '_';
    } 
    if ($att{'L1'} eq '3') { 
      return 'n'; # unique at depth 2
    } 
    return '_';
  } 
  if ($att{'L'} eq 'B') { 
    if ($att{'R1'} eq 'T') { 
      return 'p'; # unique at depth 2
    } 
    if ($att{'R1'} eq 'S') { 
      if ($att{'R3'} eq 'R') { 
        if ($att{'R2'} eq 'E') { 
          if ($att{'L1'} eq 'O') { 
            if ($att{'L2'} eq '-') { 
              if ($att{'L3'} eq '-') { 
                return 'p'; # depth limit (1/2; 2 classes) at depth 7
              } 
              return 'b';
            } 
            return 'p';
          } 
          return 'b';
        } 
        return 'p';
      } 
      if ($att{'R3'} eq 'I') { 
        return 'b'; # unique at depth 3
      } 
      return 'p';
    } 
    if ($att{'R1'} eq 'A') { 
      if ($att{'L1'} eq 'B') { 
        return '_'; # unique at depth 3
      } 
      return 'b';
    } 
    if ($att{'R1'} eq 'L') { 
      if ($att{'L2'} eq 'M') { 
        if ($att{'R3'} eq 'S') { 
          return 'b'; # unique at depth 4
        } 
        return 'a';
      } 
      if ($att{'L2'} eq 'X') { 
        return 'i'; # unique at depth 3
      } 
      if ($att{'L2'} eq 'Y') { 
        return 'a'; # unique at depth 3
      } 
      return 'b';
    } 
    return 'b';
  } 
  if ($att{'L'} eq 'g') { 
    return 'dictionary'; # unique at depth 1
  } 
  if ($att{'L'} eq '1') { 
    return 'e';
  } 
  if ($att{'L'} eq 'V') { 
    if ($att{'L3'} eq 'U') { 
      if ($att{'L2'} eq 'S') { 
        return 'i'; # unique at depth 3
      } 
      return 'v';
    } 
    return 'v';
  } 
  if ($att{'L'} eq 'O') { 
    if ($att{'R1'} eq 'I') { 
      if ($att{'R2'} eq 'T') { 
        if ($att{'L3'} eq 'X') { 
          return 'l'; # unique at depth 4
        } 
        return 'w';
      } 
      if ($att{'R2'} eq '4') { 
        return 'O'; # unique at depth 3
      } 
      if ($att{'R2'} eq 'G') { 
        if ($att{'L1'} eq '-') { 
          return 'O'; # unique at depth 4
        } 
        return 'w';
      } 
      return 'w';
    } 
    if ($att{'R1'} eq '3') { 
      if ($att{'L1'} eq 'H') { 
        if ($att{'R2'} eq 'T') { 
          return 'O'; # unique at depth 4
        } 
        return 'o';
      } 
      return 'o';
    } 
    if ($att{'R1'} eq '-') { 
      return 'o'; # unique at depth 2
    } 
    if ($att{'R1'} eq 'O') { 
      return 'u'; # unique at depth 2
    } 
    if ($att{'R1'} eq 'U') { 
      if ($att{'R2'} eq 'I') { 
        if ($att{'R3'} eq '-') { 
          if ($att{'L3'} eq 'E') { 
            return 'w'; # unique at depth 5
          } 
          return '_';
        } 
        if ($att{'R3'} eq 'T') { 
          return 'w'; # unique at depth 4
        } 
        if ($att{'R3'} eq 'S') { 
          if ($att{'L3'} eq '-') { 
            return 'w'; # unique at depth 5
          } 
          if ($att{'L3'} eq 'E') { 
            return 'w'; # unique at depth 5
          } 
          return '_';
        } 
        if ($att{'R3'} eq 'R') { 
          return 'w'; # unique at depth 4
        } 
        if ($att{'R3'} eq '4') { 
          return 'w'; # unique at depth 4
        } 
        if ($att{'R3'} eq 'E') { 
          return 'w'; # unique at depth 4
        } 
        if ($att{'R3'} eq 'N') { 
          return 'w'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'R2'} eq 'S') { 
        if ($att{'L3'} eq 'V') { 
          return 'j'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'R2'} eq 'A') { 
        return 'w'; # unique at depth 3
      } 
      if ($att{'R2'} eq 'E') { 
        if ($att{'L2'} eq 'B') { 
          return '_'; # unique at depth 4
        } 
        if ($att{'L2'} eq 'C') { 
          if ($att{'L3'} eq '1') { 
            return 'w'; # unique at depth 5
          } 
          return '_';
        } 
        if ($att{'L2'} eq '1') { 
          return '_'; # unique at depth 4
        } 
        if ($att{'L2'} eq 'P') { 
          return '_'; # unique at depth 4
        } 
        return 'w';
      } 
      if ($att{'R2'} eq 'H') { 
        return 'w'; # unique at depth 3
      } 
      return '_';
    } 
    if ($att{'R1'} eq 'T') { 
      if ($att{'L1'} eq 'L') { 
        if ($att{'R3'} eq 'E') { 
          if ($att{'L3'} eq 'C') { 
            return 'O'; # unique at depth 5
          } 
          return 'o';
        } 
        if ($att{'R3'} eq 'N') { 
          return 'O'; # unique at depth 4
        } 
        return 'o';
      } 
      if ($att{'L1'} eq 'G') { 
        if ($att{'L3'} eq 'I') { 
          return 'O'; # unique at depth 4
        } 
        return 'o';
      } 
      if ($att{'L1'} eq 'P') { 
        if ($att{'R3'} eq 'A') { 
          if ($att{'R2'} eq 'E') { 
            if ($att{'L2'} eq '-') { 
              if ($att{'L3'} eq '-') { 
                return 'O'; # depth limit (1/2; 2 classes) at depth 7
              } 
              return 'o';
            } 
            return 'o';
          } 
          return 'o';
        } 
        if ($att{'R3'} eq '-') { 
          return 'o'; # unique at depth 4
        } 
        return 'O';
      } 
      if ($att{'L1'} eq 'B') { 
        if ($att{'L3'} eq '-') { 
          return 'O'; # unique at depth 4
        } 
        return 'o';
      } 
      if ($att{'L1'} eq 'S') { 
        if ($att{'R2'} eq '-') { 
          return 'o'; # unique at depth 4
        } 
        return 'O';
      } 
      if ($att{'L1'} eq 'C') { 
        if ($att{'R2'} eq 'S') { 
          return 'o'; # unique at depth 4
        } 
        return 'O';
      } 
      if ($att{'L1'} eq 'V') { 
        return 'o'; # unique at depth 3
      } 
      if ($att{'L1'} eq 'O') { 
        return '_'; # unique at depth 3
      } 
      if ($att{'L1'} eq 'I') { 
        if ($att{'L3'} eq 'T') { 
          return 'j'; # unique at depth 4
        } 
        return 'o';
      } 
      return 'O';
    } 
    if ($att{'R1'} eq 'C') { 
      if ($att{'R2'} eq 'A') { 
        if ($att{'L3'} eq 'A') { 
          return 'o'; # unique at depth 4
        } 
        return 'O';
      } 
      if ($att{'R2'} eq 'C') { 
        if ($att{'L1'} eq '-') { 
          return 'o';
        } 
        return 'O';
      } 
      if ($att{'R2'} eq 'S') { 
        if ($att{'L1'} eq 'R') { 
          return 'o'; # unique at depth 4
        } 
        return 'O';
      } 
      if ($att{'R2'} eq 'O') { 
        if ($att{'L2'} eq 'F') { 
          return 'O'; # unique at depth 4
        } 
        return 'o';
      } 
      return 'O';
    } 
    if ($att{'R1'} eq 'S') { 
      if ($att{'R3'} eq 'I') { 
        if ($att{'L3'} eq 'O') { 
          if ($att{'L2'} eq 'M') { 
            return 'o'; # unique at depth 5
          } 
          return 'O';
        } 
        if ($att{'L3'} eq '-') { 
          if ($att{'R2'} eq 'A') { 
            return 'o'; # unique at depth 5
          } 
          if ($att{'R2'} eq 'S') { 
            if ($att{'L1'} eq 'R') { 
              return 'o';
            } 
            return 'O';
          } 
          return 'O';
        } 
        if ($att{'L3'} eq 'R') { 
          return 'o'; # unique at depth 4
        } 
        return 'O';
      } 
      if ($att{'R3'} eq '-') { 
        if ($att{'L2'} eq '1') { 
          if ($att{'L1'} eq 'R') { 
            return 'o'; # unique at depth 5
          } 
          return 'O';
        } 
        return 'o';
      } 
      if ($att{'R3'} eq '1') { 
        if ($att{'L2'} eq 'M') { 
          return 'o'; # unique at depth 4
        } 
        if ($att{'L2'} eq 'P') { 
          if ($att{'L3'} eq 'U') { 
            return 'o'; # unique at depth 5
          } 
          return 'O';
        } 
        if ($att{'L2'} eq 'X') { 
          return 'p'; # unique at depth 4
        } 
        if ($att{'L2'} eq 'E') { 
          return 'o'; # unique at depth 4
        } 
        return 'O';
      } 
      if ($att{'R3'} eq 'O') { 
        if ($att{'L3'} eq '-') { 
          return 'o'; # unique at depth 4
        } 
        return 'l';
      } 
      if ($att{'R3'} eq 'T') { 
        if ($att{'L2'} eq 'P') { 
          return 'o'; # unique at depth 4
        } 
        return 'O';
      } 
      if ($att{'R3'} eq 'R') { 
        return 'o'; # unique at depth 3
      } 
      if ($att{'R3'} eq 'N') { 
        return 'o'; # unique at depth 3
      } 
      if ($att{'R3'} eq 'E') { 
        if ($att{'L1'} eq 'G') { 
          return 'o'; # unique at depth 4
        } 
        if ($att{'L1'} eq 'F') { 
          return 'o'; # unique at depth 4
        } 
        return 'O';
      } 
      return 'O';
    } 
    if ($att{'R1'} eq 'M') { 
      if ($att{'R2'} eq 'P') { 
        return 'O~';
      } 
      if ($att{'R2'} eq 'T') { 
        return 'O~'; # unique at depth 3
      } 
      if ($att{'R2'} eq 'S') { 
        return 'O~'; # unique at depth 3
      } 
      if ($att{'R2'} eq 'B') { 
        return 'O~'; # unique at depth 3
      } 
      if ($att{'R2'} eq '-') { 
        return 'O~'; # unique at depth 3
      } 
      return 'O';
    } 
    if ($att{'R1'} eq 'B') { 
      if ($att{'R2'} eq 'S') { 
        if ($att{'R3'} eq 'E') { 
          return 'o';
        } 
        return 'O';
      } 
      return 'O';
    } 
    if ($att{'R1'} eq 'R') { 
      if ($att{'L2'} eq 'M') { 
        if ($att{'L3'} eq 'O') { 
          if ($att{'R3'} eq 'E') { 
            if ($att{'R2'} eq 'T') { 
              if ($att{'L1'} eq 'P') { 
                return '@'; # depth limit (1/2; 2 classes) at depth 7
              } 
              return 'O';
            } 
            return '@';
          } 
          return '@';
        } 
        return 'O';
      } 
      if ($att{'L2'} eq 'U') { 
        if ($att{'R3'} eq 'T') { 
          return 'O'; # unique at depth 4
        } 
        return 'o';
      } 
      if ($att{'L2'} eq 'P') { 
        if ($att{'L3'} eq 'X') { 
          return 'l'; # unique at depth 4
        } 
        return 'O';
      } 
      if ($att{'L2'} eq 'R') { 
        return 'a'; # unique at depth 3
      } 
      if ($att{'L2'} eq 'E') { 
        if ($att{'L3'} eq 'N') { 
          return 'z'; # unique at depth 4
        } 
        return 'O';
      } 
      return 'O';
    } 
    if ($att{'R1'} eq 'J') { 
      if ($att{'L2'} eq '-') { 
        return 'o'; # unique at depth 3
      } 
      return 'O';
    } 
    if ($att{'R1'} eq 'P') { 
      if ($att{'L2'} eq 'I') { 
        return 'o'; # unique at depth 3
      } 
      return 'O';
    } 
    if ($att{'R1'} eq 'W') { 
      return '_'; # unique at depth 2
    } 
    if ($att{'R1'} eq 'G') { 
      if ($att{'R3'} eq '1') { 
        return 'o'; # unique at depth 3
      } 
      return 'O';
    } 
    if ($att{'R1'} eq 'E') { 
      if ($att{'L1'} eq 'P') { 
        return 'O'; # unique at depth 3
      } 
      return 'w';
    } 
    if ($att{'R1'} eq 'Y') { 
      if ($att{'R3'} eq 'I') { 
        return '_'; # unique at depth 3
      } 
      if ($att{'R3'} eq 'U') { 
        if ($att{'L1'} eq 'B') { 
          if ($att{'R2'} eq 'A') { 
            if ($att{'L2'} eq '-') { 
              return 'w';
            } 
            return '_';
          } 
          return '_';
        } 
        return 'w';
      } 
      if ($att{'R3'} eq '-') { 
        return 'O'; # unique at depth 3
      } 
      if ($att{'R3'} eq 'N') { 
        if ($att{'L1'} eq 'R') { 
          if ($att{'R2'} eq 'A') { 
            if ($att{'L2'} eq 'C') { 
              if ($att{'L3'} eq '-') { 
                return '_'; # depth limit (1/2; 2 classes) at depth 7
              } 
              return 'w';
            } 
            return 'w';
          } 
          return '_';
        } 
        if ($att{'L1'} eq 'V') { 
          return '_'; # unique at depth 4
        } 
        return 'w';
      } 
      return 'w';
    } 
    if ($att{'R1'} eq 'L') { 
      if ($att{'L1'} eq 'P') { 
        if ($att{'R3'} eq 'E') { 
          return 'o'; # unique at depth 4
        } 
        return 'O';
      } 
      return 'O';
    } 
    if ($att{'R1'} eq 'N') { 
      if ($att{'R2'} eq 'D') { 
        if ($att{'L3'} eq 'S') { 
          return 'g'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'R2'} eq 'E') { 
        if ($att{'L3'} eq '-') { 
          return 'o'; # unique at depth 4
        } 
        return 'O';
      } 
      if ($att{'R2'} eq 'H') { 
        return 'O'; # unique at depth 3
      } 
      if ($att{'R2'} eq 'N') { 
        return 'O'; # unique at depth 3
      } 
      if ($att{'R2'} eq 'A') { 
        return 'O'; # unique at depth 3
      } 
      if ($att{'R2'} eq 'I') { 
        return 'O'; # unique at depth 3
      } 
      if ($att{'R2'} eq 'S') { 
        if ($att{'L1'} eq 'L') { 
          if ($att{'L3'} eq 'I') { 
            return 'j'; # unique at depth 5
          } 
          return '_';
        } 
        if ($att{'L1'} eq 'Y') { 
          return 'j'; # unique at depth 4
        } 
        if ($att{'L1'} eq 'I') { 
          return 'j'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'R2'} eq '-') { 
        if ($att{'L1'} eq 'N') { 
          return '_'; # unique at depth 4
        } 
        if ($att{'L1'} eq 'H') { 
          return '_'; # unique at depth 4
        } 
        if ($att{'L1'} eq 'L') { 
          if ($att{'L3'} eq 'I') { 
            return 'j'; # unique at depth 5
          } 
          return '_';
        } 
        if ($att{'L1'} eq 'E') { 
          return '_'; # unique at depth 4
        } 
        if ($att{'L1'} eq 'D') { 
          return '_'; # unique at depth 4
        } 
        if ($att{'L1'} eq 'G') { 
          return '_'; # unique at depth 4
        } 
        if ($att{'L1'} eq 'Z') { 
          return '_'; # unique at depth 4
        } 
        if ($att{'L1'} eq 'R') { 
          return '_'; # unique at depth 4
        } 
        if ($att{'L1'} eq 'B') { 
          return '_'; # unique at depth 4
        } 
        if ($att{'L1'} eq 'S') { 
          return '_'; # unique at depth 4
        } 
        if ($att{'L1'} eq 'T') { 
          return '_'; # unique at depth 4
        } 
        if ($att{'L1'} eq '1') { 
          return '_'; # unique at depth 4
        } 
        if ($att{'L1'} eq 'F') { 
          return '_'; # unique at depth 4
        } 
        return 'j';
      } 
      if ($att{'R2'} eq 'O') { 
        if ($att{'L2'} eq 'P') { 
          return 'o'; # unique at depth 4
        } 
        return 'O';
      } 
      if ($att{'R2'} eq 'U') { 
        return 'O'; # unique at depth 3
      } 
      return '_';
    } 
    return 'O';
  } 
  if ($att{'L'} eq 'W') { 
    if ($att{'L2'} eq 'L') { 
      return 'o'; # unique at depth 2
    } 
    return 'w';
  } 
  if ($att{'L'} eq 'G') { 
    if ($att{'R1'} eq 'E') { 
      if ($att{'L2'} eq 'X') { 
        if ($att{'L1'} eq 'A') { 
          return 'a'; # unique at depth 4
        } 
        return 'i';
      } 
      if ($att{'L2'} eq 'Y') { 
        return 'a'; # unique at depth 3
      } 
      return 'Z';
    } 
    if ($att{'R1'} eq 'Y') { 
      return 'Z'; # unique at depth 2
    } 
    if ($att{'R1'} eq 'N') { 
      if ($att{'L2'} eq 'O') { 
        if ($att{'R2'} eq 'A') { 
          if ($att{'L3'} eq 'L') { 
            return '_'; # unique at depth 5
          } 
          return 'a';
        } 
        if ($att{'R2'} eq 'O') { 
          return 'J'; # unique at depth 4
        } 
        return 'a';
      } 
      if ($att{'L2'} eq 'A') { 
        if ($att{'L3'} eq 'D') { 
          return 'N'; # unique at depth 4
        } 
        return 'J';
      } 
      return 'J';
    } 
    if ($att{'R1'} eq 'I') { 
      return 'Z'; # unique at depth 2
    } 
    if ($att{'R1'} eq 'T') { 
      return '_'; # unique at depth 2
    } 
    if ($att{'R1'} eq 'S') { 
      return '_'; # unique at depth 2
    } 
    if ($att{'R1'} eq '-') { 
      return 'N'; # unique at depth 2
    } 
    return 'g';
  } 
  if ($att{'L'} eq 'U') { 
    if ($att{'L1'} eq 'N') { 
      if ($att{'R2'} eq 'R') { 
        return 'H'; # unique at depth 3
      } 
      if ($att{'R2'} eq 'Z') { 
        return 'H'; # unique at depth 3
      } 
      if ($att{'R2'} eq 'E') { 
        if ($att{'L3'} eq 'E') { 
          return 'H'; # unique at depth 4
        } 
        return 'y';
      } 
      if ($att{'R2'} eq 'L') { 
        return 'H'; # unique at depth 3
      } 
      if ($att{'R2'} eq 'I') { 
        if ($att{'L3'} eq 'T') { 
          return 'H'; # unique at depth 4
        } 
        return 'y';
      } 
      if ($att{'R2'} eq 'T') { 
        return 'H'; # unique at depth 3
      } 
      if ($att{'R2'} eq '1') { 
        return 'H'; # unique at depth 3
      } 
      return 'y';
    } 
    if ($att{'L1'} eq 'H') { 
      if ($att{'R2'} eq 'T') { 
        return 'H'; # unique at depth 3
      } 
      if ($att{'R2'} eq 'S') { 
        return 'H'; # unique at depth 3
      } 
      if ($att{'R2'} eq 'B') { 
        return '9~'; # unique at depth 3
      } 
      return 'y';
    } 
    if ($att{'L1'} eq 'L') { 
      if ($att{'R1'} eq 'E') { 
        if ($att{'L3'} eq 'S') { 
          return 'H'; # unique at depth 4
        } 
        return 'y';
      } 
      if ($att{'R1'} eq 'A') { 
        return 'H'; # unique at depth 3
      } 
      if ($att{'R1'} eq 'S') { 
        if ($att{'L3'} eq 'X') { 
          return 'l'; # unique at depth 4
        } 
        return 'y';
      } 
      if ($att{'R1'} eq 'I') { 
        return 'H'; # unique at depth 3
      } 
      return 'y';
    } 
    if ($att{'L1'} eq 'E') { 
      if ($att{'R1'} eq 'L') { 
        if ($att{'L3'} eq '-') { 
          return '2'; # unique at depth 4
        } 
        if ($att{'L3'} eq 'G') { 
          return '_'; # unique at depth 4
        } 
        return '9';
      } 
      if ($att{'R1'} eq 'E') { 
        return '_'; # unique at depth 3
      } 
      if ($att{'R1'} eq 'A') { 
        return '2'; # unique at depth 3
      } 
      if ($att{'R1'} eq 'P') { 
        if ($att{'R3'} eq 'E') { 
          return '9'; # unique at depth 4
        } 
        return '2';
      } 
      if ($att{'R1'} eq 'X') { 
        return '_'; # unique at depth 3
      } 
      if ($att{'R1'} eq 'R') { 
        if ($att{'L2'} eq 'U') { 
          if ($att{'L3'} eq 'T') { 
            return '9'; # unique at depth 5
          } 
          return '_';
        } 
        return '9';
      } 
      if ($att{'R1'} eq 'S') { 
        return '2'; # unique at depth 3
      } 
      if ($att{'R1'} eq 'T') { 
        return '2'; # unique at depth 3
      } 
      if ($att{'R1'} eq 'V') { 
        if ($att{'L3'} eq 'P') { 
          return '2'; # unique at depth 4
        } 
        return '9';
      } 
      if ($att{'R1'} eq '-') { 
        return '2'; # unique at depth 3
      } 
      if ($att{'R1'} eq '3') { 
        return 'y'; # unique at depth 3
      } 
      return '9';
    } 
    if ($att{'L1'} eq 'D') { 
      if ($att{'R1'} eq 'E') { 
        if ($att{'R2'} eq 'L') { 
          return 'H'; # unique at depth 4
        } 
        return 'y';
      } 
      if ($att{'R1'} eq 'I') { 
        return 'H'; # unique at depth 3
      } 
      return 'y';
    } 
    if ($att{'L1'} eq 'A') { 
      if ($att{'R1'} eq 'N') { 
        if ($att{'L2'} eq 'J') { 
          return 'O'; # unique at depth 4
        } 
        return 'o';
      } 
      if ($att{'R1'} eq 'D') { 
        if ($att{'L3'} eq 'P') { 
          return 'O'; # unique at depth 4
        } 
        return 'o';
      } 
      if ($att{'R1'} eq 'G') { 
        return 'O';
      } 
      if ($att{'R1'} eq 'P') { 
        return 'O'; # unique at depth 3
      } 
      if ($att{'R1'} eq 'X') { 
        if ($att{'L3'} eq 'O') { 
          return 'j'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'R1'} eq 'R') { 
        if ($att{'L2'} eq '-') { 
          return 'o'; # unique at depth 4
        } 
        return 'O';
      } 
      if ($att{'R1'} eq 'T') { 
        if ($att{'R3'} eq 'M') { 
          return 'O'; # unique at depth 4
        } 
        if ($att{'R3'} eq '-') { 
          return 'O'; # unique at depth 4
        } 
        return 'o';
      } 
      if ($att{'R1'} eq 'C') { 
        if ($att{'L2'} eq 'G') { 
          return '_'; # unique at depth 4
        } 
        return 'o';
      } 
      if ($att{'R1'} eq 'S') { 
        if ($att{'L2'} eq 'F') { 
          return 'O'; # unique at depth 4
        } 
        return 'o';
      } 
      if ($att{'R1'} eq 'V') { 
        if ($att{'R2'} eq 'A') { 
          return 'O'; # unique at depth 4
        } 
        return 'o';
      } 
      return 'o';
    } 
    if ($att{'L1'} eq 'G') { 
      if ($att{'R2'} eq 'E') { 
        return 'y'; # unique at depth 3
      } 
      if ($att{'R2'} eq 'A') { 
        return 'y'; # unique at depth 3
      } 
      if ($att{'R2'} eq 'I') { 
        if ($att{'L3'} eq 'E') { 
          return 'y'; # unique at depth 4
        } 
        return '9';
      } 
      if ($att{'R2'} eq 'U') { 
        return '9'; # unique at depth 3
      } 
      if ($att{'R2'} eq '-') { 
        if ($att{'L3'} eq 'A') { 
          return 'y'; # unique at depth 4
        } 
        return '_';
      } 
      return '_';
    } 
    if ($att{'L1'} eq 'P') { 
      if ($att{'R1'} eq 'E') { 
        if ($att{'R2'} eq '1') { 
          return 'H'; # unique at depth 4
        } 
        return 'y';
      } 
      if ($att{'R1'} eq 'Y') { 
        return 'H'; # unique at depth 3
      } 
      if ($att{'R1'} eq 'A') { 
        return 'H'; # unique at depth 3
      } 
      if ($att{'R1'} eq 'I') { 
        return 'H'; # unique at depth 3
      } 
      return 'y';
    } 
    if ($att{'L1'} eq 'J') { 
      if ($att{'R1'} eq 'N') { 
        return '_'; # unique at depth 3
      } 
      if ($att{'R1'} eq 'I') { 
        return 'H'; # unique at depth 3
      } 
      return 'y';
    } 
    if ($att{'L1'} eq 'R') { 
      if ($att{'R1'} eq 'N') { 
        if ($att{'R2'} eq 'E') { 
          return 'y'; # unique at depth 4
        } 
        return '9~';
      } 
      if ($att{'R1'} eq 'Y') { 
        return 'H'; # unique at depth 3
      } 
      if ($att{'R1'} eq 'I') { 
        return 'H'; # unique at depth 3
      } 
      return 'y';
    } 
    if ($att{'L1'} eq 'B') { 
      if ($att{'R1'} eq 'N') { 
        if ($att{'L3'} eq 'R') { 
          return 'y'; # unique at depth 4
        } 
        return '9~';
      } 
      if ($att{'R1'} eq 'E') { 
        return 'H'; # unique at depth 3
      } 
      if ($att{'R1'} eq 'M') { 
        return 'O'; # unique at depth 3
      } 
      if ($att{'R1'} eq 'I') { 
        return 'H'; # unique at depth 3
      } 
      return 'y';
    } 
    if ($att{'L1'} eq 'M') { 
      if ($att{'R1'} eq 'N') { 
        if ($att{'R2'} eq 'S') { 
          return '9~'; # unique at depth 4
        } 
        return 'y';
      } 
      if ($att{'R1'} eq 'E') { 
        if ($att{'R2'} eq '1') { 
          return 'H'; # unique at depth 4
        } 
        return 'y';
      } 
      if ($att{'R1'} eq 'A') { 
        return 'H'; # unique at depth 3
      } 
      if ($att{'R1'} eq 'M') { 
        return 'O'; # unique at depth 3
      } 
      return 'y';
    } 
    if ($att{'L1'} eq 'S') { 
      if ($att{'R1'} eq 'E') { 
        return 'H'; # unique at depth 3
      } 
      if ($att{'R1'} eq 'Y') { 
        return 'H'; # unique at depth 3
      } 
      if ($att{'R1'} eq 'A') { 
        return 'H'; # unique at depth 3
      } 
      if ($att{'R1'} eq 'I') { 
        return 'H'; # unique at depth 3
      } 
      return 'y';
    } 
    if ($att{'L1'} eq 'C') { 
      if ($att{'R1'} eq 'E') { 
        return '9'; # unique at depth 3
      } 
      if ($att{'R1'} eq 'S') { 
        if ($att{'L3'} eq 'E') { 
          return 'k'; # unique at depth 4
        } 
        return 'y';
      } 
      if ($att{'R1'} eq 'I') { 
        return 'H'; # unique at depth 3
      } 
      return 'y';
    } 
    if ($att{'L1'} eq 'T') { 
      if ($att{'R1'} eq 'E') { 
        if ($att{'R2'} eq '-') { 
          return 'y'; # unique at depth 4
        } 
        return 'H';
      } 
      if ($att{'R1'} eq 'Y') { 
        return 'H'; # unique at depth 3
      } 
      if ($att{'R1'} eq 'A') { 
        return 'H'; # unique at depth 3
      } 
      if ($att{'R1'} eq 'I') { 
        return 'H'; # unique at depth 3
      } 
      return 'y';
    } 
    if ($att{'L1'} eq 'O') { 
      if ($att{'R1'} eq 'H') { 
        return '_'; # unique at depth 3
      } 
      if ($att{'R1'} eq 'E') { 
        if ($att{'L3'} eq 'B') { 
          return 'u'; # unique at depth 4
        } 
        if ($att{'L3'} eq 'C') { 
          if ($att{'L2'} eq 'L') { 
            return 'u'; # unique at depth 5
          } 
          return '_';
        } 
        if ($att{'L3'} eq '1') { 
          return 'u'; # unique at depth 4
        } 
        if ($att{'L3'} eq 'P') { 
          return 'u'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'R1'} eq 'A') { 
        return '_'; # unique at depth 3
      } 
      if ($att{'R1'} eq 'I') { 
        if ($att{'R2'} eq 'N') { 
          return '_'; # unique at depth 4
        } 
        if ($att{'R2'} eq 'E') { 
          return '_'; # unique at depth 4
        } 
        if ($att{'R2'} eq 'R') { 
          return '_'; # unique at depth 4
        } 
        if ($att{'R2'} eq '4') { 
          return '_'; # unique at depth 4
        } 
        if ($att{'R2'} eq 'T') { 
          return '_'; # unique at depth 4
        } 
        if ($att{'R2'} eq 'S') { 
          if ($att{'L3'} eq 'B') { 
            return 'u'; # unique at depth 5
          } 
          return '_';
        } 
        if ($att{'R2'} eq '-') { 
          if ($att{'L3'} eq 'B') { 
            return 'u'; # unique at depth 5
          } 
          return '_';
        } 
        return 'u';
      } 
      return 'u';
    } 
    if ($att{'L1'} eq 'Q') { 
      if ($att{'R2'} eq 'S') { 
        if ($att{'L3'} eq 'E') { 
          return 'k'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'R2'} eq 'U') { 
        if ($att{'L3'} eq 'I') { 
          return '9'; # unique at depth 4
        } 
        return '2';
      } 
      if ($att{'R2'} eq 'R') { 
        if ($att{'L3'} eq 'L') { 
          if ($att{'R3'} eq '-') { 
            return '_'; # unique at depth 5
          } 
          return 'k';
        } 
        if ($att{'L3'} eq 'P') { 
          return 'y'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'R2'} eq 'N') { 
        if ($att{'L2'} eq 'I') { 
          return 'k'; # unique at depth 4
        } 
        return '_';
      } 
      return '_';
    } 
    if ($att{'L1'} eq 'F') { 
      if ($att{'R1'} eq 'Y') { 
        return 'H'; # unique at depth 3
      } 
      if ($att{'R1'} eq 'S') { 
        if ($att{'R3'} eq 'L') { 
          if ($att{'R2'} eq 'I') { 
            if ($att{'L2'} eq '-') { 
              if ($att{'L3'} eq '-') { 
                return 'u'; # depth limit (1/2; 2 classes) at depth 7
              } 
              return 'y';
            } 
            return 'y';
          } 
          return 'u';
        } 
        return 'y';
      } 
      if ($att{'R1'} eq 'I') { 
        return 'H'; # unique at depth 3
      } 
      return 'y';
    } 
    if ($att{'L1'} eq 'I') { 
      return 'O'; # unique at depth 2
    } 
    return 'y';
  } 
  if ($att{'L'} eq 'A') { 
    if ($att{'R1'} eq '3') { 
      if ($att{'L1'} eq 'L') { 
        return 'a'; # unique at depth 3
      } 
      if ($att{'L1'} eq 'H') { 
        if ($att{'R3'} eq 'I') { 
          if ($att{'L2'} eq 'C') { 
            return '_'; # unique at depth 5
          } 
          return 'a';
        } 
        return '_';
      } 
      if ($att{'L1'} eq 'N') { 
        if ($att{'L3'} eq 'O') { 
          return 'a'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'L1'} eq 'D') { 
        return 'a'; # unique at depth 3
      } 
      if ($att{'L1'} eq 'G') { 
        if ($att{'L3'} eq 'E') { 
          return 'a'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'L1'} eq 'T') { 
        if ($att{'R3'} eq '-') { 
          return 'a'; # unique at depth 4
        } 
        if ($att{'R3'} eq 'H') { 
          if ($att{'R2'} eq 'C') { 
            if ($att{'L2'} eq '-') { 
              if ($att{'L3'} eq '-') { 
                return '_'; # depth limit (1/2; 2 classes) at depth 7
              } 
              return 'a';
            } 
            return '_';
          } 
          return '_';
        } 
        return '_';
      } 
      if ($att{'L1'} eq 'S') { 
        if ($att{'L3'} eq 'R') { 
          return '_'; # unique at depth 4
        } 
        return 'a';
      } 
      if ($att{'L1'} eq 'U') { 
        return 'a'; # unique at depth 3
      } 
      if ($att{'L1'} eq '-') { 
        if ($att{'R2'} eq 'T') { 
          return '_'; # unique at depth 4
        } 
        return 'a';
      } 
      if ($att{'L1'} eq 'V') { 
        return 'a'; # unique at depth 3
      } 
      return '_';
    } 
    if ($att{'R1'} eq 'I') { 
      if ($att{'R2'} eq 'T') { 
        if ($att{'L2'} eq 'I') { 
          if ($att{'L3'} eq 'M') { 
            if ($att{'R3'} eq '-') { 
              return '_';
            } 
            return 'i';
          } 
          if ($att{'L3'} eq 'O') { 
            return 'a'; # unique at depth 5
          } 
          return '_';
        } 
        if ($att{'L2'} eq 'O') { 
          if ($att{'L1'} eq 'Y') { 
            return 'a'; # unique at depth 5
          } 
          return '_';
        } 
        if ($att{'L2'} eq 'L') { 
          if ($att{'L1'} eq 'T') { 
            return 'l'; # unique at depth 5
          } 
          return '_';
        } 
        return '_';
      } 
      if ($att{'R2'} eq '-') { 
        if ($att{'L1'} eq 'I') { 
          return 'j'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'R2'} eq '4') { 
        return 'a'; # unique at depth 3
      } 
      if ($att{'R2'} eq 'R') { 
        if ($att{'L3'} eq 'D') { 
          return 'n';
        } 
        if ($att{'L3'} eq 'X') { 
          return 'R'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'R2'} eq 'L') { 
        return 'a';
      } 
      if ($att{'R2'} eq 'E') { 
        if ($att{'L3'} eq 'O') { 
          if ($att{'L2'} eq 'I') { 
            return 'a'; # unique at depth 5
          } 
          return '_';
        } 
        if ($att{'L3'} eq 'R') { 
          if ($att{'L2'} eq 'I') { 
            return 'R'; # unique at depth 5
          } 
          return '_';
        } 
        return '_';
      } 
      return '_';
    } 
    if ($att{'R1'} eq 'B') { 
      if ($att{'L1'} eq 'Y') { 
        return 'j'; # unique at depth 3
      } 
      if ($att{'L1'} eq 'R') { 
        if ($att{'L3'} eq 'X') { 
          return 'R'; # unique at depth 4
        } 
        return 'a';
      } 
      if ($att{'L1'} eq 'C') { 
        if ($att{'L3'} eq 'A') { 
          if ($att{'R3'} eq 'E') { 
            if ($att{'R2'} eq 'L') { 
              return 'a';
            } 
            return 'A';
          } 
          return 'a';
        } 
        return 'a';
      } 
      if ($att{'L1'} eq 'S') { 
        if ($att{'L2'} eq '-') { 
          if ($att{'R2'} eq 'L') { 
            return 'A'; # unique at depth 5
          } 
          return 'a';
        } 
        return 'a';
      } 
      if ($att{'L1'} eq 'M') { 
        if ($att{'L3'} eq 'R') { 
          return 'm'; # unique at depth 4
        } 
        return 'a';
      } 
      if ($att{'L1'} eq 'I') { 
        if ($att{'R2'} eq 'L') { 
          return 'A'; # unique at depth 4
        } 
        return 'a';
      } 
      if ($att{'L1'} eq 'F') { 
        if ($att{'R3'} eq 'E') { 
          if ($att{'L3'} eq 'E') { 
            return 'a'; # unique at depth 5
          } 
          return 'A';
        } 
        return 'a';
      } 
      return 'a';
    } 
    if ($att{'R1'} eq 'C') { 
      if ($att{'L1'} eq 'X') { 
        return 'z'; # unique at depth 3
      } 
      if ($att{'L1'} eq 'R') { 
        if ($att{'L3'} eq 'M') { 
          return 'A'; # unique at depth 4
        } 
        return 'a';
      } 
      return 'a';
    } 
    if ($att{'R1'} eq 'T') { 
      if ($att{'L3'} eq 'O') { 
        if ($att{'L2'} eq 'I') { 
          return 't'; # unique at depth 4
        } 
        return 'a';
      } 
      if ($att{'L3'} eq 'L') { 
        if ($att{'L2'} eq 'A') { 
          return 'm'; # unique at depth 4
        } 
        return 'a';
      } 
      return 'a';
    } 
    if ($att{'R1'} eq 'M') { 
      if ($att{'R2'} eq 'I') { 
        if ($att{'L2'} eq 'E') { 
          return 'z'; # unique at depth 4
        } 
        return 'a';
      } 
      if ($att{'R2'} eq 'B') { 
        return 'A~'; # unique at depth 3
      } 
      if ($att{'R2'} eq 'M') { 
        if ($att{'L3'} eq 'R') { 
          return 'j'; # unique at depth 4
        } 
        return 'a';
      } 
      if ($att{'R2'} eq 'P') { 
        return 'A~'; # unique at depth 3
      } 
      if ($att{'R2'} eq 'A') { 
        if ($att{'L3'} eq 'X') { 
          return 'l'; # unique at depth 4
        } 
        return 'a';
      } 
      return 'a';
    } 
    if ($att{'R1'} eq 'S') { 
      if ($att{'L1'} eq 'L') { 
        if ($att{'L2'} eq '-') { 
          if ($att{'R3'} eq 'E') { 
            if ($att{'R2'} eq 'S') { 
              if ($att{'L3'} eq '-') { 
                return 'a'; # depth limit (1/2; 2 classes) at depth 7
              } 
              return 'A';
            } 
            return 'a';
          } 
          return 'a';
        } 
        return 'a';
      } 
      if ($att{'L1'} eq 'X') { 
        return 'z'; # unique at depth 3
      } 
      if ($att{'L1'} eq 'R') { 
        if ($att{'R3'} eq '-') { 
          if ($att{'L2'} eq '-') { 
            if ($att{'R2'} eq '-') { 
              return 'A'; # unique at depth 6
            } 
            return 'a';
          } 
          return 'a';
        } 
        if ($att{'R3'} eq 'R') { 
          if ($att{'L3'} eq '-') { 
            return 'A'; # unique at depth 5
          } 
          return 'a';
        } 
        if ($att{'R3'} eq 'E') { 
          if ($att{'L2'} eq 'B') { 
            if ($att{'L3'} eq '-') { 
              if ($att{'R2'} eq 'S') { 
                return 'A'; # unique at depth 7
              } 
              return 'a';
            } 
            return 'a';
          } 
          return 'a';
        } 
        return 'a';
      } 
      if ($att{'L1'} eq 'C') { 
        if ($att{'R3'} eq '-') { 
          return 'A'; # unique at depth 4
        } 
        if ($att{'R3'} eq 'E') { 
          if ($att{'L2'} eq '-') { 
            if ($att{'R2'} eq 'S') { 
              if ($att{'L3'} eq '-') { 
                return 'a'; # depth limit (2/4; 2 classes) at depth 7
              } 
              return 'A';
            } 
            return 'A';
          } 
          return 'a';
        } 
        return 'a';
      } 
      if ($att{'L1'} eq 'M') { 
        if ($att{'R3'} eq '-') { 
          if ($att{'L2'} eq '-') { 
            return 'A'; # unique at depth 5
          } 
          return 'a';
        } 
        return 'a';
      } 
      if ($att{'L1'} eq 'V') { 
        if ($att{'L3'} eq '-') { 
          return 'A'; # unique at depth 4
        } 
        return 'a';
      } 
      return 'a';
    } 
    if ($att{'R1'} eq 'U') { 
      if ($att{'L2'} eq 'U') { 
        return 'j'; # unique at depth 3
      } 
      if ($att{'L2'} eq 'O') { 
        if ($att{'R2'} eq 'X') { 
          return 'a'; # unique at depth 4
        } 
        return 'j';
      } 
      return '_';
    } 
    if ($att{'R1'} eq 'O') { 
      if ($att{'L3'} eq '-') { 
        return 'a'; # unique at depth 3
      } 
      return 'R';
    } 
    if ($att{'R1'} eq 'Z') { 
      if ($att{'R2'} eq 'O') { 
        return 'A'; # unique at depth 3
      } 
      if ($att{'R2'} eq 'Z') { 
        return 'Z'; # unique at depth 3
      } 
      return 'a';
    } 
    if ($att{'R1'} eq 'L') { 
      if ($att{'L1'} eq 'X') { 
        return 'z'; # unique at depth 3
      } 
      return 'a';
    } 
    if ($att{'R1'} eq 'N') { 
      if ($att{'R2'} eq 'I') { 
        return 'a'; # unique at depth 3
      } 
      if ($att{'R2'} eq 'C') { 
        if ($att{'L1'} eq 'Y') { 
          if ($att{'R3'} eq 'E') { 
            if ($att{'L2'} eq 'O') { 
              return 'j';
            } 
            return 'a';
          } 
          return 'a';
        } 
        return '_';
      } 
      if ($att{'R2'} eq 'T') { 
        if ($att{'L3'} eq 'V') { 
          if ($att{'L2'} eq 'O') { 
            return 'a'; # unique at depth 5
          } 
          return '_';
        } 
        if ($att{'L3'} eq 'I') { 
          if ($att{'R3'} eq 'S') { 
            if ($att{'L2'} eq 'S') { 
              return 'a'; # unique at depth 6
            } 
            return '_';
          } 
          if ($att{'R3'} eq '-') { 
            if ($att{'L2'} eq 'G') { 
              return 'a';
            } 
            return '_';
          } 
          return '_';
        } 
        if ($att{'L3'} eq 'R') { 
          if ($att{'R3'} eq 'E') { 
            if ($att{'L2'} eq 'E') { 
              return '_'; # unique at depth 6
            } 
            return 'j';
          } 
          return '_';
        } 
        return '_';
      } 
      if ($att{'R2'} eq 'U') { 
        return 'a'; # unique at depth 3
      } 
      if ($att{'R2'} eq '-') { 
        if ($att{'L2'} eq 'J') { 
          return 'i'; # unique at depth 4
        } 
        if ($att{'L2'} eq 'R') { 
          return 'a'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'R2'} eq 'O') { 
        return 'a'; # unique at depth 3
      } 
      if ($att{'R2'} eq 'N') { 
        return 'a'; # unique at depth 3
      } 
      if ($att{'R2'} eq 'D') { 
        if ($att{'L3'} eq 'B') { 
          return 'j'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'R2'} eq 'E') { 
        if ($att{'L1'} eq 'V') { 
          return 'A'; # unique at depth 4
        } 
        return 'a';
      } 
      if ($att{'R2'} eq 'G') { 
        if ($att{'L3'} eq 'T') { 
          return 'j'; # unique at depth 4
        } 
        return '_';
      } 
      if ($att{'R2'} eq 'A') { 
        return 'a'; # unique at depth 3
      } 
      return '_';
    } 
    if ($att{'R1'} eq 'D') { 
      if ($att{'L3'} eq '-') { 
        if ($att{'L1'} eq 'C') { 
          if ($att{'R3'} eq 'E') { 
            return 'A'; # unique at depth 5
          } 
          return 'a';
        } 
        return 'a';
      } 
      if ($att{'L3'} eq 'G') { 
        return 'A'; # unique at depth 3
      } 
      return 'a';
    } 
    if ($att{'R1'} eq 'Y') { 
      if ($att{'L1'} eq 'W') { 
        return '_'; # unique at depth 3
      } 
      if ($att{'L1'} eq 'P') { 
        if ($att{'R2'} eq 'S') { 
          return 'e'; # unique at depth 4
        } 
        return 'E';
      } 
      if ($att{'L1'} eq 'R') { 
        if ($att{'R2'} eq 'A') { 
          return 'e'; # unique at depth 4
        } 
        return 'E';
      } 
      if ($att{'L1'} eq 'B') { 
        return 'e'; # unique at depth 3
      } 
      if ($att{'L1'} eq 'S') { 
        return '_'; # unique at depth 3
      } 
      if ($att{'L1'} eq '-') { 
        return '_'; # unique at depth 3
      } 
      return 'E';
    } 
    if ($att{'R1'} eq 'G') { 
      if ($att{'L1'} eq 'Y') { 
        return 'j'; # unique at depth 3
      } 
      if ($att{'L1'} eq 'X') { 
        return 'z'; # unique at depth 3
      } 
      return 'a';
    } 
    return 'a';
  } 
  return '_';
};



1;

