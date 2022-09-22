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

my $file_urllist = 'wikipedia-urllist-add-gebdat-IAAF-INAF-deportistas-es.txt';
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


# https://www.wikidata.org/wiki/User:M2k~dewiki/Tools/Enrich_Objects#Menschen%20ohne%20Geburtsdatum
# 
#SELECT ?item ?geo ?sitelink  WHERE {
#  { ?item wdt:P31 wd:Q5 . }
#  ?sitelink schema:about ?item .
#  ?sitelink schema:isPartOf <https://de.wikipedia.org/> .
#  OPTIONAL {?item wdt:P569 ?gebdat }  
#  FILTER (!bound(?gebdat))   # nur jene OHNE geographische Koordindaten (P625)
#}
#LIMIT 1000



# https://petscan.wmflabs.org/?edits%5Banons%5D=both&categories=Deportistas%7C30&cb_labels_yes_l=1&ns%5B0%5D=1&wikidata_prop_item_use=P569&interface_language=en&language=es&cb_labels_any_l=1&edits%5Bbots%5D=both&wikidata_item=with&project=wikipedia&cb_labels_no_l=1&since_rev0=&depth=1&wpiu=none&edits%5Bflagged%5D=both&search_max_results=500&larger=&doit=


my %mons = ("Januar"=>'01',"Februar"=>'02',"März"=>'03',"April"=>'04',"Mai"=>'05',"Juni"=>'06',"Juli"=>'07',"August"=>'08',"September"=>'09',"Oktober"=>'10',"November"=>'11',"Dezember"=>'12');

# my $INFILE = 'list.txt';
# my $INFILE = 'query.csv';
# my $INFILE = '/home/m2k/Downloads/query.csv';
# my $INFILE = '/home/m2k/Downloads/Download';
 my $INFILE = 'Download.csv';

open ( IN, "< $INFILE") || die("cannot open $INFILE: $! \n");

