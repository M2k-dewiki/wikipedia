#!/usr/bin/perl

use strict;


######################
# # # # # https://qlever.cs.uni-freiburg.de/wikidata/3IHmlL
######################
# PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
# PREFIX schema: <http://schema.org/>
# PREFIX wd: <http://www.wikidata.org/entity/>
# PREFIX wdt: <http://www.wikidata.org/prop/direct/>
# SELECT ?item ?article WHERE 
# {
# { ?item wdt:P31 wd:Q5 . }
#   ?article schema:isPartOf <https://de.wikipedia.org/> .       
#   ?article schema:about ?item .
#   optional {?item rdfs:label ?itemLabel . filter(lang(?itemLabel)="de") }
#   MINUS {?item schema:description ?itemDescription . filter(lang(?itemDescription)="de") }
#  # FILTER (STRLEN(?itemLabel) > 0)  
#   MINUS { ?item wdt:P31/wdt:P279* wd:Q4167836 . }
#   MINUS { ?item wdt:P31 wd:Q11266439 .}
#   MINUS { ?item wdt:P31 wd:Q15184295 .}
#   MINUS { ?item wdt:P31 wd:Q11753321 .}
#   MINUS { ?item wdt:P31 wd:Q17633526 .}
#   MINUS { ?item wdt:P31 wd:Q19887878 .}
# } 
######################



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

my $file_urllist = 'wikidata_XKXbUs.csv';
my %urllist ;
if (-e $file_urllist) {
  open (IN, "< $file_urllist") || die ("Cannot open $file_urllist : $! \n");
  while (<IN>) {
    chop;
    my $line = $_;
$line =~ s/\,//og;

   $line =~ s/http:\/\/www.wikidata.org\/entity\///og;

  $line =~ s/^(\s)*//og; # trim
     $line =~ s/(\s)*$//og; # trim

#  print "$line\tDde\t\"indische Schauspielerin\"\n";      
  print "$line\tDde\t\"indischer Schauspieler\"\n";      


  }
  close(IN);
}

