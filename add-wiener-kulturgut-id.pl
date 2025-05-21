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



# https://petscan.wmcloud.org/?links_to_any=&ores_type=any&templates_any=&cb_labels_no_l=1&show_redirects=no&depth=2&templates_no=&project=wikimedia&common_wiki_other=&outlinks_yes=&active_tab=tab_categories&manual_list=&language=commons&output_compatability=catscan&ores_prediction=any&labels_yes=&cb_labels_any_l=1&sortby=title&search_filter=&wikidata_label_language=&before=&interface_language=en&negcats=&edits%5Bbots%5D=both&ns%5B14%5D=1&outlinks_any=&page_image=any&cb_labels_yes_l=1&max_age=&ores_prob_to=&categories=Plaques+in+Vienna+by+district&pagepile=&max_sitelink_count=&sortorder=ascending&langs_labels_yes=&ores_prob_from=&search_max_results=500&wikidata_item=with&smaller=&labels_no=&referrer_name=&sitelinks_no=&doit=



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
    
#	my $url = 'Gedenktafel_an_die_T%C3%BCrkenbelagerung_1683_(Wien,_Sterngasse_3)';
	
	#https://commons.wikimedia.org/wiki/Category:Gedenktafel_an_die_T%C3%BCrkenbelagerung_1683_(Wien,_Sterngasse_3)
	
#   https://de.wikipedia.org/wiki/Sarah_Freitas
       my $check_url = 'https://commons.wikimedia.org/wiki/Category:'.$url.'?action=raw';
#        print "check URL:$check_url:\n"; exit;

    $agent->get( $check_url );
  my $result2 = $agent->content;
   # print "RESULT:$result2:\n";
  

 my $IAAF = "";



##################
# * {{World Athletics|14524845}}
# {{Public Art Austria|95960|AT-9}}
      if ($result2 =~ /(\s*)\{\{Public Art Austria(\s*)\|([0-9\.]+)(\s*)\|/i) {
        #  print "*** (11111) IAAF: 1:$1:2.$2:3:$3:4:$4:5:$5:6:$6:7:$7:8:$8:9:$9:10:$10:11:$11:12:$12:\n";
 $IAAF = $3;
}
##################


##################
# * {{World Athletics|ID=14524845}}
# {{Public Art Austria|95960|AT-9}}
 #     if ($result2 =~ /(\s*)\{\{Public Art Austria(\s*)\|(\s*)([0-9\.]+)(\s*)\|/i) {
 #        print "*** (22222) IAAF: 1:$1:2.$2:3:$3:4:$4:5:$5:6:$6:7:$7:8:$8:9:$9:10:$10:11:$11:12:$12:\n";
 # $IAAF = $6;
# }
##################
 
 
 

if ($IAAF ne "") {
  # FIXME
    print "$QID\tP8430\t\"$IAAF\"\tS143\tQ565\n";   
    # S ... Fundstelle
#    importiert aus Wikimedia-Projekt (P143)
# deutschsprachige Wikipedia (Q48183)

# Wikimedia Commons (Q565)
    
	
	# exit;
	
	
    #FIXME
 }

# exit;


}
close(IN);
