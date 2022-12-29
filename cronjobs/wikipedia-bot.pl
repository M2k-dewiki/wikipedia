#!/usr/bin/perl

use strict;

# API nicht notwendig, alle Infos frei verfügbar

# Crypt::SSLeay muss installiert sein fuer SSL-Support
# apt-get install libwww-mechanize-perl libio-socket-ssl-perl libnet-ssleay-perl
use WWW::Mechanize;
use Data::Dumper;
use HTML::FormatText;

####################
# m2k 27.5.2018
 my $archive_is = 0;
# my $archive_is == 1;
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

# my $PAUSE = 5; # sekunden zwischen zwei seitenabrufen
my $PAUSE = 1; # sekunden zwischen zwei seitenabrufen

# https://de.wikipedia.org/wiki/Spezial:Neue_Seiten

$agent->get("https://de.wikipedia.org/wiki/Spezial:Neue_Seiten");

# $agent->current_form();

# print Dumper($agent);
# print "===========================\n";

my $result = $agent->content;
# print "RESULT:$result:";

my $file_urllist = '/tmp/wikipedia-urllist.txt';
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

my $count = 0;

# Umlaute

my @suchliste = ('sterreich', 'Wien', 'Vorarlberg', 'Burgenland', 'Kärnten', 'rnten', 'Salzburg', 'Steiermark', 'Tirol', 'steirisch', 'steierm', 'burgenländisch','burgenl', 'Graz','Innsbruck','Bregenz','Klagenfurt','Linz','Eisenstadt');

# suedtirol / nordtirol
my @blacklist = ('Moldawien', 'Masowien', 'entfernten', 'dtirol','Wienand','Jugoslawien','ernten','Kujawien','Burgenlex','tarnten','warnten','Begriffsklärung', 'Begriffskl','Burgenlandkreis');


my $lemmalist = "";
my $text_treffer = "";
my $text_treffer_plus_inhalt ="";
my $editlist = "";
my $versionlist = "";

my $treffer_global = 0;
my $blacklist_global = 0;

