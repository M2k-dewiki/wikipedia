#!/usr/bin/perl

use strict;

# Crypt::SSLeay muss installiert sein fuer SSL-Support
# apt-get install libwww-mechanize-perl libio-socket-ssl-perl libnet-ssleay-perl
use WWW::Mechanize;
use Data::Dumper;
use HTML::FormatText;
my $USER_AGENT='Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.101 Safari/537.36';
# See the autocheck parameter, which turns all HTTP errors into fatal errors. When you turn autocheck off, you will need to do all error checking yourself.
my $agent = WWW::Mechanize->new( agent => $USER_AGENT,  autocheck => 0 );

#http://glennf.com/writing/hexadecimal.url.encoding.html
# This pattern takes the hex characters and decodes them back into real characters. The function hex() turns a hex number into decimal; 
# there is no dec() that does the reverse in perl. The "e" at the end of the regexp means "evaluate the replacement pattern as an expression."
sub URLDecode {
    my $theURL = $_[0];
    $theURL =~ tr/+/ /;
    $theURL =~ s/%([a-fA-F0-9]{2,2})/chr(hex($1))/eg;
    $theURL =~ s/<!--(.|\n)*-->//g;
    return $theURL;
}

sub URLEncode {
    my $theURL = $_[0];
    $theURL =~ s/([\W])/"%" . uc(sprintf("%2.2x",ord($1)))/eg;
    return $theURL;
}

#########################

# my $file_urllist = '/tmp/wikipedia-urllist-add-location.txt';
my $file_urllist = 'wikipedia-urllist-add-location.txt';
my %urllist ;
if (-e $file_urllist) {
  open (IN, "< $file_urllist") || die ("Cannot open $file_urllist : $! \n");
  while (<IN>) {
    chop;
    my $line = $_;
    # print "LINE:$line:\n";      
    $urllist{$line}++;
  }
  close(IN);
}

# Speichern - welche URLs wurden bereits geprueft ??!
open (OUT, "> $file_urllist") || die ("Cannot open $file_urllist : $! \n");
foreach my $key (sort keys %urllist) {
  print OUT "$key\n";
}

#########################



# ?item wdt:P31 wd:Q34038.   # WasserFall
#  ?item wdt:P17 wd:Q664.   # Neuseeland




#### Orte in der Steiermark ohne geographische Koordinaten
###
#### https://petscan.wmflabs.org/?edits%5Bbots%5D=both&common_wiki=wikidata&categories=Ort%20in%20der%20Steiermark&wpiu=none&wikidata_prop_item_use=P625&cb_labels_yes_l=1&search_max_results=500&language=de&cb_labels_no_l=1&cb_labels_any_l=1&ns%5B0%5D=1&interface_language=en&negcats=Liste&show_redirects=no&wikidata_label_language=de&project=wikipedia&wikidata_item=with&edits%5Bflagged%5D=both&combination=union&edits%5Banons%5D=both&depth=10&after=&doit=

### Problem: Klammerzusätze fehlen in Ergebnislisten !!!!

# ===>  Lösung: SPARQL-Liste

# SELECT ?item ?geo ?sitelink  WHERE {
#   ?item wdt:P31 wd:Q3257686. # Ortschaft
#  ?item wdt:P17 wd:Q40.   # Österreich
#  ?sitelink schema:about ?item .
# ?sitelink schema:isPartOf <https://de.wikipedia.org/> .
#  OPTIONAL {?item wdt:P625 ?geo }  
#  FILTER (!bound(?geo))   # nur jene OHNE geographische Koordindaten (P625)
#  # FILTER (bound(?geo))   # nur jene MIT geographische Koordindaten (P625)
# }



# SELECT ?item ?geo ?sitelink  WHERE {
# ?item wdt:P31 wd:Q34038.
# ?item wdt:P17 wd:Q664. 
#  ?sitelink schema:about ?item .
# ?sitelink schema:isPartOf <https://de.wikipedia.org/> .
#  OPTIONAL {?item wdt:P625 ?geo }  
#  FILTER (!bound(?geo))   # nur jene OHNE geographische Koordindaten (P625)
# }

