#!/usr/bin/perl

use strict;

#################################
#
# Hallo DonPedro71, es wurde jetzt die Liste 
#
# * http://www.espn.com/tennis/players
# 
# mit der Liste aller Tennisspieler mit Wikidata-Objekt:
# 
# * https://w.wiki/6LYc
# 
# abgeglichen.
# 
# In Wikidata haben wir 12.630 Objekte für Tennisspieler.
# 
# In der ESPN-Liste sind 11.4000 IDs vorhanden.
# 
# Jene Namenseinträge, die mehrfach vorkamen, wurden aus beiden importierten Listen entfernt, weil keine Eindeutigkeit vorliegt.
# 
# Bei unterschiedlichen Schreibweisen (unter Umständen auch aufgrund von Sonderzeichen) wurden kein Abgleich durchgeführt.
# 
# Insgesamt wurden jetzt 2.692 ESPN-IDs importiert.
# 
# Eine Liste aller Objekte mit ESPN-Tennispieler-ID findet sich unter
# 
# * https://w.wiki/6LZG
# 
# -------------
# 
# Beispiel Mehrdeutigkeit ESPN-Liste:
# 
# <a href="http://www.espn.com/tennis/player/_/id/2719/jan-zielinski" style="vertical-align: super;">Jan Zielinski</a>
# <a href="http://www.espn.com/tennis/player/_/id/8811/jan-zielinski" style="vertical-align: super;">Jan Zielinski</a>
# 
# Welcher Jan Zielinski hat hier welche ESPN-ID ?
# 
# -------------
# 
# Beispiel Mehrdeutigkeit Wikidata-Liste:
# 
# Aita P├╡ldma bereits definiert - QID:Q111345376:nicht eindeutig, zweiter Wert:Q111345215
# Cyril Suk bereits definiert - QID:Q112401180:nicht eindeutig, zweiter Wert:Q539768
# Dorothy Workman bereits definiert - QID:Q115978536:nicht eindeutig, zweiter Wert:Q3037193
# Ekaterina Makarova bereits definiert - QID:Q56249929:nicht eindeutig, zweiter Wert:Q56192280
# Jaime Fillol bereits definiert - QID:Q1258592:nicht eindeutig, zweiter Wert:Q5925030
# "Jairo Velasco bereits definiert - QID:Q6124249:nicht eindeutig, zweiter Wert:Q6124247
# Josh Goodall bereits definiert - QID:Q45783700:nicht eindeutig, zweiter Wert:Q178133
# Jos├⌐ Ag├╝ero bereits definiert - QID:Q116481688:nicht eindeutig, zweiter Wert:Q104880532
# Li Ting bereits definiert - QID:Q27858263:nicht eindeutig, zweiter Wert:Q240822
# Martin Damm bereits definiert - QID:Q66731884:nicht eindeutig, zweiter Wert:Q381173
# Montserrat Gonz├ílez bereits definiert - QID:Q29746767:nicht eindeutig, zweiter Wert:Q6906582
# Scott Humphries bereits definiert - QID:Q115841967:nicht eindeutig, zweiter Wert:Q961198
# 
# Bei welchem der Objekte Q115978536 oder Q3037193 sollte für Dorothy Workman eine ESPN-ID hinzugefügt werden?
# 
# Bei diesen Einträgen könnte es sich möglicherweise auch um Wikidata-Dubletten handeln (oder aber um zwei unterschiedliche Personen mit gleichem Namen), dies müsste ggf. im Einzelfall manuell geprüft werden.
# 
# -------------
# 
#################################




use utf8;
use Unicode::Normalize;
# my $test = "Vous avez aimé l'épée offerte par les elfes à Frodon";
# my $test = "Jan Zieliński";
# my $decomposed = NFKD( $test );
# $decomposed =~ s/\p{NonspacingMark}//g;
# print $decomposed; exit;


use utf8;
use Text::Unidecode;
# print unidecode('ä, ö, ü, é'); # will print 'a, o, u, e' 
# exit;

##########
use Unicode::Diacritic::Strip ':all';
# print strip_diacritics ($in), "\n";
# print fast_strip ($in), "\n";

##########
# Can't locate Unicode/Diacritic/Strip.pm in @INC (you may need to install the Unicode::Diacritic::Strip module) (@INC contains: C:/Strawberry/perl/site/lib C:/Strawberry/perl/vendor/lib C:/Strawberry/perl/lib) at match-tennisplayers-ESPN-id.pl line 19.
# BEGIN failed--compilation aborted at match-tennisplayers-ESPN-id.pl line 19.
#
# C:\wikipedia-main>cpan
# cpan> install Unicode::Diacritic::Strip
##########


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