for my $link ( @links ) {
    my $url = $link->url_abs;
    $url =~ s/\&oldid=([0-9]+)$//;  # revisionsnummer aus url entfernen

    if (defined($urllist{$url})) { 
      # print "URL $url bereits geprueft\n"; 
      print OUT "$url\n"; # bereits gepruefte URL, beim naechsten durchgang nicht nochmals pruefen
      next; 
    }
    # my $url = 'https://de.wikipedia.org/w/index.php?title=Triebwagen_V_(U-Bahn_Wien)';

    if ((!($url =~ /Benutzer:/)) && (!($url =~ /Benutzerin:/)) && (!($url =~ /Benutzer_Diskussion:/)) && (!($url =~ /Spezial:/)) && (!($url =~ /\&action=history/)) && (!($url =~ /\&action=edit/)) ) {

      # $count++; if ($count > 3) { next; }  # zum testen
      # print "COUNT:$count:URL:$url:\n";
      # sleep($PAUSE);
      print OUT "$url\n"; # bereits gepruefte URL, beim naechsten durchgang nicht nochmals pruefen

######################
#m2k 26.4.2020 - plus raw
      # $agent->get( $url );
      my $check_url_raw = $url;
      # $check_url_raw =~ s/w\/index.php\?title=/wiki\//og;
      # $check_url_raw = $check_url_raw . '?action=raw';
      $agent->get( $check_url_raw );
       print "CHECK:$check_url_raw:\n";
######################

      my $agent_result = $agent->status();
      if ($agent_result != 200) {
	next;  # HTTP Code ungleich "200" ==> seite nicht gefunden ==> naechste URL pruefen
      }

      my $result2 = $agent->content;
      # print "RESULT2:$result2:";

      my $lemma = "";
      if ($url =~ /title=(.*)$/) {
        $lemma = $1;
        $lemma =~ s/_/ /og;
      }

      my $blacklist = 0;
      foreach my $suchwort (@blacklist) {
	if ($url =~ /$suchwort/i) {
	  my $tmp_text = "*** BLACKLIST TREFFER $suchwort in URL $url:\n";
	  $blacklist = 1;
	  $blacklist_global++;
          $text_treffer .= $tmp_text;
	}
	if ($result2 =~ /$suchwort/i) {
	  my $tmp_text = "*** BLACKLIST TREFFER $suchwort im Volltext von URL $url:\n";
	  $blacklist = 1;
	  $blacklist_global++;
          $text_treffer .= $tmp_text;
	}
      }

      # if ($blacklist == 1) { next; } # eventuell spaeter aktivieren

      my $treffer = 0;
      foreach my $suchwort (@suchliste) {
	# print "SUCHWORT:$suchwort:\n";
	if ($url =~ /$suchwort/i) {
          $treffer++;
          $treffer_global++;
          if ($treffer == 1) {
            my $tmp_text = "TREFFER: Suchwort $suchwort in URL $url:\n";
            my $string = HTML::FormatText->format_string($result2 );
	    $string =~ s/Navigationsmen.*//s;  # alles ab dem ausdruck entfernen
            $text_treffer .= $tmp_text;
            $text_treffer_plus_inhalt .= $tmp_text.$string;
            if ($lemmalist ne "") { 
              $lemmalist .= " - ";
            }
            $lemmalist .= "[[$lemma]]";
	    $lemma =~ s/ /%20/og;
	    $editlist .= "https://de.wikipedia.org/w/index.php?title=Portal:%C3%96sterreich/Neue_Artikel&action=edit&summary=[[".$lemma."]]\n";

            ################
            my $archive_url = "http://web.archive.org/save/https://de.wikipedia.org/wiki/".$lemma;
            $agent->get( $archive_url );
            ################
            # 2017-10-02
# 2018-05-19
	    if ($archive_is == 1) {
  	      $agent->get("http://archive.is/");
  	      my $archive_url = 'https://de.wikipedia.org/wiki/'.$lemma;
  	      $agent->form_name('submiturl');
  	      $agent->field('url',$archive_url);
  	      $agent->submit();
	    }
            ################

            my $version_url = "https://de.wikipedia.org/w/index.php?title=".$lemma."&action=history";
            $agent->get( $version_url );
            my $version_result = $agent->content;
            my $string = HTML::FormatText->format_string($version_result );
            $string =~ s/Navigationsmen.*//s;  # alles ab dem ausdruck entfernen
            $string =~ s/.*Alte Versionen des Artikels//s;
            $versionlist .= "LEMMA:$lemma:VERSION:$string:\n";

	  }
	} else {

          # 3.5.2016 - nur in text ohne wiki-links etc. suchen
          my $string = HTML::FormatText->format_string($result2 );
          $string =~ s/Navigationsmen.*//s;  # alles ab dem ausdruck entfernen

  	  if ($string =~ /$suchwort/i) {
            $treffer++;
            $treffer_global++;
            if ($treffer == 1) {
              # 27.7.2016 - treffer im volltext hervorheben
	      my $replacement = "\n\n********************************************\n************ $suchwort ****************\n********************************************\n";
	      $string =~ s/$suchwort/$replacement/ig;
              my $tmp_text = "TREFFER: Suchwort $suchwort im Volltext von URL $url:\n";
              $text_treffer .= $tmp_text;
              $text_treffer_plus_inhalt .= $tmp_text.$string;
              if ($lemmalist ne "") { 
                $lemmalist .= " - ";
              }
              $lemmalist .= "[[$lemma]]";
  	      $lemma =~ s/ /%20/og;
  	      $editlist .= "https://de.wikipedia.org/w/index.php?title=Portal:%C3%96sterreich/Neue_Artikel&action=edit&summary=[[".$lemma."]]\n";

              ################
	      my $archive_url = "http://web.archive.org/save/https://de.wikipedia.org/wiki/".$lemma;
              $agent->get( $archive_url );
              ################
              # 2017-10-02
# 2018-05-19
  	      if ($archive_is == 1) {
  	        $agent->get("http://archive.is/");
  	        my $archive_url = 'https://de.wikipedia.org/wiki/'.$lemma;
  	        $agent->form_name('submiturl');
  	        $agent->field('url',$archive_url);
  	        $agent->submit();
              }
              ################

	      my $version_url = "https://de.wikipedia.org/w/index.php?title=".$lemma."&action=history";
              $agent->get( $version_url );
              my $version_result = $agent->content;
              my $string = HTML::FormatText->format_string($version_result );
	      $string =~ s/Navigationsmen.*//s;  # alles ab dem ausdruck entfernen
	      $string =~ s/.*Alte Versionen des Artikels//s;
              $versionlist .= "LEMMA:$lemma:VERSION:$string:\n";

	    }
	  }
	}
      }
    }
}