####################
####################
####################
####################
# https://w.wiki/wsn
#
# https://query.wikidata.org/#%20SELECT%20%3Fitem%20%3Fgeo%20%3Fsitelink%20%20WHERE%20%7B%0A%20%20%3Fitem%20wdt%3AP17%20wd%3AQ574.%20%20%20%23%20%C3%96sterreich%0A%20%20%3Fsitelink%20schema%3Aabout%20%3Fitem%20.%0A%20%3Fsitelink%20schema%3AisPartOf%20%3Chttps%3A%2F%2Fde.wikipedia.org%2F%3E%20.%0A%20%20OPTIONAL%20%7B%3Fitem%20wdt%3AP625%20%3Fgeo%20%7D%20%20%0A%20%20FILTER%20%28%21bound%28%3Fgeo%29%29%20%20%20%23%20nur%20jene%20OHNE%20geographische%20Koordindaten%20%28P625%29%0A%20%20%23%20FILTER%20%28bound%28%3Fgeo%29%29%20%20%20%23%20nur%20jene%20MIT%20geographische%20Koordindaten%20%28P625%29%0A%20%7D
####################
#https://query.wikidata.org/
####################
# SELECT ?item ?geo ?sitelink  WHERE {
#  ?item wdt:P17 wd:Q574.   # Osttimor
#  ?sitelink schema:about ?item .
# ?sitelink schema:isPartOf <https://de.wikipedia.org/> .
#  OPTIONAL {?item wdt:P625 ?geo }  
#  FILTER (!bound(?geo))   # nur jene OHNE geographische Koordindaten (P625)
# }
####################
####################
####################


# Q486972 - Siedlung
# Q17376095 - Katastralgemeinde in Österreich

# verwaltungseinheit in österreich - oder unterklasse
#   ?item p:P31/ps:P31/wdt:P279* wd:Q361733. 

#  ?item p:P31/ps:P31/wdt:P279* wd:Q486972. # siedlung oder unterklasse

# TODO: deutschland - stadtviertel oder ortsteil 
# TODO: deutschland - ortsteil 


####################
####################
# Bauwerk: Q811979
####################
####################
####################




# FIXME:  stellt: auf astronomischem Körper (P376): Mond (Q405) 

####################
##### https://w.wiki/3nL2
####################
####################
####################
####################
####################
# { ?item wdt:P17 wd:Q183 . } UNION { ?item wdt:P17 wd:Q39 . } UNION { ?item wdt:P17 wd:Q40 . }   # Staat: Deutschland oder Schweiz oder Österreich
# SELECT ?item ?geo ?sitelink  WHERE {
#  { ?item wdt:P31 wd:Q811979 . } UNION { ?item wdt:P31 wd:Q41176 . } UNION { ?item wdt:P31 wd:Q123705 . } UNION { ?item wdt:P31 wd:Q253019 . } UNION { ?item wdt:P31 wd:Q23413 . } UNION { ?item wdt:P31 wd:Q1015644 . } UNION { ?item wdt:P31 wd:Q16970 . } UNION { ?item wdt:P31 wd:Q3914 . } UNION { ?item wdt:P31 wd:Q8502 . } UNION { ?item wdt:P31 wd:Q355304 . } UNION { ?item wdt:P31 wd:Q337567 . } UNION { ?item wdt:P31 wd:Q34627 . }  UNION { ?item wdt:P31 wd:Q4632675 . } UNION { ?item wdt:P31 wd:Q4989906 . } UNION { ?item wdt:P31 wd:Q39614 . } UNION { ?item wdt:P31 wd:Q79007 . } UNION { ?item wdt:P31 wd:Q846659 . } UNION { ?item wdt:P31 wd:Q350895 . }  # Bauwerk, Gebäude, Stadtviertel oder Ortsteil, Ortsteil, Burg, Burgstall, Kirchengebäude, Schule, Berg, Fließgewässer, Stillgewässer, Synagoge, Wohnplatz, Denkmal,Friedhof, Innerortsstraße, jüdischer Friedhof , Wüstung
#
#  ?sitelink schema:about ?item .
#  ?sitelink schema:isPartOf <https://de.wikipedia.org/> .
#  OPTIONAL {?item wdt:P625 ?geo }  
#  FILTER (!bound(?geo))   # nur jene OHNE geographische Koordindaten (P625)
#  # FILTER (bound(?geo))   # nur jene MIT geographische Koordindaten (P625)
#  MINUS { ?item wdt:P376 wd:Q405 . } # ohne astronomischem Körper (P376): Mond (Q405) 
# }
####################
####################
####################
####################

