#!/usr/bin/perl

use strict;

use LWP::UserAgent;
use Data::Dumper;
use JSON::XS;

sub wdSparqlQuery(@args) {
  my $agent = shift;
  my $query = shift;
  my $format = shift;
  my $endpointURL = "https://query.wikidata.org/sparql";
  my $queryURL = "${endpointURL}?query=${query}&format=${format}";
  my $ua = LWP::UserAgent -> new;
  $ua -> agent($agent);
  my $req = HTTP::Request -> new(GET => $queryURL);
  my $res = $ua -> request($req);
  my $str = $res -> content;
  return $str;
}


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


# https://de.wikipedia.org/wiki/Benutzer%3AZ_thomas%2FDE-NW-Stra%C3%9Fen-Aachen

# https://commons.wikimedia.org/w/index.php?title=Category:Streets_in_Aachen_by_name

# https://petscan.wmflabs.org/?search_filter=&cb_labels_no_l=1&minlinks=&combination=union&outlinks_any=&ns%5B0%5D=1&labels_no=&edits%5Banons%5D=both&interface_language=en&search_query=&source_combination=&cb_labels_yes_l=1&regexp_filter=&search_max_results=500&sitelinks_yes=&min_sitelink_count=&project=wikimedia&show_soft_redirects=both&referrer_name=&links_to_all=&ns%5B14%5D=1&wikidata_item=without&ores_prob_from=&ns%5B4%5D=1&langs_labels_any=&language=commons&negcats=Wikipedia%3AL%C3%B6schkandidat%0D%0AWikipedia%3ASchnelll%C3%B6schen&show_redirects=no&templates_any=&sortby=title&sitelinks_any=&outlinks_no=&max_age=&templates_yes=&common_wiki_other=&sitelinks_no=&max_sitelink_count=&cb_labels_any_l=1&categories=Streets+in+Aachen+by+name&sparql=&langs_labels_yes=&before=&referrer_url=&doit=&al_commands=P131%3AQ1741%0AP17%3AQ40%0AP31%3AQ79007

my $INFILE = 'list.txt';

open ( IN, "< $INFILE") || die("cannot open $INFILE: $! \n");

