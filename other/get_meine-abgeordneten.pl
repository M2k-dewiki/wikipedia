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



####################
# PetScan: 
#   Politiker (21. Jahrhundert) 
#   Österreicher

# https://petscan.wmcloud.org/?cb_labels_no_l=1&referrer_name=&language=de&categories=Politiker+%2821.+Jahrhundert%29%0D%0A%C3%96sterreicher&larger=&search_wiki=&combination=subset&min_redlink_count=1&manual_list=&active_tab=tab_categories&project=wikipedia&smaller=&interface_language=en&outlinks_any=&pagepile=&rxp_filter=&before=&sitelinks_yes=&since_rev0=&edits%5Bflagged%5D=both&labels_any=&show_disambiguation_pages=both&search_query=&search_filter=&cb_labels_any_l=1&max_sitelink_count=&langs_labels_yes=&output_limit=&search_max_results=500&langs_labels_no=&outlinks_no=&sitelinks_any=&edits%5Bbots%5D=both&cb_labels_yes_l=1&sitelinks_no=&links_to_no=&templates_yes=&maxlinks=&sortorder=ascending&doit=

# ===> Export CSV - list of names into list.txt

####################



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



my $INFILE = 'list.txt';
open ( IN, "< $INFILE") || die("cannot open $INFILE: $! \n");

my $count =0 ;
while(<IN>)
{
    chop;
    my $lemma = $_;
    $lemma =~ s/^(\s)*//og; # trim                                                                                                                                                                                                             
    $lemma =~ s/(\s)*$//og; # trim
    $lemma =~ s/_/ /og; # trim                                                                                                                                                                                                             
    # print ":LEMMA:$lemma:\n";   

    $count++; 
    # if ( $count == 500 ) { close(IN); close(OUT); exit ; }    
   #  if ( $count == 10 ) { close(IN); close(OUT); exit ; }    
   # if ( $count == 100 ) { close(IN); close(OUT); exit ; }    

    # print "count:$count:\n";
    my $QID_LEMMA = get_WD_ID_for_URL($lemma);

    # print "QID_LEMMA:$QID_LEMMA:\n";
	
	my $sitelink = 'https://de.wikipedia.org/wiki/'.$lemma;
	my $check_url = $sitelink.'?action=raw';
       
       
       
#my $check_url = 'https://de.wikipedia.org/wiki/Jakob_Gr%C3%BCner?action=raw';
	   
	   
 #      print "check URL:$check_url:\n"; # exit;
#  print OUT "$url\n"; # bereits gepruefte URL, beim naechsten durchgang nicht nochmals pruefen
 
 
    $agent->get( $check_url );
  my $result2 = $agent->content;
  # print "RESULT:$result2:\n";
  
  my $AID = "";
  #https://www.meineabgeordneten.at/Abgeordnete/jakob.gruener
if ($result2 =~ /www\.meineabgeordneten\.at\/Abgeordnete\/([a-z.-_]+) /i) {
# print "MATCH:0:$0:1:$1:2:$2:\n";
$AID = $1;
}
  
 # exit;
	
	
    if (($QID_LEMMA > 0) && ($AID ne "")) {

	print  "Q".$QID_LEMMA."\tP13350\t\"".$AID."\"\tS143\tQ48183\n";

    # S ... Fundstelle
#    importiert aus Wikimedia-Projekt (P143)
# deutschsprachige Wikipedia (Q48183)
    }

# print "===================\n";

    
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
  }
  return $QID;
}

