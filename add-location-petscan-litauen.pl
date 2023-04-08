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

#########################

# my $file_urllist = '/tmp/wikipedia-urllist-add-location-litauen.txt';
my $file_urllist = 'wikipedia-urllist-add-location-litauen.txt';
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

#########################


#### Siedlungen ohne geographische Koordinaten

# https://w.wiki/6Yu5


    
# https://metacpan.org/pod/Geo::Coordinates::Transform
# use Geo::Coordinates::Convert;
# https://packages.debian.org/buster/libgeo-coordinates-utm-perl

# https://packages.debian.org/buster/all/libgeo-coordinates-utm-perl/filelist
# https://metacpan.org/pod/Geo::Coordinates::UTM

# apt-get install libgeo-coordinates-utm-perl
 
#########################
# aus # use Geo::Coordinates::DecimalDegrees;
sub dms2decimal {
    my $latitude_or_longitude = $_[0];
    my ($degrees, $minutes, $seconds) = split (/\//,$latitude_or_longitude);
    my $decimal;
    if ($degrees >= 0) {
	$decimal = $degrees + $minutes/60 + $seconds/3600;
    } else {
	$decimal = $degrees - $minutes/60 - $seconds/3600;
    }
    return $decimal;
} 
#########################
# my $north = '46/44/32/N';
# my $north_dec = dms2decimal($north);
# print "NORTH:$north:NORTH_DEC:$north_dec:\n";
#########################
# my $east = '13/51/01/E';
# my $east_dec = dms2decimal($east);
# print "EAST:$east:EAST_DEC:$east_dec:\n";
#########################



# my $INFILE = 'list.txt';
# my $INFILE = 'query.csv';
my $INFILE = 'query.csv';

open ( IN, "< $INFILE") || die("cannot open $INFILE: $! \n");

my $count =0 ;
while(<IN>)
{
    chop;
    my ($QID, $geo, $sitelink) = split (/\,/,$_);

    $QID =~ s/http:\/\/www.wikidata.org\/entity\///og;
    


  # print "=============\n";  print "QID:$QID:SL:$sitelink:\n";
    
   

#     my $url = URLEncode($sitelink);


     my $url = $sitelink;

     #my $url = 'https://de.wikipedia.org/wiki/Torfjanoje_(Kaliningrad,_Osjorsk)';

     
###################     
     if (defined($urllist{$url})) { 
      # print "URL $url bereits geprueft\n"; 
      print OUT "$url\n"; # bereits gepruefte URL, beim naechsten durchgang nicht nochmals pruefen
#print "URL $url bereits geprüft - ignore\n";
       next; 
    }
###################     
   
       my $check_url = $url.'?action=raw';
       
       
# my $check_url = 'https://lt.wikipedia.org/wiki/Gumb%C4%97?action=raw';
       
#        print "check URL:$check_url:\n"; # exit;
 #  print OUT "$url\n"; # bereits gepruefte URL, beim naechsten durchgang nicht nochmals pruefen
 
 
    $agent->get( $check_url );
  my $result2 = $agent->content;
#   print "RESULT:$result2:\n"; exit;

#       if ($result2 =~ /Wikidata infobox/i) {
#        print STDERR "Lemma $check_url hat Wikidata Infobox - do nothing\n";
#        next;
 #    } 

 my $north = "";
my $east = "";


# |lat = 55.919
# |long = 24.502

#      if ($result2 =~ /\|(\s*)lat(\s*)=(\s*)([0-9\.]+)(\s*)/i) {
# $north = $4;
#	  }
#      if ($result2 =~ /\|(\s*)long(\s*)=(\s*)([0-9\.]+)(\s*)/i) {
# $east = $4;
#	  }
#    if ( $north =~ /\//) {
#     $north = dms2decimal($north);
#    }
#        if ( $east =~ /\//) {
#     $east = dms2decimal($east);
#    }
#}


    if ($result2 =~ /(\s*)\|(\s*)(lat)(\s*)=(\s*)([^|]+)(\s*)/i) {
 #  print "***Breitengrad***6:$6:7:$7:\n";
  
 $north = $6;
 $north =~ s/<.+?>//g; # drop all HTML tags, including remarks
 $north =~ s/^(\s)*//og; # trim
 $north =~ s/(\s)*$//og; # trim
   if ( $north =~ /\//) {
     $north = dms2decimal($north);
    }
      }


if ($result2 =~ /(\s*)\|(\s*)(long)(\s*)=(\s*)([^|]+)(\s*)/i) {
 # print "***Laengengrad:***8:$8:\n";
 #       print "*** Coordinate: 1:$1:2.$2:3:$3:4:$4:5:$5:6:$6:7:$7:8:$8:9:$9:10:$10:11:$11:\n";
 $east = $6;
 $east =~ s/<.+?>//g; # drop all HTML tags, including remarks
 $east =~ s/^(\s)*//og; # trim
 $east =~ s/(\s)*$//og; # trim
 if ( $east =~ /\//) {
   $east = dms2decimal($east);
 }

 }
# FIXME
  
# exit;


   
   
#########################
#########################
#########################
     if ($result2 =~ /(\s*)\|lat_deg(\s*)=(\s*)([0-9\.]+)(\s*)\|lat_min(\s*)=(\s*)([0-9\.]+)(\s*)\|lat_sec(\s*)=(\s*)([0-9\.]+)(\s*)/i) {
#         print "*** HIER: 1:$1:2.$2:3:$3:4:$4:5:$5:6:$6:7:$7:8:$8:9:$9:10:$10:11:$11:12:$12:\n";
 $north = $4.'/'.$8.'/'.$12.'/N';
 $north = dms2decimal($north);
# print "NORTH:$north:NORTH_DEC:$north_dec:\n";

}     

     if ($result2 =~ /(\s*)\|lon_deg(\s*)=(\s*)([0-9\.]+)(\s*)\|lon_min(\s*)=(\s*)([0-9\.]+)(\s*)\|lon_sec(\s*)=(\s*)([0-9\.]+)(\s*)/i) {
#         print "*** HIER: 1:$1:2.$2:3:$3:4:$4:5:$5:6:$6:7:$7:8:$8:9:$9:10:$10:11:$11:12:$12:\n";
 $east = $4.'/'.$8.'/'.$12.'/E';
 $east = dms2decimal($east);
# print "NORTH:$north:NORTH_DEC:$north_dec:\n";

}     

   ##############

 
    # print "KAT:$kat:LEMMA_MIT:$lemma_mit_klammerzusatz:LEMMA_OHNE:$lemma_ohne_klammerzusatz:\n";
    

if (($north ne "") && ($east ne "")) {
  my $cord = '@'.$north.'/'.$east;
  # FIXME

# if (($cord !~ /grad/iog) && (($cord !~ /nutz/iog)) {
if ($cord !~ /[A-Z]/iog) {
  
    print "$QID\tP625\t$cord\tS143\tQ202472\n";   # koordinaten 
    #FIXME
}    
    # S ... Fundstelle
#    importiert aus Wikimedia-Projekt (P143)
# deutschsprachige Wikipedia (Q48183)
# litauische Wikipedia (Q202472)
#exit;
 }


    
# {{Object location|52.975743| 13.988022}}  {{Baudenkmal Brandenburg|09130507}}
# https://www.wikidata.org/wiki/Q101573281
# https://commons.wikimedia.org/wiki/Category:Dorfkirche_(Herzsprung_in_der_Uckermark)

# ytes +499‎  ‎Aussage erstellt: geographische Koordinaten (P625): 52°58'32.675"N, 13°59'16.879"E 
# Location coordinates in the form of @LAT/LON, with LAT and LON as decimal numbers.
# Example: Q3669835 TAB P625 TAB @43.26193/10.92708


}
close(IN);

close(OUT);
