#!/usr/bin/perl

use strict;

# Crypt::SSLeay muss installiert sein fuer SSL-Support
# apt-get install libwww-mechanize-perl libio-socket-ssl-perl libnet-ssleay-perl
use WWW::Mechanize;
use Data::Dumper;
use HTML::FormatText;

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


my $startURL = 'https://commons.wikimedia.org/wiki/Category:Cultural_heritage_monuments_in_Saxony-Anhalt_not_in_Wikidata';
    

my $outfile = "out-sachsen-anhalt.txt";
open ( OUT, "> $outfile") || die("cannot open $outfile: $! \n");

my $newURL = followURL($startURL);
while ($newURL ne "") {
  $startURL = $newURL;
  print "startURL:$startURL:\n";
  $newURL = followURL($startURL);
}

close(OUT);

exit;


# FIXME: wie zwischen previous und next unterscheiden ?!?

sub followURL {
  my $URL = $_[0];
  $URL =~ s/\#(.*)// ;
  $agent->get($URL);
  # print Dumper($agent);
  # print "===========================\n";
  
  my $result = $agent->content;
  # print "RESULT:$result:";
  
  my $next = "";
  # my @links = $agent->find_all_links( title_regex => qr/\/next page/ );
  my @links = $agent->find_all_links( );
  for my $link ( @links ) {
      my $found_url = $link->url_abs;
      if ($found_url =~ /subcatfrom=/) {
          $found_url =~ s/\#(.*)// ;
	  # print "URL:$found_url:Title: ", $link->attrs->{title}."\n";
	  if ($found_url ne $URL) {
  	$next = $found_url;
  	last;
	  }
      }
  }
  # print "NEXT:$next:\n";
  # exit;
  # return $next;
# }



 my @links = $agent->find_all_links( url_regex => qr/\/Category\:/ );
# my @links = $agent->find_all_links( url_regex => qr/\/wiki\/Benutzer\:/ );

my $count = 0;
for my $link ( @links ) {
    my $url = $link->url_abs;
    # print "Title: ", $link->attrs->{title}."\n";    next;
    
 #    print "============================\n";
 # print "LINK:$url:\n";

     # https://commons.wikimedia.org/wiki/Category:M%C3%BCnchner_Torturm_(M%C3%BChldorf_am_Inn)?action=raw

     #test
     # $url = 'https://commons.wikimedia.org/wiki/Category:Mangfallpark_S%C3%BCd_(Rosenheim)';
     # $url = 'https://commons.wikimedia.org/wiki/Category:F%C3%A4rberstra%C3%9Fe_19_(Rosenheim)';
    # $url = 'https://commons.wikimedia.org/wiki/Category:Interior_of_St._Nikolaus_(M%C3%BChldorf_am_Inn)';
    # $url = 'https://commons.wikimedia.org/wiki/Category:M%C3%BCnchener_Stra%C3%9Fe_3_(Abensberg)';
    # $url = 'https://commons.wikimedia.org/wiki/Category:Kaiserstra%C3%9Fe_11_(Rosenheim)';
    
     my $lemma = "";
     my $lemma_decode = "";
     if ($url =~ /Category:(.*)$/) {
        $lemma = $1;
	$lemma_decode = URLDecode($lemma);
	$lemma_decode =~ s/_/ /og;
    }
  #     print "LEMMA:$lemma:DECODE:$lemma_decode:\n";
     
        my $QID = get_WD_ID_for_URL("Category:".$lemma);
     
       my $check_url = $url.'?action=raw';
  #     print "check URL:$url:\n";
  $agent->get( $check_url );
  my $result2 = $agent->content;
  # print "RESULT:$result2:\n";
  if ($result2 =~ /Baudenkmal Sachsen-Anhalt/i) {
     # print "Lemma $check_url hat Baudenkmal-ID\n";

     
     my $blfd_id = "";
	       if ($result2 =~ /(\s*)\{\{Baudenkmal Sachsen-Anhalt(\s*)\|(1=)?(\s*)([0-9 ]+)/i) {
#            print "*** HIER: $1:$2:$3:$4:\n";
#           $blfd_id = $4;
           $blfd_id = $5;
           $blfd_id =~ s/ //og; # allfälliges leerzeichen aus denkmal entfernen
           
     }
#	 print "Lemma $check_url / QID:$QID: hat Baudenkmal-ID $blfd_id:\n";

# if ($count == 5) { exit ; }
	
	if (($blfd_id ne "") && ($QID > 0)) {

	#  Quickstatement ausgeben

print "Q".$QID."\t"."P9148\t\"".$blfd_id."\"\n";
    $count++;

	}

  } else {
   #  print "Lemma $check_url - Kein Baudenkmal\n";
  }

  #  exit;
     
}


return $next;
}  # end sub

  

exit 0;




## from ~/dokumente/wiki $ less get-denkmalliste-ids.pl 


sub get_WD_ID_for_URL {
  my $lemma = $_[0];
  my $QID = 0;
  
##  https://commons.wikimedia.org/w/api.php?action=query&prop=pageprops&titles=Category:Abendstra%C3%9Fe%2012%20(Magdeburg)&format=json
  
#  my $checkURL = 'https://commons.wikipedia.org/w/api.php?action=query&prop=pageprops&titles='.URLEncode($lemma).'&format=json';
  my $checkURL = 'https://commons.wikipedia.org/w/api.php?action=query&prop=pageprops&titles='.$lemma.'&format=json';
 #  print "checkURL:$checkURL:\n";
  $agent->get( $checkURL );
  my $result = $agent->content;
  # print "RESULT:$result:\n";
  if ($result =~ /\"Q([0-9]+)\"/) {
    $QID = $1;
   #  print "QID:$QID:\n";
  }
  # print "====================\n";
  return $QID;
}