my $count =0 ;
while(<IN>)
{
    chop;

    my ($number,$title,$pageid,$namespace,$length,$touched,$QID) = split (/\,/,$_); 
 $title =~ s/\"//og;
 $QID =~ s/\"//og;
my $sitelink = 'https://es.wikipedia.org/wiki/'.$title;
    
#    my ($QID, $geo, @sitelink_rest) = split (/\,/,$_); 
#    my ($QID,  @sitelink_rest) = split (/\,/,$_);
#    my $sitelink = "";
#    foreach my $part (@sitelink_rest) {
#      if ($sitelink eq "") {
#        $sitelink = $part; 
#      } else {
#        $sitelink = $sitelink . ",".$part;
#      }
#    }
#    $sitelink =~ s/\"//og;
#   $QID =~ s/http:\/\/www.wikidata.org\/entity\///og;
    
# if (! ($QID =~ s/Q[0-9]+/ )) { print "$QID ist KEINE QID"; next ; }

#    print "QID:$QID:SL:$sitelink:\n";
    
#  $sitelink = 'https://de.wikipedia.org/wiki/Anne-Monika_Spallek'; $QID = 'Q102180722';

#$sitelink = 'https://es.wikipedia.org/wiki/Laura_Petersen';
#$sitelink = 'https://es.wikipedia.org/wiki/Grace_Ariola';

#     my $url = URLEncode($sitelink);
     my $url = $sitelink;

     
###################     
     if (defined($urllist{$url})) { 
      # print "URL $url bereits geprueft\n"; 
      print OUT "$url\n"; # bereits gepruefte URL, beim naechsten durchgang nicht nochmals pruefen
# print "URL $url bereits geprüft - ignore\n";
      next; 
    }
###################     
   
       my $check_url = $url.'?action=raw';
       
       
#my $check_url = 'https://de.wikipedia.org/wiki/H%C3%BCbnersm%C3%BChle?action=raw';
       
 #       print "check URL:$check_url:\n"; # exit;
   print OUT "$url\n"; # bereits gepruefte URL, beim naechsten durchgang nicht nochmals pruefen
 
 
    $agent->get( $check_url );
  my $result2 = $agent->content;
  # print "RESULT:$result2:\n";
  

 my $gebdat = "";
my $jahr= 0;
my $monat = 0;
my $tag = 0;

#https://es.wikipedia.org/wiki/Laura_Petersen
# |fecha nacimiento    = {{Fecha|28|12|2000}}

# https://es.wikipedia.org/wiki/Brayden_McCarthy 
# |fecha nacimiento    = {{Fecha|20|12|1997|edad}}

    if ($result2 =~ /\|(\s*)fecha nacimiento(\s*)=(\s*)\{\{Fecha\|([0-9]{1,2})\|([0-9]{1,2})\|([0-9]{4})(\|edad)?\}\}/i) {
	
# print "*************\n";
#          print "*** GEBDAT(1): 1:$1:2.$2:3:$3:4:$4:5:$5:6:$6:7:$7:8:$8:9:$9:10:$10:11:$11:12:$12:\n";
#print "*************\n";
$tag = $4;
$monat = $5;
$jahr  = $6;


# print "TAG:$tag:MONAT:$monat:JAHR:$jahr:\n";


my $tag_s = sprintf("%02d",$tag);
my $jahr_s = sprintf("%04d",$jahr);
my $monat_s = sprintf("%02d",$monat);

# Time values must be in format eg +1967-01-17T00:00:00Z/11, where /11 designates the precision. The precision is: 0 - billion years, 1 - hundred million years, ..., 6 - millennium, 7 - century, 8 - decade, 9 - year (default), 10 - month, 11 - day, 12 - hour, 13 - minute, 14 - secon


my $precision = 10;


if ($tag > 0)  { $precision = 11; }

if ($jahr > 0) {
  # $gebdat = "$tag_s. $monat_s $jahr\n";
  $gebdat = "+".$jahr_s."-".$monat_s."-".$tag_s.'T00:00:00Z/'.$precision;
}
  
# Example: Q41576483 TAB P569 TAB +1839-00-00T00:00:00Z/9
# Meaning: add to Bronisław Podbielski (Q41576483) Geburtsdatum (P569) +1839


	}


   
   ##############

 
    # print "KAT:$kat:LEMMA_MIT:$lemma_mit_klammerzusatz:LEMMA_OHNE:$lemma_ohne_klammerzusatz:\n";
    


if ($gebdat ne "") {
  
    print "$QID\tP569\t$gebdat\tS143\tQ8449\n";    
    #FIXME
}    
    # S ... Fundstelle
#    importiert aus Wikimedia-Projekt (P143)
# deutschsprachige Wikipedia (Q48183)
# spanischsprachige Wikipedia (Q8449)



#######################################
# IAAF
#######################################
#https://es.wikipedia.org/wiki/Laura_Petersen
my $IAAF = "";
#{{wat|id=14763258}}
 if ($result2 =~ /\{\{wat\|id\=([0-9]+)\}\}/i) {
$IAAF = $1;
# print "*************\n";
# print "IAAF:$1:\n";
# print "*************\n";
   print "$QID\tP1146\t\"$IAAF\"\tS143\tQ8449\n";
    # S ... Fundstelle
#    importiert aus Wikimedia-Projekt (P143)   
# spanischsprachige Wikipedia (Q8449)
}	 
#######################################


#######################################
# FINA 
#######################################
#https://es.wikipedia.org/wiki/Grace_Ariola
my $FINA = "";
#{{fina|id=1002647}}
 if ($result2 =~ /\{\{fina\|id\=([0-9]+)\}\}/i) {
$FINA = $1;
# print "*************\n";
# print "FINA:$1:\n";
# print "*************\n";
#FINA athlete ID (P3408)
   print "$QID\tP3408\t\"$FINA\"\tS143\tQ8449\n";
    # S ... Fundstelle
#    importiert aus Wikimedia-Projekt (P143)   
# spanischsprachige Wikipedia (Q8449)
}	 
#######################################


#######################################
# FDR
#######################################
#https://es.wikipedia.org/wiki/Ralf_Rienks
my $FDR = "";
# {{fdr|id=46957}}
 if ($result2 =~ /\{\{fdr\|id\=([0-9]+)\}\}/i) {
$FDR = $1;
# print "*************\n";
# print "FDR:$1:\n";
# print "*************\n";
#FISA-ID (numerisches Format) (P2091)
   print "$QID\tP2091\t\"$FDR\"\tS143\tQ8449\n";
    # S ... Fundstelle
#    importiert aus Wikimedia-Projekt (P143)   
# spanischsprachige Wikipedia (Q8449)
}	 
#######################################



# exit;

  

}
close(IN);

close(OUT);
