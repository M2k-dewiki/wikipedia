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
    # if ( $count == 10 ) { close(IN); close(OUT); exit ; }    

    # print "count:$count:\n";
    my $QID_LEMMA = get_WD_ID_for_URL($lemma);

    # print "QID_LEMMA:$QID_LEMMA:\n";
	
    if ($QID_LEMMA > 0) {
		 # öffentliches Amt oder Stellung (P39): Mitglied des schweizerischen Nationalrats (Q18510612) 
		 # Wahlperiode (P2937) - 52. Legislaturperiode des Schweizer Nationalrats (Q123495815)
#      print  "Q".$QID_LEMMA."\tP39\tQ18510612\tP2937\tQ123495815\n";


# 51. Legislaturperiode des Schweizer Nationalrats (Q72601373)
#      print  "Q".$QID_LEMMA."\tP39\tQ18510612\tP2937\tQ72601373\n";

# Abgeordneter zum Nationalrat (Q17535155)
# 28. Gesetzgebungsperiode des österreichischen Nationalrats (Q130381789)
# https://meta.wikimedia.org/wiki/QuickStatements_3.0/Documentation#Force_creation_of_duplicate_statements
#   + - > Force_creation_of_duplicate_statements

      print  "+Q".$QID_LEMMA."\tP39\tQ17535155\tP2937\tQ130381789\tP580\t+2024-10-24T00:00:00Z/11\n";

# 24. Oktober 2024
# Q42328389	P39	Q17535155	P2937	Q130381789


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


# https://de.wikipedia.org/w/api.php?action=query&prop=pageprops&titles=Kategorie%3ASpecial%20Olympics%20%28Special%20Olympics%20Albanien%29&format=json:



# https://de.wikipedia.org/w/api.php?action=query&list=categorymembers&cmtitle=Kategorie:Liste (Bodendenkmäler in Bayern)
# https://de.wikipedia.org/w/api.php?action=query&list=categorymembers&cmtitle=Kategorie%3AListe+%28Bodendenkm%C3%A4ler+in+Bayern%29&format=json

# https://de.wikipedia.org/w/api.php?action=query&list=categorymembers&cmtitle=Kategorie:Liste%20(Bodendenkm%C3%A4ler%20in%20Bayern)&cmlimit=max
# https://de.wikipedia.org/w/api.php?action=query&list=categorymembers&cmtitle=Kategorie:Liste (Bodendenkmäler in Bayern)&cmlimit=max

   
