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

my $USER_AGENT='Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.101 Safari/537.36';

# See the autocheck parameter, which turns all HTTP errors into fatal errors. When you turn autocheck off, you will need to do all error checking yourself.
my $agent = WWW::Mechanize->new( agent => $USER_AGENT,  autocheck => 0 );


# https://de.wikipedia.org/wiki/Spezial:Neue_Seiten

# my $startURL = 'https://commons.wikimedia.org/w/index.php?title=Category:Cultural_heritage_monuments_in_Bavaria_with_known_IDs';

#27.8.2020
my $startURL = 'https://commons.wikimedia.org/wiki/Category:Cultural_heritage_monuments_in_Bavaria_without_linked_Wikidata';
    

# my $startURL = 'https://commons.wikimedia.org/w/index.php?title=Category:Cultural_heritage_monuments_in_Bavaria_with_known_IDs&subcatfrom=++D-6-75-139-11+%0ABahnhofstra%C3%9Fe+16+%28Iphofen%29#mw-subcategories';
# my $URL = 'https://commons.wikimedia.org/w/index.php?title=Category:Cultural_heritage_monuments_in_Bavaria_with_known_IDs&subcatfrom=+D-1-61-000-642+%0AVermessungsamt+%28Ingolstadt%29#mw-subcategories';
# my $startURL = 'https://commons.wikimedia.org/w/index.php?title=Category:Cultural_heritage_monuments_in_Bavaria_with_known_IDs';
# my $startURL = 'https://commons.wikimedia.org/w/index.php?title=Category:Cultural_heritage_monuments_in_Bavaria_with_known_IDs&subcatfrom=+D-1-63-000-266+%0AKellerstra%C3%9Fe+12+%28Rosenheim%29#mw-subcategories';
# my $startURL = 'https://commons.wikimedia.org/w/index.php?title=Category:Cultural_heritage_monuments_in_Bavaria_with_known_IDs&subcatfrom=+D-1-72-114-99+%0ASpitalkirche+Sankt+Johannes+%28Bad+Reichenhall%29#mw-subcategories';
    


###############################
# my $startURL = 'https://commons.wikimedia.org/wiki/Category:Cultural_heritage_monuments_in_Bavaria_without_linked_Wikidata';
###############################


my $outfile = "out-bav.txt";
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
    
    # print "============================\n";
    # print "LINK:$url:\n";
    $count++;

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
       print "LEMMA:$lemma:DECODE:$lemma_decode:\n";
     
       my $check_url = $url.'?action=raw';
  #     print "check URL:$url:\n";
  $agent->get( $check_url );
  my $result2 = $agent->content;
  # print "RESULT:$result2:\n";
  if ($result2 =~ /Baudenkmal Bayern/i) {
     # print "Lemma $check_url hat Baudenkmal-ID\n";
     if ($result2 =~ /xxxxxxxxxxWikidata infoboxxxxxx/i) {
      #  print "Lemma $check_url hat Wikidata Infobox - do nothing\n";
     } else {
	my $blfd_id = "";
   if ($result2 =~ /(\s*)\{\{Baudenkmal Bayern(\s*)\|(1=)?(\s*)(D[\-0-9]+)/i) {
	# if ($result2 =~ /(\s*)\{\{Baudenkmal Bayern(\s*)\|(\s*)(D[\-0-9]+)/i) {
          #  print "*** HIER: $1:$2:$3:$4:\n";
           # $blfd_id = $4;
           $blfd_id = $5;
        }
	 print "Lemma $check_url hat Baudenkmal-ID $blfd_id:\n";
        print "Lookup Q-ID for BLFD_ID:$blfd_id:\n";

	# if ($count == 5) { exit ; }
	
	if ($blfd_id ne "") {

# haswbstatement:P4244=D-1-89-159-2

# SELECT ?item WHERE { ?item, P373 wdt:P4244 "D-1-89-159-2" . }
# SELECT ?item ?commonscat WHERE { ?item wdt:P4244 "D-1-63-000-18" .  OPTIONAL{?item wdt:P373 ?commonscat .}   }
	    
	  # my $wd_url = 'https://query.wikidata.org/sparql?query=SELECT%20%3Fitem%20WHERE%20%7B%20%3Fitem%20wdt%3AP4244%20%22'.$blfd_id.'%22%20.%20%7D';
	  # my $wd_url = 'https://query.wikidata.org/sparql?query=SELECT%20%3Fitem%20WHERE%20%7B%20%3Fitem%20wdt%3AP4244%20%22'.$blfd_id.'%22%20.%20%7D';
	    my $wd_url = 'https://query.wikidata.org/sparql?query=SELECT%20%3Fitem%20%3Fcommonscat%20WHERE%20%7B%20%3Fitem%20wdt%3AP4244%20%22'.$blfd_id.'%22%20.%20%20OPTIONAL%7B%3Fitem%20wdt%3AP373%20%3Fcommonscat%20.%7D%20%20%20%7D';

	    # print "WD_URL:$wd_url:\n";
            #   "Accept: application/json"
	    # "Accept: text/csv"
               # 'Accept' => 'application/json'
	    $agent->add_header(
               'Accept' => 'text/csv'
		);
	    $agent->get( $wd_url );
          my $result3 = $agent->content;
	    # print "RESULT:$result3:\n";
	    # print "LINE2:".@result3[1]."\n";
	    
	    my $qid = 0; my $wd_commonscat = "";
	  if ($result3 =~ /wikidata.org\/entity\/Q([0-9]+),(.*)/i) {
	      # print "QID:$1:CAT:$2\n";
	      $qid = $1;
	      $wd_commonscat = $2;
	$wd_commonscat =~ s/\s//og;
	  }
	    if ($wd_commonscat ne "") {
		# print "lemma $lemma hat bereits commonscat $wd_commonscat - do nothing\n";
	    } else {
	      
	      if ($qid > 0 ) {
	        # Wenn Q-ID gefunden, dann quickstatement ausgeben
	        # print "QUICKSTATEMENT for Q$qid\n";

 	        # Q41269749	P373	"Ringstraße 13 Hofkapelle (Übersee, Chiemgau)"
                # Q41269749	Scommonswiki	"Category:Ringstraße 13 Hofkapelle (Übersee, Chiemgau)"
	        print OUT "Q".$qid."\t".'P373'."\t".'"'.$lemma_decode.'"'."\n";
	        print OUT "Q".$qid."\t".'Scommonswiki'."\t".'"Category:'.$lemma_decode.'"'."\n";

		print "Q".$qid."\t".'P373'."\t".'"'.$lemma_decode.'"'."\n";
	        print "Q".$qid."\t".'Scommonswiki'."\t".'"Category:'.$lemma_decode.'"'."\n";

	    }
	  }
	}
	
    }
		   
  } else {
    # print "Lemma $check_url - Kein Baudenkmal\n";
  }

  #  exit;
     
}


return $next;
}  # end sub

  

exit 0;

