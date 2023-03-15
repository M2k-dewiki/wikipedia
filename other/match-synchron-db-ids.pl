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


#####################
# Sprecher: https://cloud.funzi.org/s/mi7YjC3XfaM8mMf
# Darsteller: https://cloud.funzi.org/s/xL4kzRRHXRMWBbD
#####################
# https://w.wiki/6R5Q - Darsteller - 7.724 Wikidata-Objekte
# https://w.wiki/6R5P - Sprecher - 2.362 Wikidata-Objekte
#####################
# ===> save as "query.csv"
#####################


#####################
my $INFILE = 'darsteller.txt';
#####################
# my $INFILE = 'sprecher.txt';
#####################
my %CLOUDhash;
open ( IN, "< $INFILE") || die("cannot open $INFILE: $! \n");
while(<IN>)
{
  chop;
  my ($ID_old,$ID_new) = split (/\t/,$_);
#  print "ID_old:$ID_old:ID_new:$ID_new:\n";
  if (defined($CLOUDhash{$ID_old})) {
	      print "ID_old bereits definiert - Wert für Synch-DB-ID:$ID_old: nicht eindeutig:alter Wert". $CLOUDhash{$ID_old}.":\n";
    $CLOUDhash{$ID_old} = 'invalid';

  } else {
    $CLOUDhash{$ID_old} = $ID_new;
  }

}
close (IN);
#####################
# my $count = 0;
# foreach my $ID_old (sort keys %CLOUDhash) {
# 	print "ID_old:$ID_old:".$CLOUDhash{$ID_old}."\n";
# $count++;
# }
# print "Anzahl Synch-BD-Einträge:$count:\n";
# exit;
############################

my $INFILE = 'query.csv';

open ( IN, "< $INFILE") || die("cannot open $INFILE: $! \n");

my %QIDhash;
while(<IN>)
{
  chop;
  my ($QID, $name,$ID_old) = split (/\,/,$_);
  $QID =~ s/http:\/\/www.wikidata.org\/entity\///og;

#  print "=============\n";  print "QID:$QID:NAME:$name:ID_old:$ID_old\n";
  
  if (defined($QIDhash{$ID_old})) {
     print "$ID_old bereits definiert - QID:$QID:nicht eindeutig, zweiter Wert:".$QIDhash{$ID_old}."\n";
    # unset($QIDhash{$decomposed_name});
    $QIDhash{$ID_old} = 'invalid';
  } else {
    $QIDhash{$ID_old} = $QID;
  }

}
close (IN);
# foreach my $ID_old (sort keys %QIDhash) {
# 	print "ID_old:$ID_old:".$QIDhash{$ID_old}."\n";
# }
# exit;


#### fuer alle Wikidata-Objekte
foreach my $ID_old (sort keys %QIDhash) {
#	print "ID_old:$ID_old:".$QIDhash{$ID_old}."\n";

 if (defined($CLOUDhash{$ID_old})) {
# print "ID_old:$ID_old:QID:".$QIDhash{$ID_old}.":CLOUD:".$CLOUDhash{$ID_old}."\n";

    if (( $QIDhash{$ID_old} ne 'invalid') && $CLOUDhash{$ID_old} ne 'invalid') {

################	
	#### https://www.wikidata.org/wiki/Property:P11646
 print $QIDhash{$ID_old}."\tP11646\t\"".$CLOUDhash{$ID_old}."\"\n";    
################	
	
	}
	

 } else {
    print "NO synch-db-ID found for ID_old:$ID_old:".$QIDhash{$ID_old}."\n";
 }
}

exit;



