#!/usr/bin/perl

use strict;

sub URLEncode {
    my $theURL = $_[0];
    $theURL =~ s/([\W])/"%" . uc(sprintf("%2.2x",ord($1)))/eg;
    return $theURL;
}

sub URLDecode {
    my $theURL = $_[0];
    $theURL =~ tr/+/ /;
    $theURL =~ s/%([a-fA-F0-9]{2,2})/chr(hex($1))/eg;
    $theURL =~ s/<!--(.|\n)*-->//g;
    return $theURL;
}


# CREATE		
# LAST	P31	Q4167836
# LAST	Sdewiki	Kategorie:Geographie (Bezirk Bruck-Mürzzuschlag)
# LAST	Lde	Kategorie:Geographie (Bezirk Bruck-Mürzzuschlag)

# my $INFILE = 'query.csv';
my $INFILE = '/home/m2k/Downloads/query.csv';


open ( IN, "< $INFILE") || die("cannot open $INFILE: $! \n");

my $count =0 ;
while(<IN>)
{
    chop;
    my ($qid_url,$dummy,@restlist ) = split (/\,/,$_);

    my $commons_sitelink = join (',',@restlist);
    $commons_sitelink =~ s/\"//og;
    
    if (!($commons_sitelink =~ /Category:/i)) { 
      # print "ignore $commons_sitelink\n"; 
      next; 
    }
    
    
    my $QID = $qid_url;
    $QID =~ s/http:\/\/www.wikidata.org\/entity\///og;

    if ($commons_sitelink =~ /Category:/) {
	# sonst galerie
    
      my $COMMONSCAT = URLDecode($commons_sitelink);
      $COMMONSCAT =~ s/\_/ /og;
      $COMMONSCAT =~ s/https:\/\/commons.wikimedia.org\/wiki\/Category://og;
      
      
      # print "QID:$QID:SITELINK:$COMMONSCAT:\n";
      if ($QID =~ /^Q[0-9]+/) {
      	
        print $QID."\tP373\t\"".$COMMONSCAT."\"\n";
      }
    }
      
}
close(IN);
