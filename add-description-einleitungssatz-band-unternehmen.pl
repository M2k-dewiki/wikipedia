#!/usr/bin/perl

use strict;


###################
# cpan> install Text::MediawikiFormat
# cpan> install HTML::Strip
###################

use Text::MediawikiFormat 'wikiformat';
use HTML::Strip;



###################
#### $ sudo cpan
#### cpan shell -- CPAN exploration and modules installation (v2.22)
#### cpan[1]> install Text::WikiText 
###################
# sudo apt-get install libtext-mediawikiformat-perl libtext-wikiformat-perl
# https://packages.debian.org/search?suite=default&section=all&arch=any&lang=en&searchon=names&keywords=WikiFormat

#### https://metacpan.org/pod/Text::WikiFormat
### It creates HTML by default, but can produce valid POD, DocBook, XML, or any other format imaginable.

# https://packages.debian.org/search?searchon=names&keywords=html+strip
#
#### sudo apt-get install libhtml-strip-perl
#
###################

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


###########################
###
## Objekte mit Property P3596
###
##SELECT ?item ?itemLabel ?itemDescription ?value
##{
##  ?item wdt:P3596 ?value .
##  SERVICE wikibase:label { bd:serviceParam wikibase:language "de"  }
##    ?sitelink schema:about ?item .
##  ?sitelink schema:isPartOf <https://de.wikipedia.org/> .
##}
##order by ?itemDescription
##
## https://w.wiki/4jpC
#########################


#########################
# Objekte mit Property P3596
# Export von Liste mit QID, Sitelink (de-WP) und Beschreibung
#########################
# SELECT ?item ?sitelink ?itemDescription 
#{
#  ?item wdt:P3596 ?value .
#  SERVICE wikibase:label { bd:serviceParam wikibase:language "de"  }
#    ?sitelink schema:about ?item .
#  ?sitelink schema:isPartOf <https://de.wikipedia.org/> .
#}
#order by ?itemDescription
# 
#
# https://w.wiki/4jsf
#
#########################
# m2k@max: ~/dokumente/wiki $ ./add-description-einleitungssatz.pl  | grep -i nummerisch | wc -l
# 40 Datensätze mit (ausschließlich) nummerischer Beschreibung
#########################


my $file_urllist = 'wikipedia-urllist-add-description-einleitungssatz.txt';
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


my %mons = ("Januar"=>'01',"Februar"=>'02',"März"=>'03',"April"=>'04',"Mai"=>'05',"Juni"=>'06',"Juli"=>'07',"August"=>'08',"September"=>'09',"Oktober"=>'10',"November"=>'11',"Dezember"=>'12');

# my $INFILE = '/home/m2k/Downloads/query.tsv';
# my $INFILE = 'Download.csv';

# my $INFILE = 'wikidata_2NZoiQ.tsv';
my $INFILE = 'wikidata_6WHpqa.tsv';
# my $INFILE = 'wikidata_USRTdW.tsv';
# my $INFILE = 'wikidata_N2xJIM.tsv';


# Band
# https://qlever.cs.uni-freiburg.de/wikidata/P9Lasd#tsv
my $INFILE = 'wikidata_P9Lasd.tsv';

# Unternehmen
# https://qlever.cs.uni-freiburg.de/wikidata/ufhsRl
my $INFILE = 'wikidata_ufhsRl.tsv';


# Album
# https://qlever.cs.uni-freiburg.de/wikidata/wdEUwG#tsv
my $INFILE = 'wikidata_wdEUwG.tsv';

# literarisches Werk (Q7725634)
# https://qlever.cs.uni-freiburg.de/wikidata/WOCaEw#tsv
my $INFILE = 'wikidata_WOCaEw.tsv';

# musikalisches Werk/Komposition (Q105543609)
# https://qlever.cs.uni-freiburg.de/wikidata/Hx4lde#tsv
my $INFILE = 'wikidata_Hx4lde.tsv';


open ( IN, "< $INFILE") || die("cannot open $INFILE: $! \n");