my $count =0 ;
while(<IN>)
{
    chop;
    my $kat = $_;
    $kat =~ s/^(\s)*//og; # trim
    $kat =~ s/(\s)*$//og; # trim
    $kat =~ s/_/ /og; # trim
    
    if ($kat eq "") { next ; }
    
    # print "KAT:$kat:\n";
    
    my $lemma_mit_klammerzusatz = $kat;  # ohne präfix "category:"
    $lemma_mit_klammerzusatz =~ s/Category://iog;
    #fixme

    my $lemma_ohne_zusatz = $lemma_mit_klammerzusatz;  # ohne präfix und klammerzusatz
    $lemma_ohne_zusatz =~ s/\,.+//og;
    $lemma_ohne_zusatz =~ s/\(.+//og;
    $lemma_ohne_zusatz =~ s/^(\s)*//og; # trim
    $lemma_ohne_zusatz =~ s/(\s)*$//og; # trim

    
    my $kat_mit_prefix = "Category:".$kat;

    
##############

   #   my $url = 'https://commons.wikimedia.org/wiki/Category:Dorfkirche_(Herzsprung_in_der_Uckermark)';
     my $url = 'https://commons.wikimedia.org/wiki/Category:'.URLEncode($kat);
    
#      my $lemma = "";
#     my $lemma_decode = "";
#     if ($url =~ /Category:(.*)$/) {
#        $lemma = $1;
#        $lemma_decode = URLDecode($lemma);
#        $lemma_decode =~ s/_/ /og;
#      }
#       print "LEMMA:$lemma:DECODE:$lemma_decode:\n";
     
       my $check_url = $url.'?action=raw';
       # print "check URL:$check_url:\n"; # exit;

    $agent->get( $check_url );
  my $result2 = $agent->content;
  # print "RESULT:$result2:\n";
  
#       if ($result2 =~ /Wikidata infobox/i) {
#        print STDERR "Lemma $check_url hat Wikidata Infobox - do nothing\n";
#        next;
#     } 


my $north = "";
my $east = "";
  if ($result2 =~ /Object location/i) {
      # print "Lemma $check_url hat Object location\n";
      if ($result2 =~ /(\s*)\{\{Object location( dec)?(\s*)\|(\s*)([0-9\.]+)(\s*)\|(\s*)([0-9\.]+)(\s*)\}/i) {
       #  print "*** HIER: 1:$1:2.$2:3:$3:4:$4:5:$5:6:$6:7:$7:8:$8\n";
$north = $5;
$east = $8;
     }
        # print "Lemma $check_url hat location $north $east:\n";
   } # Baudenkmal
   
##############

    
    # print "KAT:$kat:LEMMA_MIT:$lemma_mit_klammerzusatz:LEMMA_OHNE:$lemma_ohne_klammerzusatz:\n";
    
    
    ##############
my $query_agent = "WDQS-example "; # TODO adjust this; see https://w.wiki/CX6
my $query = '
SELECT DISTINCT ?item ?label ?itemDescription
WHERE
{
  SERVICE wikibase:mwapi
  {
    bd:serviceParam wikibase:endpoint "www.wikidata.org";
                    wikibase:api "Generator";
                    mwapi:generator "search";
                    mwapi:gsrsearch "inlabel:'.$lemma_ohne_zusatz.' köln"@de;
                    mwapi:gsrlimit "max".
    ?item wikibase:apiOutputItem mwapi:title.
  }
  ?item rdfs:label ?label. FILTER( LANG(?label)="de" )
  SERVICE wikibase:label { bd:serviceParam wikibase:language "[AUTO_LANGUAGE],de". }
  }
';

# $format = "json";
# $data = JSON::XS::decode_json(wdSparqlQuery($agent, $query, $format));

my $format = "csv";
my $data = wdSparqlQuery($query_agent, $query, $format);

# print Dumper($data);
 
 my @qid_list = ($data =~ /wikidata.org\/entity\/Q([0-9]+)/g);
# print Dumper(@list);
 my $result_count = @qid_list;
# print "COUNT:$count:\n";
   ############## 
    #### FIXME - check deaktiviert
 my $result_count = 0;     my @qid_list = ();
#### FIXME - check deaktiviert
    
if ($result_count eq 0) {    
    print "CREATE\n";
   print "LAST\tLde\t\"$lemma_ohne_zusatz\"\n"; # label de - bezeichnung
   print "LAST\tLen\t\"$lemma_ohne_zusatz\"\n"; # label de - bezeichnung

    my $alias = $lemma_ohne_zusatz;
      print "LAST\tAde\t\"".$alias.", Aachen\"\n"; # alias de - alias
      print "LAST\tAen\t\"".$alias.", Aachen\"\n"; # alias de - alias
      print "LAST\tAde\t\"".$alias." (Aachen)\"\n"; # alias de - alias
      print "LAST\tAen\t\"".$alias." (Aachen)\"\n"; # alias de - alias
  
     my $beschreibung = "Straße in Aachen";
     my $beschreibung_en = "street in Aachen";
     
     if ($lemma_ohne_zusatz =~ /platz/i) {
       $beschreibung = "Platz in Aachen";
       $beschreibung_en = "square in Aachen";
       print "LAST\tP31\tQ174782\n"; # ist eine: Platz (Q174782)
     } else {
       print "LAST\tP31\tQ79007\n"; # ist eine: Innerortsstraße
     }
     
     print "LAST\tDde\t\"$beschreibung\"\n"; # description de - beschreibung
     print "LAST\tDen\t\"$beschreibung_en\"\n"; # description en - beschreibung
     print "LAST\tScommonswiki\t\"$kat_mit_prefix\"\n"; # sitelink
    print "LAST\tP17\tQ183\n"; # Staat: Deutschland (Q183)
	
    print "LAST\tP131\tQ1017\n"; # liegt in der Verwaltungseinheit: Aachen (Q1017)
	
    print "LAST\tP373\t\"$kat\"\n";   # Commonscat-Property
 
    
    if (($north ne "") && ($east ne "")) {
  my $cord = '@'.$north.'/'.$east;
    print "LAST\tP625\t$cord\n";   # koordinaten 
 }
} else {


if ($result_count == 1) {

my $qid = @qid_list[0];
# print "===================";
    print "Q".$qid."\tScommonswiki\t\"$kat_mit_prefix\"\n"; # sitelink
    print "Q".$qid."\tP373\t\"$kat\"\n";   # Commonscat-Property
#print "===================";

     
}


# FIXME
# wenn anzahl == 1  dann automatisch verbinden

# wenn anzahl meher als 1 dann manuell




}
 
 


}
close(IN);