sub store_utf82_encoding{
##see file UTF8vowels.txt
#converts  UTF8 Euro vowels to nearest English equivant  

  my $name=$_[0];
$name =~s/\x00c0/A/g; #Agrav
  $name =~s/\x00c1/A/g; # Aacute
  $name =~s/\x00c2/A/g; # Acap
  $name =~s/\x00c3/A/g; # Atilde
  $name =~s/\x00c4/A/g; # Auml
  $name =~s/\x00c5/A/g; # Aring
  $name =~s/\x00c6/AE/g; # AE
$name =~s/\x00c7/Ch/g; # Ccedilla
  $name =~s/\x00c8/E/g; #Egrav
  $name =~s/\x00c9/E/g; # Eacute
  $name =~s/\x00ca/E/g; # Ecap
  $name =~s/\x00cb/E/g; # Euml
  $name =~s/\x00cc/I/g; # Igrav
  $name =~s/\x00cd/I/g; # Iacut
  $name =~s/\x00ce/I/g; # Icap
  $name =~s/\x00cf/I/g; # Iuml
  $name =~s/\x00d0/Th/g; #CapEth
  $name =~s/\x00d1/NY/g; # Ntild
  $name =~s/\x00d2/O/g; # Ograv
  $name =~s/\x00d3/O/g; # Oacute
  $name =~s/\x00d4/O/g; # Ocap
  $name =~s/\x00d5/Th/g; # Otilde
  $name =~s/\x00d6/O/g; # Ouml
  $name =~s/\x00d8/O/g; # Ostroke 
  $name =~s/\x00d9/U/g; # Ugrav
  $name =~s/\x00da/U/g; # Uacute
  $name =~s/\x00db/U/g; # Ucap
  $name =~s/\x00dc/U/g; # Uuml
  $name =~s/\x00dd/Y/g; # Yacute
  $name =~s/\x00de/Th/g; # CapThorn
  $name =~s/\x00df/SS/g; # GermanUCss Ezette
  $name =~s/\x00e0/a/g; # agrav
  $name =~s/\x00e1/a/g; # aacute 
  $name =~s/\x00e2/a/g; # acap
  $name =~s/\x00e3/a/g; # atilde
  $name =~s/\x00e4/a/g; # auml
  $name =~s/\x00e5/a/g; # aring
  $name =~s/\x00e6/ae/g; # ae
  $name =~s/\x00e7/ch/g; # ccedilla 
  $name =~s/\x00e8/e/g; # egrav
  $name =~s/\x00e9/e/g; # eacute
  $name =~s/\x00ea/e/g; # ecap
  $name =~s/\x00eb/e/g; # euml
  $name =~s/\x00ec/i/g; # igrav
  $name =~s/\x00ed/i/g; # iacute
  $name =~s/\x00ee/i/g; # icap
  $name =~s/\x00ef/i/g; # iuml
  $name =~s/\x00f0/th/g; # lowercase eth
  $name =~s/\x00f1/ny/g; # ntilde
  $name =~s/\x00f2/o/g; # ograv
  $name =~s/\x00f3/o/g; # oacute 
  $name =~s/\x00f4/o/g; # ocap
  $name =~s/\x00f5/th/g; # otilde
  $name =~s/\x00f6/o/g; # ouml
  $name =~s/\x00f8/o/g; # ostroke
  $name =~s/\x00f9/u/g; # ugrav
  $name =~s/\x00fa/u/g; # uacute
  $name =~s/\x00fb/u/g; # ucap
  $name =~s/\x00fc/u/g; # uuml
  $name =~s/\x00fe/th/g; # lowercase thorn
  $name =~s/\x00fd/y/g; # yacute
  $name =~s/\x00ff/y/g; # yuml

return $name;

} #endsub store_utf82_encoding



#####################
# https://w.wiki/6LYc
#####################
# SELECT ?item ?itemLabel ?itemDescription WHERE {
#  {  ?item wdt:P106 wd:Q10833314. } 
#  {  ?item wdt:P31 wd:Q5. }
#  SERVICE wikibase:label { bd:serviceParam wikibase:language "en,de". }
# }
# ORDER BY ?itemLabel
#####################


#####################
### query.csv als ANSI abspeichern!!!
#####################

my $INFILE = 'ESPN-id.txt.html';

# <td><a href="http://www.espn.com/tennis/player/_/id/9993/facundo-diaz-acosta" style="vertical-align: super;">Facundo Diaz Acosta</a></td>