# Schule (Q3914)
# Berg (Q8502)
# Fließgewässer (Q355304)
# Stillgewässer (Q337567)
# Synagoge (Q34627)
# Wohnplatz (Q4632675)
# Denkmal (Q4989906)
# Friedhof (Q39614)
# Innerortsstraße (Q79007)
# jüdischer Friedhof (Q846659)
# Wüstung (Q350895)



#  ?item wdt:P31 wd:Q811979.   # Bauwerk
#  ?item wdt:P31 wd:Q41176.   # Gebäude (Q41176)
#  ?item wdt:P31 wd:Q123705.   # Stadtviertel oder Ortsteil
#  ?item wdt:P31 wd:Q253019.   # Ortsteil (Q253019)
#  ?item wdt:P31 wd:Q23413.   # Burg (Q23413)
#  ?item wdt:P31 wd:Q1015644.   # Burgstall (Q1015644)
#  ?item wdt:P31 wd:Q16970.   #Kirchengebäude (Q16970)

######  ?item wdt:P17 wd:Q183.   # Deutschland




    
# https://metacpan.org/pod/Geo::Coordinates::Transform
# use Geo::Coordinates::Convert;
# https://packages.debian.org/buster/libgeo-coordinates-utm-perl

# https://packages.debian.org/buster/all/libgeo-coordinates-utm-perl/filelist
# https://metacpan.org/pod/Geo::Coordinates::UTM

# apt-get install libgeo-coordinates-utm-perl
 
