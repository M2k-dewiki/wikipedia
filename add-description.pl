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

my $file_urllist = 'wikipedia-urllist-add-description.txt';
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


my %mons = ("Januar"=>'01',"Februar"=>'02',"März"=>'03',"April"=>'04',"Mai"=>'05',"Juni"=>'06',"Juli"=>'07',"August"=>'08',"September"=>'09',"Oktober"=>'10',"November"=>'11',"Dezember"=>'12');

# my $INFILE = 'list.txt';
# my $INFILE = 'query.csv';
 my $INFILE = '/home/m2k/Downloads/query.csv';
# my $INFILE = '/home/m2k/Downloads/Download';
# my $INFILE = '/home/m2k/Downloads/Download.csv';

open ( IN, "< $INFILE") || die("cannot open $INFILE: $! \n");

my $count =0 ;
while(<IN>)
{
    chop;

#    my ($number,$title,$pageid,$namespace,$length,$touched,$QID) = split (/\,/,$_); 
# $title =~ s/\"//og;
# $QID =~ s/\"//og;
# my $sitelink = 'https://de.wikipedia.org/wiki/'.$title;
    

    my ($QID,  @sitelink_rest) = split (/\,/,$_);
    my $sitelink = "";
    foreach my $part (@sitelink_rest) {
      if ($sitelink eq "") {
        $sitelink = $part; 
      } else {
        $sitelink = $sitelink . ",".$part;
      }
    }
    $sitelink =~ s/\"//og;
   $QID =~ s/http:\/\/www.wikidata.org\/entity\///og;


    if (! ($QID =~ /Q[0-9]+/ )) {
	# print "$QID ist KEINE QID\n";
	next ;
    }

 #   print "QID:$QID:SL:$sitelink:\n";
 


#     my $url = URLEncode($sitelink);
     my $url = $sitelink;

     
###################     
     if (defined($urllist{$url})) { 
      # print "URL $url bereits geprueft\n"; 
#      print OUT "$url\n"; # bereits gepruefte URL, beim naechsten durchgang nicht nochmals pruefen
# print "URL $url bereits geprüft - ignore\n";
      next; 
    }
###################     
   
       my $check_url = $url.'?action=raw';
       
       
#my $check_url = 'https://de.wikipedia.org/wiki/H%C3%BCbnersm%C3%BChle?action=raw';
       
 #       print "check URL:$check_url:\n"; # exit;
   print OUT "$url\n"; # bereits gepruefte URL, beim naechsten durchgang nicht nochmals pruefen
 
 
    $agent->get( $check_url );
  my $result2 = $agent->content;
#   print "RESULT:$result2:\n";
  

 my $description = "";
 
 
    
#  if ($result2 =~ /\|(\s*)KURZBESCHREIBUNG(\s*)=(\s*)(.+)$/i) {
  if ($result2 =~ /\|(\s*)KURZBESCHREIBUNG(\s*)=(\s*)(.*)/i) {

#   if ($result2 =~ /\|(\s*)KURZBESCHREIBUNG(\s*)=(\s*)([^|].*)|/i) {
#          print "*** GEBDAT(1): 1:$1:2.$2:3:$3:4:$4:5:$5:6:$6:7:$7:8:$8:9:$9:10:$10:11:$11:12:$12:\n";
	  $description = $4;

 }

   
   ##############

 
#     print "KAT:$kat:LEMMA_MIT:$lemma_mit_klammerzusatz:LEMMA_OHNE:$lemma_ohne_klammerzusatz:\n";
    


if ($description ne "") {
  

   print "$QID\tDde\t\"".$description."\"\n";

}    
# exit;

  

}
close(IN);

close(OUT);
