#!/usr/bin/perl

open (IN, "< filter.rss ") || die("Couldn't open file: $!\n");
$count = 0;

my $match_vorname = 0;
my $vorname = "";

my $match_nachname = 0;
my $nachname = "";

my $match_wahlkreis = 0;
my $wahlkreis = "";

my $match_fraktion = 0;
my $fraktion = "";

while (<IN>) {
    chop;
	
  my $line=$_;

if ($line =~ /^Vorname:/) { $match_vorname = 1; next; }
if ($match_vorname == 1) { $vorname = $line; 
# print "VORNAME:$vorname:\n"; 
$match_vorname = 0; 
next; }
	
if ($line =~ /^Nachname:/) { $match_nachname = 1; next; }
if ($match_nachname == 1) { $nachname = $line; 
# print "NACHNAME:$nachname:\n"; 
$match_nachname = 0; 
next; }

if ($line =~ /^Fraktion:/) { $match_fraktion = 1; next; }
if ($match_fraktion == 1) { 

$fraktion = $line; $fraktion =~ s/<.+?>//g;  # drop html-tags
# print "FRAKTION:$fraktion:\n"; 
$match_fraktion = 0; 
}

	
if ($line =~ /^Wahlkreis:/) { $match_wahlkreis = 1; next; }
if ($match_wahlkreis == 1) { $wahlkreis = $line; 
 #print "WAHKLKREIS:$wahlkreis:\n"; 
 $match_wahlkreis = 0; 

$wahlkreis =~ s/1 Burgenland/[[Landeswahlkreis Burgenland|1 – Burgenland]]/og;
$wahlkreis =~ s/2 Kärnten/[[Landeswahlkreis Kärnten|2 – Kärnten]]/og;
$wahlkreis =~ s/3 Niederösterreich/[[Landeswahlkreis Niederösterreich|3 – Niederösterreich]]/og;
$wahlkreis =~ s/4 Oberösterreich/[[Landeswahlkreis Oberösterreich|4 – Oberösterreich]]/og;
$wahlkreis =~ s/5 Salzburg/[[Landeswahlkreis Salzburg|5 – Salzburg]]/og;
$wahlkreis =~ s/6 Steiermark/[[Landeswahlkreis Steiermark|6 – Steiermark]]/og;
$wahlkreis =~ s/7 Tirol/[[Landeswahlkreis Tirol|7 – Tirol]]/og;
$wahlkreis =~ s/8 Vorarlberg/[[Landeswahlkreis Vorarlberg|8 – Vorarlberg]]/og;
$wahlkreis =~ s/9 Wien/[[Landeswahlkreis Wien|9 – Wien]]/og;


# print "VORNAME:$vorname:NACHNAME:$nachname:WAHLKREIS:$wahlkreis:FRAKTION:$fraktion:\n";


# |-
# | [[Hannes Amesbauer|Amesbauer Hannes]]  {{PersonZelle|Hannes|Amesbauer}}
# | [[Datei:Image of none.svg|80px]]
# | 1981
# |
# | bgcolor="#{{Wahldiagramm/Partei|FPÖ|dunkel|AT}}" |
# | FPÖ
# | [[Regionalwahlkreis Obersteiermark|6D – Obersteiermark]]
# |
# |-




print "|-
| {{PersonZelle|".$vorname."|".$nachname."}}
| \[\[Datei:Image of none.svg|80px\]\]
|
|
| bgcolor=\"#{{Wahldiagramm/Partei|".$fraktion."|dunkel|AT}}\" |  
| $fraktion
| $wahlkreis
| 
";
# print "\n";


next; }
	

	
next;

  
 

  
  

  

    

}
close(IN);