#########################
# aus # use Geo::Coordinates::DecimalDegrees;
sub dms2decimal {
    my $latitude_or_longitude = $_[0];
    my ($degrees, $minutes, $seconds) = split (/\//,$latitude_or_longitude);
    my $decimal;
    if ($degrees >= 0) {
	$decimal = $degrees + $minutes/60 + $seconds/3600;
    } else {
	$decimal = $degrees - $minutes/60 - $seconds/3600;
    }
    return $decimal;
} 
#########################
# my $north = '46/44/32/N';
# my $north_dec = dms2decimal($north);
# print "NORTH:$north:NORTH_DEC:$north_dec:\n";
#########################
# my $east = '13/51/01/E';
# my $east_dec = dms2decimal($east);
# print "EAST:$east:EAST_DEC:$east_dec:\n";
#########################


# my $INFILE = 'list.txt';
# my $INFILE = 'query.csv';
my $INFILE = '/home/m2k/Downloads/query.csv';

open ( IN, "< $INFILE") || die("cannot open $INFILE: $! \n");

my $count =0 ;
while(<IN>)
{
    chop;
    my ($QID, $geo, $sitelink) = split (/\,/,$_);

    $QID =~ s/http:\/\/www.wikidata.org\/entity\///og;
    


  # print "=============\n";  print "QID:$QID:SL:$sitelink:\n";
    
   

#     my $url = URLEncode($sitelink);


     my $url = $sitelink;

     #my $url = 'https://de.wikipedia.org/wiki/Torfjanoje_(Kaliningrad,_Osjorsk)';

     
###################     
     if (defined($urllist{$url})) { 
      # print "URL $url bereits geprueft\n"; 
      print OUT "$url\n"; # bereits gepruefte URL, beim naechsten durchgang nicht nochmals pruefen
#print "URL $url bereits geprüft - ignore\n";
       next; 
    }
###################     
   
       my $check_url = $url.'?action=raw';
       
       
#my $check_url = 'https://de.wikipedia.org/wiki/H%C3%BCbnersm%C3%BChle?action=raw';
       
     #   print "check URL:$check_url:\n"; # exit;
   print OUT "$url\n"; # bereits gepruefte URL, beim naechsten durchgang nicht nochmals pruefen
 
 
    $agent->get( $check_url );
  my $result2 = $agent->content;
#   print "RESULT:$result2:\n"; exit;

#       if ($result2 =~ /Wikidata infobox/i) {
#        print STDERR "Lemma $check_url hat Wikidata Infobox - do nothing\n";
#        next;
 #    } 

 my $north = "";
my $east = "";

    #  {{Coordinate|NS=47.32361|EW=16.085556|type=city|region=AT-1}}
   # old      if ($result2 =~ /(\s*)\{\{Coordinate?(\s*)\|(\s*)NS(\s*)=(\s*)([0-9\.]+)(\s*)\|(\s*)EW(\s*)=(\s*)([0-9\.]+)(\s*)/i) {

#      if ($result2 =~ /(\s*)\{\{Coordinate?(\s*)\|(article=\/\|)?(\s*)NS(\s*)=(\s*)([0-9\.]+)(\s*)\|(\s*)EW(\s*)=(\s*)([0-9\.]+)(\s*)/i) {
      if ($result2 =~ /\|(\s*)NS(\s*)=(\s*)([0-9\.\/N]+)(\s*)\|(\s*)EW(\s*)=(\s*)([0-9\.\/E]+)(\s*)/i) {
     #     print "*** Coordinate(1): 1:$1:2.$2:3:$3:4:$4:5:$5:6:$6:7:$7:8:$8:9:$9:10:$10:11:$11:12:$12:\n";
# $north = $7;
# $east = $12;
 $north = $4;
 $east = $9;
    if ( $north =~ /\//) {
     $north = dms2decimal($north);
    }
        if ( $east =~ /\//) {
     $east = dms2decimal($east);
    }
}

#      if ($result2 =~ /(\s*)\{\{Coordinate?(\s*)\|(article=\/\|)?(\s*)NS(\s*)=(\s*)([0-9\.]+)(\s*)\|(\s*)EW(\s*)=(\s*)([0-9\.]+)(\s*)/i) {
#          print "*** Coordinate: 1:$1:2.$2:3:$3:4:$4:5:$5:6:$6:7:$7:8:$8:9:$9:10:$10:11:$11:12:$12:\n";
#$north = $7;
#$east = $12;
#}


#FIXME
# { "type": "unknown", "text": "@48/41/46/N/15/57/17/E" }


# | Breitengrad           = 53.197671 <!-- Quelle: bb-viewer.geobasis-bb.de -->
# | Längengrad            = 12.117839 <!-- Quelle: bb-viewer.geobasis-bb.de -->


#### 12.8.2021    if ($result2 =~ /(\s*)\|(\s*)(Breitengrad|BREITE)(\s*)=(\s*)(.+)/i) {
    if ($result2 =~ /(\s*)\|(\s*)(Breitengrad|Breitengrad1|BREITE)(\s*)=(\s*)([^|]+)(\s*)/i) {
 # print "***Breitengrad***6:$6:7:$7:\n";
  
 $north = $6;
 $north =~ s/<.+?>//g; # drop all HTML tags, including remarks
 $north =~ s/^(\s)*//og; # trim
 $north =~ s/(\s)*$//og; # trim
   if ( $north =~ /\//) {
     $north = dms2decimal($north);
    }
      }


#### 12.8.2021 if ($result2 =~ /(\s*)\|(\s*)(L(.+)ngengrad|L(.+)NGE)(\s*)=(\s*)(.+)/i) {
if ($result2 =~ /(\s*)\|(\s*)(L(.+)ngengrad|L(.+)ngengrad1|L(.+)NGE)(\s*)=(\s*)([^|]+)(\s*)/i) {
#  print "***Laengengrad:***8:$8:\n";
  #       print "*** Coordinate: 1:$1:2.$2:3:$3:4:$4:5:$5:6:$6:7:$7:8:$8:9:$9:10:$10:11:$11:\n";
 $east = $9;
 $east =~ s/<.+?>//g; # drop all HTML tags, including remarks
 $east =~ s/^(\s)*//og; # trim
 $east =~ s/(\s)*$//og; # trim
 if ( $east =~ /\//) {
   $east = dms2decimal($east);
 }

 }
# FIXME
  
# exit;


  if ($result2 =~ /Object location/i) {
      # print "Lemma $check_url hat Object location\n";
      if ($result2 =~ /(\s*)\{\{Object location( dec)?(\s*)\|(\s*)([0-9\.]+)(\s*)\|(\s*)([0-9\.]+)(\s*)\}/i) {
       #  print "*** HIER: 1:$1:2.$2:3:$3:4:$4:5:$5:6:$6:7:$7:8:$8\n";
$north = $5;
$east = $8;
     }
        # print "Lemma $check_url hat location $north $east:\n";
   } # Baudenkmal
   
# {{Coordinate|NS=51.313414|EW=9.670555|type=building|region=DE-HE}}
#  if ($result2 =~ /Coordinate/i) {
#       print "Lemma $check_url hat Coordinate\n";
#      if ($result2 =~ /(\s*)\{\{Coordinate|NS=(\s*)\|EW=(\s*)([0-9\.]+)(\s*)\|/i) {
#         print "*** HIER: 1:$1:2.$2:3:$3:4:$4:5:$5:6:$6:7:$7:8:$8\n";
#$north = $5;
#$east = $8;
#     }
#        # print "Lemma $check_url hat location $north $east:\n";
#   } # Baudenkmal
   
   
#########################
#########################
#########################
     if ($result2 =~ /(\s*)\|lat_deg(\s*)=(\s*)([0-9\.]+)(\s*)\|lat_min(\s*)=(\s*)([0-9\.]+)(\s*)\|lat_sec(\s*)=(\s*)([0-9\.]+)(\s*)/i) {
#         print "*** HIER: 1:$1:2.$2:3:$3:4:$4:5:$5:6:$6:7:$7:8:$8:9:$9:10:$10:11:$11:12:$12:\n";
 $north = $4.'/'.$8.'/'.$12.'/N';
 $north = dms2decimal($north);
# print "NORTH:$north:NORTH_DEC:$north_dec:\n";

}     

     if ($result2 =~ /(\s*)\|lon_deg(\s*)=(\s*)([0-9\.]+)(\s*)\|lon_min(\s*)=(\s*)([0-9\.]+)(\s*)\|lon_sec(\s*)=(\s*)([0-9\.]+)(\s*)/i) {
#         print "*** HIER: 1:$1:2.$2:3:$3:4:$4:5:$5:6:$6:7:$7:8:$8:9:$9:10:$10:11:$11:12:$12:\n";
 $east = $4.'/'.$8.'/'.$12.'/E';
 $east = dms2decimal($east);
# print "NORTH:$north:NORTH_DEC:$north_dec:\n";

}     

#   |lat_deg =54 |lat_min =20 |lat_sec =58
# |lon_deg =22 |lon_min =13 |lon_sec =31

   #########################
#########################
# my $east = '13/51/01/E';
# my $east_dec = dms2decimal($east);
# print "EAST:$east:EAST_DEC:$east_dec:\n";
#########################
#########################
#########################

   ##############

 
    # print "KAT:$kat:LEMMA_MIT:$lemma_mit_klammerzusatz:LEMMA_OHNE:$lemma_ohne_klammerzusatz:\n";
    

if (($north ne "") && ($east ne "")) {
  my $cord = '@'.$north.'/'.$east;
  # FIXME

# if (($cord !~ /grad/iog) && (($cord !~ /nutz/iog)) {
if ($cord !~ /[A-Z]/iog) {
  
    print "$QID\tP625\t$cord\tS143\tQ48183\n";   # koordinaten 
    #FIXME
}    
    # S ... Fundstelle
#    importiert aus Wikimedia-Projekt (P143)
# deutschsprachige Wikipedia (Q48183)
#exit;
 }


    
# {{Object location|52.975743| 13.988022}}  {{Baudenkmal Brandenburg|09130507}}
# https://www.wikidata.org/wiki/Q101573281
# https://commons.wikimedia.org/wiki/Category:Dorfkirche_(Herzsprung_in_der_Uckermark)

# ytes +499‎  ‎Aussage erstellt: geographische Koordinaten (P625): 52°58'32.675"N, 13°59'16.879"E 
# Location coordinates in the form of @LAT/LON, with LAT and LON as decimal numbers.
# Example: Q3669835 TAB P625 TAB @43.26193/10.92708


}
close(IN);

close(OUT);
