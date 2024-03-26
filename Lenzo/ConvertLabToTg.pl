#!/usr/bin/perl;

# Programme qui convertie les fichiers .lab en .TextGrid 
# Carolina Rodriguez Master Langue et Informatique 2014-2015 

main();

sub main {
	my $arg = $ARGV[0];
		if(!(-d $arg)) {
		trait_fic($arg);
	}
	else {
		trait_rep($arg);
	}	
}



sub trait_rep {
	my ($dir) = @_;
	opendir(DIR, $dir) or die "ERREUR LORS DE L'OUVERTURE DU REPERTOIRE $dir"; 
	my @listeDeFichier = grep {/\.lab$/} (readdir DIR);
	my @listeOrdonnee = sort(@listeDeFichier);
	close(DIR);

	print "+--------------------------------------------------+\n";
	print "Nom du repertoire : $dir\n";
	print "Nombre de fichiers : " . (scalar(@listeOrdonnee))."\n";
	print "Noms des fichiers : ---------\n";

	foreach my $fichier (@listeOrdonnee) {		
		trait_fic($dir."/".$fichier);
	}
}

sub trait_fic {
		my ($fichier) = @_;
		my $size = -s $fichier;
	print "**** TRAITEMENT FICHIER *****\n";
	print "# ".$fichier." \t ".$size." octets # \n";

# Phase 1 de traitement :

open (T0, "<$fichier") or die "ERREUR D'OUVERTURE DU FICHIER ".$fichier."\n";
	my $fic_sortie1 = $fichier;
	$fic_sortie1 =~ s/(.*).lab/$1.TextGrid/g;
open (TF, ">>$fic_sortie1") or die "ERREUR D'OUVERTURE DU FICHIER ".$fic_sortie."\n";

foreach (reverse(<T0> )) {
$nbligne++;
$n="1";
chomp($derniere=$_) and last;
}

#\s est un blanc et correspond a [\ \t\r\n\f]
# xx 7 ou 6 chiffres xx xx
if ($derniere =~ /(.*?)\s([1-9]{1}[0-9]{5,6})\s(.*?)\s(.*?)$/) {
	print TF "File type = \"ooTextFile\"\n";
	print TF "Object class = \"TextGrid\"\n";
	print TF "xmin = 0\n";
	print TF "xmax = 0.".$2."\n" ;
	print TF "tiers? <exists> \n";
	print TF "size = 1 \n";
	print TF "item []: \n";
  	print TF "\t item [".$n."]:\n";
  	print TF "\t \t class = \"IntervalTier\" \n";
   	print TF "\t \t name = \"Phoneme\" \n";
  	print TF "\t \t xmin = 0 \n";
    print TF "\t \t xmax = 0.".$2."\n" ;
			}
	
elsif ($derniere =~ /(.*?)\s([1-9])([0-9]{7})\s(.*?)\s(.*?)$/) {
	print TF "File type = \"ooTextFile\"\n";
	print TF "Object class = \"TextGrid\"\n";
	print TF "xmin = 0\n";
	print TF "xmax = ".$2.".".$3."\n";
	print TF "tiers? <exists>\n";
	print TF "size = 1 \n";
	print TF "item []: \n";
  	print TF "\t item [".$n."]:\n";
  	print TF "\t \t class = \"IntervalTier\" \n";
   	print TF "\t \t name = \"Phoneme\" \n";
  	print TF "\t \t xmin = 0 \n";
    print TF "\t \t xmax = ".$2.".".$3."\n" ;
}
	
elsif ($derniere =~ /(.*?)\s([1-9][0-9])([0-9]{7})\s(.*?)\s(.*?)$/) {
	print TF "File type = \"ooTextFile\"\n";
	print TF "Object class = \"TextGrid\"\n";
	print TF "xmin = 0\n";
	print TF "xmax = ".$2.".".$3."\n";
	print TF "tiers? <exists> \n";
	print TF "size = 1 \n";
	print TF "item []: \n";
  	print TF "\t item [".$n."]:\n";
  	print TF "\t \t class = \"IntervalTier\" \n";
   	print TF "\t \t name = \"Phoneme\" \n";
  	print TF "\t \t xmin = 0 \n";
    print TF "\t \t xmax = ".$2.".".$3."\n" ;
   
}
	
close(T0) or die "ERREUR DE FERMETURE DU FICHIER $fichier\n";
close(TF) or die "ERREUR DE FERMETURE DU FICHIER $fichier_sortie\n";

#Phase 2
	
open (T0, "<$fichier") or die "ERREUR D'OUVERTURE DU FICHIER $fichier\n";
open (TF, ">>$fic_sortie1") or die "ERREUR D'OUVERTURE DU FICHIER $fic_sortie\n";

my $nb_ligne = 0;
while($ligne = <T0>) {
		
		@liste_ligne = split( /\n+/, $ligne);
		
		foreach $liste_ligne (@liste_ligne)
			{
				$nb_ligne++;
				}
			}	
		print TF "\n \t \t intervals: size = ".$nb_ligne."\n" ;
		
	
	
	
close(T0) or die "ERREUR DE FERMETURE DU FICHIER $fichier\n";
close(TF) or die "ERREUR DE FERMETURE DU FICHIER $fichier_sortie\n";

# Phase 3

open (T0, "<$fichier") or die "ERREUR D'OUVERTURE DU FICHIER $fichier\n";
open (TF, ">>$fic_sortie1") or die "ERREUR D'OUVERTURE DU FICHIER $fic_sortie\n";

my $n;
while($ligne = <T0>) {
  $n++;	
  chomp;
  
  # 0 5chiffres
  if ($ligne =~ /^0\s([1-9]{1}[0-9]{4})\s(.*?)\s(.*?)$/) {
	print TF "\t \t intervals [".$n."]:\n";
	print TF "\t \t \t xmin = 0.0\n";
	print TF "\t \t \t xmax = 0.00".$1."\n" ;
	print TF "\t \t \t text = \"".$2."\"\n" ;
			}
  # 0 6chiffres
  elsif ($ligne =~ /^0\s([1-9]{1}[0-9]{5})\s(.*?)\s(.*?)$/) {
	print TF "\t \t intervals [".$n."]:\n";
	print TF "\t \t \t xmin = 0.0\n";
	print TF "\t \t \t xmax = 0.0".$1."\n" ;
	print TF "\t \t \t text = \"".$2."\"\n" ;
			}
  # 0 7chiffres
  elsif ($ligne =~ /^0\s([1-9]{1}[0-9]{6})\s(.*?)\s(.*?)$/) {
	print TF "\t \t intervals [".$n."]:\n";
	print TF "\t \t \t xmin = 0.0\n";
	print TF "\t \t \t xmax = 0.".$1."\n" ;
	print TF "\t \t \t text = \"".$2."\"\n" ;
			}

}

close(T0) or die "ERREUR DE FERMETURE DU FICHIER $fichier\n";
close(TF) or die "ERREUR DE FERMETURE DU FICHIER $fichier_sortie\n";

#Phase 4

open (T0, "<$fichier") or die "ERREUR D'OUVERTURE DU FICHIER $fichier\n";
open (TF, ">>$fic_sortie1") or die "ERREUR D'OUVERTURE DU FICHIER $fic_sortie\n";

my $n;
while($ligne = <T0>) {
	$n++;	
	chomp;
  #5chiffres 100000 (6)
	if ($ligne =~ /^([1-9]{1}[0-9]{4})\s([1-9]{1}[0-9]{5})\s(.*?)\s(.*?)$/) {
		print TF "\t \t intervals [".$n."]:\n";
    	print TF "\t \t \t xmin = 0.00".$1."\n";
    	print TF "\t \t \t xmax = 0.0".$2."\n"; 
    	print TF "\t \t \t text = \"".$3."\"\n";
	}
	
	#6chiffres 1000000 (6)
	elsif ($ligne =~ /^([1-9]{1}[0-9]{5})\s([1-9]{1}[0-9]{5})\s(.*?)\s(.*?)$/) {
		print TF "\t \t intervals [".$n."]:\n";
    	print TF "\t \t \t xmin = 0.0".$1."\n";
    	print TF "\t \t \t xmax = 0.0".$2."\n"; 
    	print TF "\t \t \t text = \"".$3."\"\n";
	}

#6chiffres 1 000000 (7)
	elsif ($ligne =~ /^([1-9]{1}[0-9]{5})\s([1-9]{1}[0-9]{6})\s(.*?)\s(.*?)$/) {
		print TF "\t \t intervals [".$n."]:\n";
    	print TF "\t \t \t xmin = 0.0".$1."\n";
    	print TF "\t \t \t xmax = 0.".$2."\n"; 
    	print TF "\t \t \t text = \"".$3."\"\n";
	}
	
	#7chiffres 1 000000 (7)
	elsif ($ligne =~ /^([1-9]{1}[0-9]{6})\s([1-9]{1}[0-9]{6})\s(.*?)\s(.*?)$/) {
		print TF "\t \t intervals [".$n."]:\n";
    	print TF "\t \t \t xmin = 0.".$1."\n";
    	print TF "\t \t \t xmax = 0.".$2."\n"; 
    	print TF "\t \t \t text = \"".$3."\"\n";
	}


	#1000000(7) 1 0000000(8)
	elsif ($ligne =~ /^([1-9]{1}[0-9]{6})\s([1-9]{1})([0-9]{7})\s(.*?)\s(.*?)$/) {
		print TF "\t \t intervals [".$n."]:\n";
    	print TF "\t \t \t xmin = 0.".$1."\n";
    	print TF "\t \t \t xmax = ".$2.".".$3."\n"; 
    	print TF "\t \t \t text = \"".$4."\"\n";
			}
	
	#1 0000000(8) 1 0000000(8)
	elsif ($ligne =~ /^([1-9]{1})([0-9]{7})\s([1-9]{1})([0-9]{7})\s(.*?)\s(.*?)$/) {
		print TF "\t \t intervals [".$n."]:\n";
	    print TF "\t \t \t xmin = ".$1.".".$2."\n";
	    print TF "\t \t \t xmax = ".$3.".".$4."\n";
	    print TF "\t \t \t text = \"".$5."\"\n";
			}
	
	# 1 0000000(8) 10 0000000(9)
	elsif ($ligne =~ /^([1-9])([0-9]{7})\s([1-9][0-9])([0-9]{7})\s(.*?)\s(.*?)$/) {
		print TF "\t \t intervals [".$n."]:\n";
	    print TF "\t \t \t xmin = ".$1.".".$2."\n";
	  	print TF "\t \t \t xmax = ".$3.".".$4."\n";
	    print TF "\t \t \t text = \"".$5."\"\n";
	}
			
	# 10 0000000(9) 10 0000000(9)
	elsif ($ligne =~ /^([1-9][0-9])([0-9]{7})\s([1-9][0-9])([0-9]{7})\s(.*?)\s(.*?)$/) {
		print TF "\t \t intervals [".$n."]:\n";
	    print TF "\t \t \t xmin = ".$1.".".$2."\n";
	  	print TF "\t \t \t xmax = ".$3.".".$4."\n";
	    print TF "\t \t \t text = \"".$5."\"\n";
	}
				
	# 10 0000000(9) 100 0000000(10)
	elsif ($ligne =~ /^([1-9][0-9])([0-9]{7})\s([1-9][0-9][0-9])([0-9]{7})\s(.*?)\s(.*?)$/) {
		print TF "\t \t intervals [".$n."]:\n";
	    print TF "\t \t \t xmin = ".$1.".".$2."\n";
	  	print TF "\t \t \t xmax = ".$3.".".$4."\n";
	    print TF "\t \t \t text = \"".$5."\"\n";	
	}
	# 100 0000000(10) 100 0000000(10)
	elsif ($ligne =~ /^([1-9][0-9][0-9])([0-9]{7})\s([1-9][0-9][0-9])([0-9]{7})\s(.*?)\s(.*?)$/) {
		print TF "\t \t intervals [".$n."]:\n";
	    print TF "\t \t \t xmin = ".$1.".".$2."\n";
	  	print TF "\t \t \t xmax = ".$3.".".$4."\n";
	    print TF "\t \t \t text = \"".$5."\"\n";	
	}


			
}
}
	
close(T0) or die "ERREUR DE FERMETURE DU FICHIER $fichier\n";
close(TF) or die "ERREUR DE FERMETURE DU FICHIER $fichier_sortie\n";

#eof

