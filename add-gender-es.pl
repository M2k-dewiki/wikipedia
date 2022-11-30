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

my $file_urllist = 'wikipedia-urllist-add-gender-es.txt';
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

# * [https://w.wiki/63qj Objects for humans with link to es-WP without gender-property]
#
# SELECT ?item ?sitelink  WHERE {
#   { ?item wdt:P31 wd:Q5 . }
#   ?sitelink schema:about ?item .
#   ?sitelink schema:isPartOf <https://es.wikipedia.org/> .
#   OPTIONAL {?item wdt:P21 ?gender }  
#   FILTER (!bound(?gender))   # humans without gender
# }



my %mons = ("Januar"=>'01',"Februar"=>'02',"März"=>'03',"April"=>'04',"Mai"=>'05',"Juni"=>'06',"Juli"=>'07',"August"=>'08',"September"=>'09',"Oktober"=>'10',"November"=>'11',"Dezember"=>'12');

# my $INFILE = 'list.txt';
 my $INFILE = 'query.csv';
# my $INFILE = '/home/m2k/Downloads/query.csv';
# my $INFILE = '/home/m2k/Downloads/Download';
# my $INFILE = 'Download.csv';

open ( IN, "< $INFILE") || die("cannot open $INFILE: $! \n");

my $count =0 ;
while(<IN>)
{
  chop;
#  my ($QID, §dummy,$sitelink) = split (/\,/,$_); 
  my ($QID, $sitelink) = split (/\,/,$_); 
  $sitelink =~ s/\"//og;
  $QID =~ s/\"//og;
  # my $sitelink = 'https://es.wikipedia.org/wiki/'.$title;
    
	# test
	# my $sitelink = 'https://es.wikipedia.org/wiki/Laura_Petersen';
	# my $sitelink = 'https://es.wikipedia.org/wiki/Brayden_McCarthy';
	
  my $url = $sitelink;
   $QID =~ s/http:\/\/www.wikidata.org\/entity\///og;
if (! ($QID =~ /Q[0-9]+/ )) { 
 # print "$QID ist KEINE QID\n"; 
 next ; 
 }

#    print "QID:$QID:SL:$sitelink:\n";
#next;
     
###################     
     if (defined($urllist{$url})) { 
      # print "URL $url bereits geprueft\n"; 
      print OUT "$url\n"; # bereits gepruefte URL, beim naechsten durchgang nicht nochmals pruefen
# print "URL $url bereits geprüft - ignore\n";
      next; 
    }
###################     
   
    my $check_url = $url.'?action=raw';
       
       
      
 #       print "check URL:$check_url:\n"; # exit;
   print OUT "$url\n"; # bereits gepruefte URL, beim naechsten durchgang nicht nochmals pruefen
 
 
    $agent->get( $check_url );
  my $result2 = $agent->content;
  # print "RESULT:$result2:\n";
  
my $gender = "";

# (es|fue) una 
#https://es.wikipedia.org/wiki/Laura_Petersen

# (es|fue) un  
# https://es.wikipedia.org/wiki/Brayden_McCarthy 

    if ($result2 =~ / (es|fue) una (deportista|futbolista) /i) {
	  $gender = "Q6581072"; # female
	  # $gender = "female / Q6581072"; # female
	}

    if ($result2 =~ / (es|fue) un (deportista|futbolista) /i) {
  	   $gender = "Q6581097";  # male 
  	#   $gender = "male / Q6581097";  # male 
	}
   
   ##############

 
    # print "KAT:$kat:LEMMA_MIT:$lemma_mit_klammerzusatz:LEMMA_OHNE:$lemma_ohne_klammerzusatz:\n";
    


if ($gender ne "") {
  
    print "$QID\tP21\t$gender\tS143\tQ8449\n";    
    #FIXME
}    
    # S ... Fundstelle
#    importiert aus Wikimedia-Projekt (P143)
# deutschsprachige Wikipedia (Q48183)
# spanischsprachige Wikipedia (Q8449)




# exit;

  

}
close(IN);

close(OUT);