my $count =0 ;
while(<IN>)
{
    chop;

# my $sitelink = 'https://de.wikipedia.org/wiki/'.$title;
    

    my ($QID, $sitelink, $beschreibung) = split (/\t/,$_);
#    $sitelink =~ s/\"//og;
   $QID =~ s/http:\/\/www.wikidata.org\/entity\///og;


    if (! ($QID =~ /Q[0-9]+/ )) {
	# print "$QID ist KEINE QID\n";
	next ;
    }

 my $nummerische_ID = ""; 
    if ($beschreibung =~ /^[0-9]+$/) {
      # print "Beschreibung $beschreibung $beschreibung für QID Q$QID ist nummerisch - leeren/update\n"; 
      $nummerische_ID = $beschreibung; # merken / ans ende der beschreibung in klammern anhängen
      $beschreibung = "";
    } # else { next ; }
    
    if ($beschreibung ne "") { 
     # print "Beschreibung $beschreibung ist nicht leer für QID Q$QID - ignore\n"; 
     next; 
    }
	
    $sitelink =~ s/^<//og;
    $sitelink =~ s/>$//og;
	
    $QID =~ s/^<//og;
    $QID =~ s/>$//og;
	
 #   print "QID:$QID:SL:$sitelink:BESCHREIBUNG:$beschreibung:\n";  next;
 
     my $url = URLEncode($sitelink);
     my $url = $sitelink;

     
###################     
     if (defined($urllist{$url})) { 
      # print "URL $url bereits geprueft\n"; 
#      print OUT "$url\n"; # bereits gepruefte URL, beim naechsten durchgang nicht nochmals pruefen
# print "URL $url bereits geprüft - ignore\n";
      next; 
    }
###################     
 
 
 # ohne action=raw wird nicht wiki-syntax geliefert, sondern html-text, plus navigation etc.
        my $check_url = $url.'?action=raw&section=0';
 #      my $check_url = $url;
#       https://de.wikipedia.org/wiki/Hilfe:URL-Parameter#action=raw
       
# &section=n	gibt an, welcher Abschnitt einer Seite ausgegeben werden soll, wobei n nur positive, ganzzahlige Werte akzeptiert, 0 bezeichnet den Abschnitt vor der ersten Überschrift

#my $check_url = 'https://de.wikipedia.org/wiki/H%C3%BCbnersm%C3%BChle?action=raw';
 
 
# https://www.mediawiki.org/wiki/API:Parsing_wikitext
 #
 # contentformat
# Content serialization format used for the input text. Only valid when used with text.
# Einer der folgenden Werte: application/json, application/octet-stream, application/unknown, application/x-binary, text/css, text/javascript, text/plain, text/unknown, text/x-wiki, unknown/unknown
 
#       print "check URL:$check_url:\n"; # exit;
   print OUT "$url\n"; # bereits gepruefte URL, beim naechsten durchgang nicht nochmals pruefen
 
 # https://metacpan.org/pod/Text::WikiText
 
 #######
 # 1) wiki -> html 
 # 2) strip all html-tags
 #######
  
 ########
 #### Parse::BBCode
 ########
 
 
    $agent->get( $check_url );
  my $result2 = $agent->content;
  
  
  
  ########### für rein textliche einleitungssätze - allfällige infoboxen und vorlagen entfernen
  # $result2 =~ s|\n| |g; # newlines entfernen
  # $result2 =~ s|\r| |g; # carrige return entfernen
  ##### $result2 =~ s|\{\{Infobox.+?\}\}||g; # vorlage/infobox entfernen
  ##### $result2 =~ s|\{\{daS.+?\}\}||g; # dänisch
  # $result2 =~ s|\{\{.+?\}\}||g; # vorlagen entfernen
  ########### für rein textliche einleitungssätze


  #  print "RESULT:$result2:\n";

   
 
# use Text::WikiText;
#use Text::WikiText::Output::HTML;
#
#my $parser = Text::WikiText->new;
#my $document = $result2;
#
#my $html = Text::WikiText::Output::HTML->new->dump($document);
#print $html;
 
my $html = wikiformat ($result2);




# How do I remove HTML from a string?
# Use HTML::Strip, or HTML::FormatText which not only removes HTML but also attempts to do a little simple formatting of the resulting plain text.

# use HTML::TreeBuilder;
# $tree = HTML::TreeBuilder->new->parse_file("test.html");
# my $tree = HTML::TreeBuilder->new->parse($html);
# use HTML::FormatText;
#$formatter = HTML::FormatText->new(leftmargin => 0, rightmargin => 50);
#my $formatter = HTML::FormatText->new();

my $hs = HTML::Strip->new(emit_spaces => 0);
my $clean_text = $hs->parse( $html );
# $hs->eof;  

#print "========================\n";
#print "CLEAN_TEXT:$clean_text:\n";
#print "========================\n";
#print "========================\n";

#print "========================\n";
#print "HTML:$html:\n";
#print "========================\n";
#print "FORMATTER:";
#print $formatter->format($tree);
#print "========================\n";

# my $text = wikiformat ($result2, {}, {implicit_links => 1});
# print "========================\n";
# print "TEXT:$text:\n";
# print "========================\n";


# test;
# $clean_text = 'Das Großsteingrab Bistrup war eine megalithische Grabanlage der jungsteinzeitlichen Nordgruppe der Trichterbecherkultur im Kirchspiel Birkeräd in der dänischen Kommune Rudersdal. Es wurde im 19. oder frühen 20. Jahrhundert zerstört.';
 
# $result =
# Die [[bronzezeit]]liche '''Steinkiste von Horne''' befindet sich auf dem Friedhof der [[Horne Kirke (Hjørring Kommune)|Horne Kirke]] in der [[Hjørring Kommune]] im [[Vendsyssel]] in [[Region Nordjylland|Nordjütland]] in [[Dänemark]]. 
 
 my $description = "";
  if ($clean_text =~ /(ist eine|ist ein|war ein|war eine|befindet sich|liegt|wurde) ([^\.\,]+)(\.|\,)/i) {
#         print "*** MATCH:1: 1:$1:2.$2:3:$3:4:$4:5:$5:6:$6:7:$7:8:$8:9:$9:10:$10:11:$11:12:$12:\n";
	  $description = $2;

if ($1 eq 'befindet sich') { $description = $1." ".$2; }
if ($1 eq 'liegt') { $description = $1." ".$2; }
if ($1 eq 'wurde') { $description = $1." ".$2; }
  $description =~ s|\(([^\)]*)\)||g; # klammern plus inhalt entfernen
  $description =~ s/\s{2,}/ /; #remove multiple whitespaces
$description =~ s/^(\s)*//og; # trim
$description =~ s/(\s)*$//og; # trim
$description =~ s/\<ref\>.*$//og; # remove ref-tag and the rest of the line
	  
	  }
#exit;  

   
   ##############

 
#     print "KAT:$kat:LEMMA_MIT:$lemma_mit_klammerzusatz:LEMMA_OHNE:$lemma_ohne_klammerzusatz:\n";
    



if ($description ne "") {

 
   
   print "$QID\tDde\t\"".$description."\"\n";
# print "-------------\n";

}    
# exit;

  

}
close(IN);

close(OUT);