if (($blacklist_global > 0) && ($treffer_global == 0)) { exit ; }


if ($lemmalist ne "") {
  $lemmalist = URLDecode($lemmalist);
  print "\nLEMMALIST $lemmalist\n\n";
  print "Artikel hinzufuegen:\n";

  $editlist =~ s/\[/%5B/og;
  $editlist =~ s/\]/%5D/og;
  print "$editlist\n";
}
print "$text_treffer";
print "$text_treffer_plus_inhalt";
print "$versionlist";

close(OUT);


###########################
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime(time);
$year += 1900;
$mon++;
my $today = sprintf("%04d-%02d-%02d", $year, $mon, $mday);

my $filename = "/tmp/wiki-logfile-$today";
open (OUT, ">> $filename") || die ("Cannot open $filename : $! \n");
print OUT "$text_treffer";
print OUT "$text_treffer_plus_inhalt";
print OUT "$versionlist";
close(OUT);
###########################


exit 0;


# Script zur Auswertung von
# 
# https://de.wikipedia.org/wiki/Spezial:Neue_Seiten
# 
# 
# ==> alle Artikel Volltextmäßig prüfen:
# 
# - kommt der Text
# 
# Österreich, Wien, Burgenland, usw. vor ?!?
# 
# - wenn ja, dann automatische Mail
# 
# 
# ==> alle x Minuten ausführen
# 
# ==> merken, welche Artikel bereits geprüft bzw. benachrichtigt wurden
# 
# 
# https://packages.debian.org/search?keywords=libmediawiki-api-perl
# https://www.mediawiki.org/wiki/Perl
# 
# 
# m2k@max: ~ $ sudo apt-get install libmediawiki-api-perl
# 
# 
# http://search.cpan.org/~exobuzz/MediaWiki-API-0.40/lib/MediaWiki/API.pm



# use MediaWiki::API;
# 
# sub on_error {
#   print "Error code: " . $mw->{error}->{code} . "\n";
#   print $mw->{error}->{stacktrace}."\n";
#   die;
# }
# 
# 
# my $mw = MediaWiki::API->new();
# # $mw->{config}->{api_url} = 'http://en.wikipedia.org/w/api.php';
# $mw->{config}->{api_url} = 'http://de.wikipedia.org/w/api.php';
# 
# $mw->{config}->{on_error} = \&on_error;
# 
# 
#   
# # log in to the wiki
# $mw->login( { lgname => '.....', lgpassword => '..........' } )
#   || die $mw->{error}->{code} . ': ' . $mw->{error}->{details};
#   
#   
# # get some page contents
# my $page = $mw->get_page( { title => 'Main Page' } );
# 
# # https://de.wikipedia.org/wiki/Spezial:Neue_Seiten
# 
# 
# # print page contents
# print $page->{'*'};
  
