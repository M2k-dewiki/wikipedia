#!/usr/bin/perl

use strict;

# Crypt::SSLeay muss installiert sein fuer SSL-Support
# apt-get install libwww-mechanize-perl libio-socket-ssl-perl libnet-ssleay-perl
use WWW::Mechanize;
use Data::Dumper;
use HTML::FormatText;

# sudo apt-get install libjson-perl
# examples: http://www.dispersiondesign.com/articles/perl/json_data
# use JSON::PP;
#### use JSON::Parse 'parse_json';


#http://glennf.com/writing/hexadecimal.url.encoding.html
# This pattern takes the hex characters and decodes them back into real characters. The function hex() turns a hex number into decimal; there is no dec() that does the reverse in perl. The "e" at the end of the regexp means "evaluate the replacement pattern as an expression."
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


my $USER_AGENT='Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.101 Safari/537.36';

# See the autocheck parameter, which turns all HTTP errors into fatal errors. When you turn autocheck off, you will need to do all error checking yourself.
my $agent = WWW::Mechanize->new( agent => $USER_AGENT,  autocheck => 0 );


my $outfile = "suedtirol-out-umschluesselung.txt";
open ( OUT, "> $outfile") || die("cannot open $outfile: $! \n");



# Dokumentation:
# https://en.wikipedia.org/w/api.php
# https://de.wikipedia.org/w/api.php 
# https://de.wikipedia.org/w/api.php?action=help&modules=query
# https://de.wikipedia.org/w/api.php?action=help&modules=query%2Bpageprops

# https://stackoverflow.com/questions/38527828/how-to-query-wikidata-items-using-its-labels

# https://query.wikidata.org/sparql?query=
# 
# SELECT ?item ?sitelink WHERE {
# FILTER(CONTAINS(LCASE(?sitelink), "Kategorie:Bodendenkmal in Rohr in Niederbayern")).
#  ?sitelink 	schema:about ?item ;
#  schema:isPartOf <https://de.wikipedia.org/> .
# }


# https://de.wikipedia.org/wiki/Liste_der_Bodendenkm%C3%A4ler_in_Rohr_in_Niederbayern?action=info
# ==> Wikidata-Objektkennung	Q97643764


# https://de.wikipedia.org/w/api.php?action=query&prop=pageprops&titles=Kategorie:Bodendenkmal%20in%20Rohr%20in%20Niederbayern&format=json

########################

# 1) liste der kategorien nach "input-list-kategorie-liste-crossreferences.txt" schreiben:

# https://petscan.wmflabs.org/?&cb_labels_any_l=1&categories=Liste%20(Bodendenkm%C3%A4ler%20in%20Bayern)%0A&project=wikipedia&edits%5Banons%5D=both&edits%5Bflagged%5D=both&search_max_results=500&edits%5Bbots%5D=both&cb_labels_no_l=1&language=de&cb_labels_yes_l=1&ns%5B0%5D=1&interface_language=en&show_redirects=no&doit=

########################

# https://de.wikipedia.org/wiki/Kategorie:Liste_(Baudenkm%C3%A4ler_in_S%C3%BCdtirol)
my $INFILE = 'suedtirol-list.txt';
open ( IN, "< $INFILE") || die("cannot open $INFILE: $! \n");

my $count =0 ;
while(<IN>)
{
    chop;
    my $list = $_;
    $list =~ s/^(\s)*//og; # trim                                                                                                                                                                                                             
    $list =~ s/(\s)*$//og; # trim
    $list =~ s/_/ /og; # trim                                                                                                                                                                                                             

    print "LIST:$list:\n";
    
    my $QID_LIST = get_WD_ID_for_URL($list);
    print OUT "$list\tQ".$QID_LIST."\n";
    print "Q".$QID_LIST."\t",$list."\n";

    
    my $gemeinde = $list;
    $gemeinde =~ s/Liste der Baudenkmäler in //og;

    my $QID_GEMEINDE = get_WD_ID_for_URL($gemeinde);
    print OUT "$gemeinde\tQ".$QID_GEMEINDE."\n";
    print  "Q".$QID_GEMEINDE."\t",$gemeinde."\n";


    
}    
    
 
close(IN);
close(OUT);


exit;  

sub get_WD_ID_for_URL {
  my $lemma = $_[0];
  my $QID = 0;
  my $checkURL = 'https://de.wikipedia.org/w/api.php?action=query&prop=pageprops&titles='.URLEncode($lemma).'&format=json';
  # print "checkURL:$checkURL:\n";
  $agent->get( $checkURL );
  my $result = $agent->content;
  # print "RESULT:$result:\n";
  if ($result =~ /\"Q([0-9]+)\"/) {
    $QID = $1;
    # print "QID:$QID:\n";
  } else {
      print "**** WARNING: keine QID gefunden fuer Lemma:$lemma:\n";
  }
  return $QID;
}





# https://de.wikipedia.org/w/api.php?action=query&list=categorymembers&cmtitle=Kategorie:Liste (Bodendenkmäler in Bayern)
# https://de.wikipedia.org/w/api.php?action=query&list=categorymembers&cmtitle=Kategorie%3AListe+%28Bodendenkm%C3%A4ler+in+Bayern%29&format=json

# https://de.wikipedia.org/w/api.php?action=query&list=categorymembers&cmtitle=Kategorie:Liste%20(Bodendenkm%C3%A4ler%20in%20Bayern)&cmlimit=max
# https://de.wikipedia.org/w/api.php?action=query&list=categorymembers&cmtitle=Kategorie:Liste (Bodendenkmäler in Bayern)&cmlimit=max

   
