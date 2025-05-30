#!/usr/bin/perl

use strict;


###########################
# for details see:
# 
# https://www.wikidata.org/w/index.php?title=User_talk:LIPARUS232&oldid=2354723170#German_descriptions_-_alias_instead_of_description,_upper_case_instead_lower_case,_wrong_gender
# 
#
#
# the (3851) edits of editgroup
#https://editgroups.toolforge.org/b/OR/255071bb4ac/
#have been reverted.
#Female indian actresses without german description have been selected using QLEVER, since this usually does not end with a timeout like the Wikidata Query Service often does:
#https://qlever.cs.uni-freiburg.de/wikidata/0Hx8JQ
#For these items the description indische Schauspielerin has been added:
#https://quickstatements.toolforge.org/#/batch/247136
#The QuickStatements could be prepared using a spreadsheet application like Excel, LibreOffice or OpenOffice.
#For example:
#https://www.wikidata.org/w/index.php?title=Q5052949&diff=2354691538&oldid=2354405111
#Similar has been done for male indian actors:
#male indian actors without german description:
#https://qlever.cs.uni-freiburg.de/wikidata/XKXbUs
#add description indischer Schauspieler
#https://quickstatements.toolforge.org/#/batch/247149
#For example:
#https://www.wikidata.org/w/index.php?title=Q901655&diff=2354720723&oldid=2354404069

###########################


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

my $file_urllist = 'wikidata_XKXbUs.csv';
my %urllist ;
if (-e $file_urllist) {
  open (IN, "< $file_urllist") || die ("Cannot open $file_urllist : $! \n");
  while (<IN>) {
    chop;
    my $line = $_;
$line =~ s/\,//og;

   $line =~ s/http:\/\/www.wikidata.org\/entity\///og;

  $line =~ s/^(\s)*//og; # trim
     $line =~ s/(\s)*$//og; # trim

#  print "$line\tDde\t\"indische Schauspielerin\"\n";      
  print "$line\tDde\t\"indischer Schauspieler\"\n";      


  }
  close(IN);
}