my %ESPNhash;
open ( IN, "< $INFILE") || die("cannot open $INFILE: $! \n");
while(<IN>)
{
  chop;
  my (@lines) = split (/\<td\>/,$_);

foreach my $line (@lines) {
# print  "LINE:$line:\n";

if ($line =~ /www.espn.com\/tennis\/player\/\_\/id\/([0-9]+)/)  {
#print "ID:$1:\n";
my $ID = $1;

 $line =~ s|<.+?>||g;
my $name = $line;

# print "NAME:$name:\n";
# print "=============\n";

  if (defined($ESPNhash{$name})) {
	  
	  if ($ID ne $ESPNhash{$name}) {
#	      print "$name bereits definiert - NAME für EPSN-ID:$ID: nicht eindeutig:alter Wert". $ESPNhash{$name}.":\n";
#          undef($ESPNhash{$name});
$ESPNhash{$name} = 'invalid';
	 }
  } else {
    $ESPNhash{$name} = $ID;
  }

}


}


# <a href="http://www.espn.com/tennis/player/_/id/2719/jan-zielinski" style="vertical-align: super;">Jan Zielinski</a>
# <a href="http://www.espn.com/tennis/player/_/id/8811/jan-zielinski" style="vertical-align: super;">Jan Zielinski</a>


# LINE:<a href="http://www.espn.com/tennis/player/_/id/6665/greta-zwerger" style="vertical-align: super;">Greta Zwerger</a></td>:



} 
close (IN);
#exit;
# my $count = 0;
# foreach my $this_name (sort keys %ESPNhash) {
# 	print "NAME:$this_name:".$ESPNhash{$this_name}."\n";
# $count++;
# }
#print "Anzahl ESPN-Einträge:$count:\n";
# exit;
############################

my $INFILE = 'query.csv';

open ( IN, "< $INFILE") || die("cannot open $INFILE: $! \n");

my %QIDhash;
while(<IN>)
{
  chop;
  my ($QID, $name) = split (/\,/,$_);
  $QID =~ s/http:\/\/www.wikidata.org\/entity\///og;

 # print "=============\n";  print "QID:$QID:NAME:$name:\n";
  
  # remove diacritics
 #  my $decomposed_name = NFKD( $name );
 #  $decomposed_name =~ s/\p{NonspacingMark}//g;
 #my $decomposed_name = unidecode($name); 
 # my $decomposed_name = store_utf82_encoding($name);

my $decomposed_name = strip_diacritics ($name);
 #print "DN:$decomposed_name:\n"; 
 #  my $decomposed_name = $name ;
  
  if (defined($QIDhash{$decomposed_name})) {
    # print "$decomposed_name bereits definiert - QID:$QID:nicht eindeutig, zweiter Wert:".$QIDhash{$decomposed_name}."\n";
    # unset($QIDhash{$decomposed_name});
    $QIDhash{$decomposed_name} = 'invalid';
  } else {
    $QIDhash{$decomposed_name} = $QID;
  }


}
close (IN);
# foreach my $this_name (sort keys %QIDhash) {
# 	print "NAME:$this_name:".$QIDhash{$this_name}."\n";
# }
# exit;


###########

# Aita P├╡ldma bereits definiert - QID:Q111345376:nicht eindeutig, zweiter Wert:Q111345215
#Cyril Suk bereits definiert - QID:Q112401180:nicht eindeutig, zweiter Wert:Q539768
#Dorothy Workman bereits definiert - QID:Q115978536:nicht eindeutig, zweiter Wert:Q3037193
#Ekaterina Makarova bereits definiert - QID:Q56249929:nicht eindeutig, zweiter Wert:Q56192280
#Jaime Fillol bereits definiert - QID:Q1258592:nicht eindeutig, zweiter Wert:Q5925030
#"Jairo Velasco bereits definiert - QID:Q6124249:nicht eindeutig, zweiter Wert:Q6124247
#Josh Goodall bereits definiert - QID:Q45783700:nicht eindeutig, zweiter Wert:Q178133
#Jos├⌐ Ag├╝ero bereits definiert - QID:Q116481688:nicht eindeutig, zweiter Wert:Q104880532
#Li Ting bereits definiert - QID:Q27858263:nicht eindeutig, zweiter Wert:Q240822
#Martin Damm bereits definiert - QID:Q66731884:nicht eindeutig, zweiter Wert:Q381173
#Montserrat Gonz├ílez bereits definiert - QID:Q29746767:nicht eindeutig, zweiter Wert:Q6906582
#Scott Humphries bereits definiert - QID:Q115841967:nicht eindeutig, zweiter Wert:Q961198


#### fuer alle Wikidata-Objekte
foreach my $this_name (sort keys %QIDhash) {
#	print "NAME:$this_name:".$QIDhash{$this_name}."\n";

 if (defined($ESPNhash{$this_name})) {
    if (( $QIDhash{$this_name} ne 'invalid') && $ESPNhash{$this_name} ne 'invalid') {

	# print "NAME:$this_name:QID:".$QIDhash{$this_name}.":ESPN:".$ESPNhash{$this_name}."\n";

	# print "NAME:$this_name:QID:".$QIDhash{$this_name}.":ESPN:".$ESPNhash{$this_name}."\n";
	
#	ESPN.com Tennisspieler ID (P11585)
	
#	    print $QIDhash{$this_name}."\tP11585\t".$ESPNhash{$this_name}."\tS143\tQ48183\n";    
	    print $QIDhash{$this_name}."\tP11585\t\"".$ESPNhash{$this_name}."\"\n";    
    # S ... Fundstelle
#    importiert aus Wikimedia-Projekt (P143)
# deutschsprachige Wikipedia (Q48183)

	
	}
	

 } else {
   # print "NO ESPN-ID found\n";
 }
}

exit;



