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

#
# - baudenkmaler in Sachsen/Meißen + id
#
# Cultural heritage monuments in Saxony without linked Wikidata
# Cultural heritage monuments in Meißen
# 
# https://petscan.wmflabs.org/?&search_max_results=500&cb_labels_yes_l=1&language=commons&edits%5Bbots%5D=both&edits%5Bflagged%5D=both&interface_language=en&edits%5Banons%5D=both&wikidata_item=without&project=wikimedia&depth=10&show_redirects=no&cb_labels_no_l=1&ns%5B14%5D=1&categories=Cultural%20heritage%20monuments%20in%20Saxony%20without%20linked%20Wikidata%0ACultural%20heritage%20monuments%20in%20Mei%C3%9Fen%0A&cb_labels_any_l=1&&doit=


# SELECT ?item ?itemLabel ?value ?liegt_in_der_Verwaltungseinheit ?liegt_in_der_VerwaltungseinheitLabel ?Bild WHERE {
#  ?item wdt:P1708 ?value.
#  ?item wdt:P131 wdt:Q8738.
#  SERVICE wikibase:label { bd:serviceParam wikibase:language "de,en". }
#  OPTIONAL { ?item wdt:P131 ?liegt_in_der_Verwaltungseinheit. }
#  OPTIONAL { ?item wdt:P18 ?Bild. }
# } order by ?liegt_in_der_VerwaltungseinheitLabel



my $INFILE = 'dittografien-2021-01-07.txt';

open ( IN, "< $INFILE") || die("cannot open $INFILE: $! \n");

my $count =0 ;
my $QID = 0;
while(<IN>)
{
    chop;
    my $line = $_;

    my $beschreibung = "";
    
    if ($line =~ /\(Q([0-9]+)\)/i) {
	# print "1:$1:2:$2:\n";
	$QID = $1;
       next;	
    }

    if ($line =~ /Politiker und Politiker/i) {
	$beschreibung = $line;
	$beschreibung =~ s/Politiker und Politiker/Politiker/og;
	$beschreibung =~ s/Politiker, Politiker/Politiker/og;

	$beschreibung =~ s/Politiker, Politiker/Politiker/og;
	

    }
    if ($line =~ /Politiker, Jurist, Politiker und Jurist/i) {
	$beschreibung = $line;
        $beschreibung =~ s/Politiker\, Jurist\, Politiker und Jurist/Politiker und Jurist/og;
    }


    if ($line =~ /Politiker, Manager, Politiker und Manager/i) {
	$beschreibung = $line;
        $beschreibung =~ s/Politiker, Manager, Politiker und Manager/Politiker und Manager/og;
    }

    if ($line =~ /Politiker, Journalist, Politiker und Journalist/i) {
	$beschreibung = $line;
        $beschreibung =~ s/Politiker, Journalist, Politiker und Journalist/Politiker und Journalist/og;
    }

    
    if (($beschreibung ne "") && ($QID > 0)) {
       # print "Q.".$QID."\tDde\t\"$beschreibung (ALT:$line)\"\n"; # description de - beschreibung
       print "Q".$QID."\tDde\t\"$beschreibung\"\n"; # description de - beschreibung
    $QID = 0;
    } else {
# print  "*** WARNING:QID:$QID:BESCHR:$beschreibung:\n"; 
    }


   

}
close(IN);
