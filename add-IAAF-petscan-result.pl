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



# https://petscan.wmflabs.org/?sparql=&search_max_results=500&since_rev0=&wikidata_item=with&cb_labels_no_l=1&ns%5B0%5D=1&language=de&cb_labels_any_l=1&edits%5Bbots%5D=both&edits%5Banons%5D=both&interface_language=en&negcats=Wikipedia:L%C3%B6schkandidat%0AWikipedia:Schnelll%C3%B6schen&cb_labels_yes_l=1&categories=Wikipedia:World%20Athletics%20ID%20fehlt%20auf%20Wikidata%0APerson%20nach%20Geschlecht&project=wikipedia&show_redirects=no&depth=1&edits%5Bflagged%5D=both&before=&doit=




# my $INFILE = 'Download';
# my $INFILE = '/home/m2k/Downloads/Download.csv';
 my $INFILE = 'Download.csv';

open ( IN, "< $INFILE") || die("cannot open $INFILE: $! \n");

my $count =0 ;
while(<IN>)
{
    chop;
my $line = $_;
$line =~ s/\"//og;

    my ($number,$title,$pageid,$namespace,$length,$touched,$Wikidata) = split (/\,/,$line);

    if ($title eq "title") { next; }
    
    
    my $QID = $Wikidata;
  my $sitelink = $title;
  my $IAFF= "";
  
    # print "QID:$QID:SL:$sitelink:\n";
    
   
     # my $url = $sitelink;

     my $url = URLEncode($sitelink);
    
#   https://de.wikipedia.org/wiki/Sarah_Freitas
       my $check_url = 'https://de.wikipedia.org/wiki/'.$url.'?action=raw';
       # print "check URL:$check_url:\n"; exit;

    $agent->get( $check_url );
  my $result2 = $agent->content;
  # print "RESULT:$result2:\n";
  

 my $IAAF = "";



##################
# * {{World Athletics|14524845}}
      if ($result2 =~ /(\s*)\{\{World Athletics(\s*)\|([0-9\.]+)(\s*)\}\}/i) {
         # print "*** IAAF: 1:$1:2.$2:3:$3:4:$4:5:$5:6:$6:7:$7:8:$8:9:$9:10:$10:11:$11:12:$12:\n";
 $IAAF = $3;
}
##################


##################
# * {{World Athletics|ID=14524845}}
      if ($result2 =~ /(\s*)\{\{World Athletics(\s*)\|(\s*)ID(\s*)\=(\s*)([0-9\.]+)(\s*)\}\}/i) {
      #   print "*** IAAF: 1:$1:2.$2:3:$3:4:$4:5:$5:6:$6:7:$7:8:$8:9:$9:10:$10:11:$11:12:$12:\n";
 $IAAF = $6;
}
##################
 

if ($IAAF ne "") {
  # FIXME
    print "$QID\tP1146\t\"$IAAF\"\tS143\tQ48183\n";   
    # S ... Fundstelle
#    importiert aus Wikimedia-Projekt (P143)
# deutschsprachige Wikipedia (Q48183)

    
    #FIXME
 }

# exit;


}
close(IN);
