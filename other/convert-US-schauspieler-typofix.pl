#!/usr/bin/perl

use strict;

#################
# Korrigiere Tippfehler mit Quickstatements

# https://www.wikidata.org/w/index.php?title=Q897597&diff=prev&oldid=1567559385

# * ALT: ehemalige Kommunge in Dänemark
# * NEU: ehemalige Kommune in Dänemark
#################


# https://query.wikidata.org/#SELECT%20DISTINCT%20%3Fitem%20%3Flabel%20%3FitemDescription%0AWHERE%0A%7B%0A%20%20SERVICE%20wikibase%3Amwapi%0A%20%20%7B%0A%20%20%20%20bd%3AserviceParam%20wikibase%3Aendpoint%20%22www.wikidata.org%22%3B%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20wikibase%3Aapi%20%22Generator%22%3B%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20mwapi%3Agenerator%20%22search%22%3B%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20mwapi%3Agsrsearch%20%22%27ehemalige%20Kommunge%20in%20D%C3%A4nemark%27%22%40de%3B%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20mwapi%3Alanguage%20%22de%22%3B%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20mwapi%3Agsrlimit%20%22max%22.%0A%20%20%20%20%3Fitem%20wikibase%3AapiOutputItem%20mwapi%3Atitle.%0A%20%20%7D%0A%20%20SERVICE%20wikibase%3Alabel%20%7B%20bd%3AserviceParam%20wikibase%3Alanguage%20%22%5BAUTO_LANGUAGE%5D%2Cde%22.%20%7D%0A%20%20%7D


# Mittels 
# <syntaxhighlight lang="sparql">
# SELECT DISTINCT ?item ?label ?itemDescription
# WHERE
# {
#   SERVICE wikibase:mwapi
#   {
#     bd:serviceParam wikibase:endpoint "www.wikidata.org";
#                     wikibase:api "Generator";
#                     mwapi:generator "search";
#                     mwapi:gsrsearch "'ehemalige Kommunge in Dänemark'"@de;
#                     mwapi:language "de";
#                     mwapi:gsrlimit "max".
#     ?item wikibase:apiOutputItem mwapi:title.
#   }
#   SERVICE wikibase:label { bd:serviceParam wikibase:language "[AUTO_LANGUAGE],de". }
#   }
# </syntaxhighlight>
# 
# https://w.wiki/4jTh
# 
# wurden 353 betroffene Einträge ermittelt.


# my $INFILE = '/home/m2k/Downloads/query.csv';
my $INFILE = 'query.csv';

open ( IN, "< $INFILE") || die("cannot open $INFILE: $! \n");

my $count =0 ;
my $QID = 0;
while(<IN>)
{
    chop;
    my $line = $_;
    my ($QID,$dummy,$beschreibung) = split (/\,/,$line);
    $QID =~ s/http:\/\/www.wikidata.org\/entity\/Q//og;
    # print "QID:$QID:BESCHR:$beschreibung:\n";

my $beschreibung_neu = "";
    if ($beschreibung =~ /us-amerikanischer Schauspieler/) {
		$beschreibung_neu = $beschreibung;
	  $beschreibung_neu =~ s/us-amerikanischer Schauspieler/US-amerikanischer Schauspieler/;
	
    }
    
    if (($beschreibung_neu ne "") && ($QID > 0)) {
       print "Q".$QID."\tDde\t\"$beschreibung_neu\"\n"; # description de - beschreibung
    } 

}
close(IN);
