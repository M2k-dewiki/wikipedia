#!/usr/bin/perl

use strict;


# Petscan für https://de.wikipedia.org/wiki/Kategorie:Grieche_(Antike)

# https://petscan.wmflabs.org/?outlinks_any=&active_tab=tab_wikidata&combination=union&cb_labels_any_l=1&links_to_no=&format=html&edits%5Banons%5D=both&negcats=&max_sitelink_count=&categories=Grieche+%28Antike%29&sortorder=ascending&langs_labels_yes=&links_to_any=&max_age=&sparql=&sitelinks_no=&wpiu=none&ns%5B0%5D=1&min_sitelink_count=&cb_labels_no_l=1&language=de&wikidata_item=with&depth=30&wikidata_label_language=&langs_labels_no=&cb_labels_yes_l=1&project=wikipedia&subpage_filter=either&edits%5Bflagged%5D=both&templates_no=&interface_language=en&after=&show_disambiguation_pages=both&wikidata_source_sites=&manual_list=&search_max_results=500&maxlinks=&before=&wikidata_prop_item_use=&labels_yes=&ores_prob_from=&regexp_filter=&doit=


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

my $file_urllist = 'wikipedia-urllist-add-description-griechen.txt';
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
# my $INFILE = '/home/m2k/Downloads/query.csv';
# my $INFILE = '/home/m2k/Downloads/Download';
# my $INFILE = '/home/m2k/Downloads/Download.csv';
my $INFILE = 'Download.csv';

open ( IN, "< $INFILE") || die("cannot open $INFILE: $! \n");

my $count =0 ;
while(<IN>)
{
    chop;

    my ($number,$title,$pageid,$namespace,$length,$touched,$QID) = split (/\,/,$_); 
 $title =~ s/\"//og;
 $QID =~ s/\"//og;
 my $sitelink = 'https://de.wikipedia.org/wiki/'.$title;
    
 #   $sitelink =~ s/\"//og;
 #  $QID =~ s/http:\/\/www.wikidata.org\/entity\///og;
     my $url = $sitelink;
	 

    if (! ($QID =~ /Q[0-9]+/ )) {
	   # print "$QID ist KEINE QID\n";
	next ;
    }

    # print "QID:$QID:SL:$sitelink:\n"; next;


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



# check, if german description is already set for this wikidata object - if not, the get the description for de-WP article ("Vorlage:Personendaten" -> KURZBESCHREIBUNG )
my $wd_url = 'https://query.wikidata.org/sparql?query=SELECT%20%3FitemDesc%0AWHERE%20%7B%0A%20%20SERVICE%20wikibase%3Alabel%20%7B%0A%20%20%20%20bd%3AserviceParam%20wikibase%3Alanguage%20%22de%22%20.%0A%20%20%20%20wd%3A'.$QID.'%20schema%3Adescription%20%3FitemDesc%20.%0A%20%20%7D%0A%7D';
# print "WD_URL:$wd_url:\n";
    	    $agent->add_header(
               'Accept' => 'text/csv'
    		);
    	    $agent->get( $wd_url );
          my $result3 = $agent->content;
          $result3 =~ s/\s//og;
    #     print "RESULT:$result3:\n";
   if ($result3 eq 'itemDesc' ) { 
     # print "beschreibung (de) ist noch leer";
     my $description = "";
     if ($result2 =~ /\|(\s*)KURZBESCHREIBUNG(\s*)=(\s*)(.*)/i) {
       $description = $4;
     }
     if ($description ne "") {
       print "$QID\tDde\t\"".$description."\"\n";
     }
  } else {
    # print "beschreibung ist bereits gesetzt - do nothing";
  }
  ################### 
  


   
   ##############

 
#     print "KAT:$kat:LEMMA_MIT:$lemma_mit_klammerzusatz:LEMMA_OHNE:$lemma_ohne_klammerzusatz:\n";
    


if ($description ne "") {
  

   # print "$QID\tDde\t\"".$description."\"\n";

}    
# exit;

  

}
close(IN);

close(OUT);
