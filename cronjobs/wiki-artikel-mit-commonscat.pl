#!/usr/bin/perl

use strict;

# my $url = 'https://de.wikipedia.org/wiki/Benutzer:Kolja_Lange/Walter_J._Spielberger';
#      if ($url =~ /Benutzer:(.*)$/) {
#  my        $user = $1;
# $user =~ s/\/(.+)$//;
# print "User:$user:\n";
# }
# 	 exit;

# API nicht notwendig, alle Infos frei verfügbar

# Crypt::SSLeay muss installiert sein fuer SSL-Support
# apt-get install libwww-mechanize-perl libio-socket-ssl-perl libnet-ssleay-perl
use WWW::Mechanize;
use Data::Dumper;
use HTML::FormatText;

####################
# m2k 27.5.2018
# my $archive_is == 0;
my $archive_is == 1;
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

my $USER_AGENT='Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.101 Safari/537.36';

# See the autocheck parameter, which turns all HTTP errors into fatal errors. When you turn autocheck off, you will need to do all error checking yourself.
my $agent = WWW::Mechanize->new( agent => $USER_AGENT,  autocheck => 0 );

my $PAUSE = 1; # sekunden zwischen zwei seitenabrufen

# https://de.wikipedia.org/wiki/Spezial:Neue_Seiten

 $agent->get("https://de.wikipedia.org/wiki/Spezial:Neue_Seiten");
#  $agent->get('https://de.wikipedia.org/w/index.php?title=Spezial:Neue_Seiten&offset=&limit=200');
# $agent->get('https://de.wikipedia.org/w/index.php?title=Spezial:Neue_Seiten&offset=&limit=3500');

# $agent->current_form();

# print Dumper($agent);
# print "===========================\n";

my $result = $agent->content;
# print "RESULT:$result:";

my $file_urllist = '/tmp/wikipedia-urllist-commonscat-wikidata.txt';
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

  
# <li><a href=\"/w/index.php?title=When_Day_Is_Done&amp;oldid=147939241\" title=\"When Day Is Done\"><span class=\"mw-newpages-time\">17:19, 11. Nov. 2015</span></a> \x{200e}<a href=\"/wiki/When_Day_Is_Done\" title=\"When Day Is Done\" class=\"mw-newpages-pagename\">When Day Is Done</a> <span class=\"mw-newpages-history\">(<a href=\"/w/index.php?title=When_Day_Is_Done&amp;action=history\" title=\"When Day Is Done\">Versionen</a>)</span> \x{200e}<span class=\"mw-newpages-length\">[3.187 Bytes]</span> 

 my @links = $agent->find_all_links( url_regex => qr/\/w\/index.php\?title=/ );
# my @links = $agent->find_all_links( url_regex => qr/\/wiki\/Benutzer\:/ );



for my $link ( @links ) {
   
    my $url = $link->url_abs;
       $url =~ s/\&oldid=([0-9]+)$//;  # revisionsnummer aus url entfernen
#     print "URL:$url:\n";

    if (defined($urllist{$url})) {
	$urllist{$url}++;
       # print "URL $url bereits geprueft\n"; 
        print OUT "$url\n"; # bereits gepruefte URL, beim naechsten durchgang nicht nochmals pruefen
       next; 
     }
	$urllist{$url}++;

    
    if ((!($url =~ /Benutzer:/)) && (!($url =~ /Benutzerin:/)) && (!($url =~ /Benutzer_Diskussion:/)) && (!($url =~ /Spezial:/)) && (!($url =~ /\&action=history/)) ) {
        print OUT "$url\n"; # bereits gepruefte URL, beim naechsten durchgang nicht nochmals pruefen

	       my $lemma = "";
       if ($url =~ /title=(.*)$/) {
         $lemma = $1;
         # $lemma =~ s/_/ /og;
       }

     # nicht ...."Creative Commons"...
      my $check_url = 'https://de.wikipedia.org/wiki/'.$lemma.'?action=raw';
	       my $print_url = 'https://de.wikipedia.org/wiki/'.$lemma;
	       
	  #     print "check URL:$url:\n";
   $agent->get( $check_url );
 my $result2 = $agent->content;
#	       print "RESULT:$result2:\n";
	       
	       if ($result2 =~ /Commons/i) {
#	       if ($result2 =~ /\{\{Commons/i) {
		   print "Lemma $print_url hat Commons(cat)\n";
		   }
	
    } else {
	# print "Lemma $url - KEINE COMMONSCAT\n";
    }
	
	   
} # for


close(OUT);


exit 0;

