#!/usr/bin/perl
# mk_dodumps.pl

# this DOES seem to work with most reasonable /etc/fstab entries...

use strict;
use warnings;

use Time::Piece;
use Sys::Hostname;
use Sort::Naturally;

# tracking versions manually while developing...
#my $Ver   = '_v5';
my $Ver = '';

# main level-0 all-partition dump-script...
my $Fname = 'do_dumps' . $Ver . '.sh';

open( my $fstab,  "<", "/etc/fstab" ) or die "Cannot open /etc/fstab.";
open( my $dodump, ">", "$Fname" )     or die "Cannot open $Fname.";

my %dsk2loc;
my %chkDays = ( 1 => 'Assumed' );
my $Day1ck  = 0;
my %dsk2day;
my $d2d = 0;
my %dsk2fin;
my $prtln;
my $prtdl;
my @prtlns;
my @prtdls;

while (<$fstab>) {
    my @list = split;

    my $beg    = "Device : ";
    my $part   = "adefghijklmnop";
    my $mid    = "\t\t\t Mountpoint : ";
    my $okB    = 0;                        # basename-of-disk
    my $okP    = 0;                        # partition-of-disk
    my $okD    = 0;                        # mount-pt-in-fs
    my $okE    = 0;                        # exists-on-boot
    my $ok     = 0;                        # overall-ok...
    my $chkDay = 0;                        #my %chkDays = ( Assumed => '1');

    if ( $list[0] =~ m,^/dev/.+, ) { $okB = 1; }
    if ( $list[0] =~ m,[$part]$, ) { $okP = 1; }
    if ( $list[0] =~ m,^\w+.*\., ) { $okB = 1; }
    if ( $okB && $okP ) {
        $beg .= $list[0];
    }
    if ( scalar(@list) > 3 ) {             # need 4-elements...
        if ( $list[1] =~ m,^/+, )    { $okD = 1; }
        if ( $list[3] !~ m,noauto, ) { $okE = 1; }
        $ok = $okB && $okP && $okD && $okE;
    }

    # last two numbers are days-btwn-dumps and fs-check-order
    # check they exist, and both non-zero (where strings eval to zero)
    # also double-check for 1-day dumps...
    if ( $ok && ( $list[4] && $list[5] ) ) {
        my $ok4 = 0;
        my $ok5 = 0;
        if ( $list[4] =~ m,^[1-9][0-9]*$, ) { $ok4 = 1; }
        if ( $list[5] =~ m,^[1-9][0-9]*$, ) { $ok5 = 1; }
        if ( $ok4 && $ok5 ) {
            $chkDay = $list[4];
            if ( $Day1ck || ( $chkDay == 1 ) ) { $Day1ck = 1; }
            if ( not exists $chkDays{$chkDay} ) {
                $chkDays{"$chkDay"} = "Used";
            }
            $dsk2day{ $list[0] } = $list[4];
        }
    }

    if ($ok) {
        if ($chkDay) {
            $prtln = "chkday=$chkDay\t $beg $mid $list[1] \n";
            $dsk2loc{ $list[0] } = $list[1];
        }
        else {
            $prtln = " $beg $mid $list[1] \n";
        }
        push( @prtlns, $prtln );
##        print $prtln;
    }
}

# after parsing full-fstab, double-check for assumption...
if ( not $Day1ck ) { delete $chkDays{1} }

# this creates more-generic shell-script-var version...
my $lvl    = 0;
my $dts    = Time::Piece::localtime->strftime('%Y%m%d_%H%M%S');
my ($hst)  = split /\./, Sys::Hostname::hostname();
my $setlvl = "LVL='0'";
my $v2lvl  = '$LVL';
my $setdts = "DTS=`date +%Y%m%d_%H%M%S`";
my $v2dts  = '$DTS';
my $sethst = "HN=`hostname -s`";
my $v2hst  = '$HN';

# to avoid multiple pwd-reqs on long-dump without 'persist'
my $v4dobeg = "doas sh -c \" { \n";
my $v4beg   = "  dump -" . $v2lvl . " -au -f /mnt/dump";
my $v4doend = "} \" \n";
my $v2end   = $v2hst . "." . $v2dts . "-" . $v2lvl;

my $hdr = <<"END_HEADER";
$setlvl
$setdts
$sethst
END_HEADER

my @lines;
my @v2lines;
my $line;
my $v2line;
my $midP;
my $midL;

for ( keys %chkDays ) {
    $prtdl = "Day-list of $_ is $chkDays{$_} \n";
    push( @prtdls, $prtdl );
}
##print nsort @prtdls;

while ( my ( $d, $l ) = each %dsk2loc ) {
    my $hDP = $d;
    if ( "/" eq $l ) {
        $midP = "a";
        $midL = "root";
    }
    else {
        $midP = "p_" . chop $d;    # yes, ancient strip last-char...
        $midL = $l;                # yes, save the copy b4 modifying...
        $midL =~ s,/,_,g;
        $midL = substr( $midL, 1 );
    }

    $v2line = $v4beg . ".$midP-$midL." . $v2end . " $l ; \n";
    push( @v2lines, $v2line );
    $dsk2fin{$hDP} = $v2line;
}

# HERES THE FIRST FILE DATA...
my $prehdr = <<"END_PREHEADER";
#!/bin/sh
# $Fname
END_PREHEADER
print $dodump $prehdr;
print $dodump $hdr;
print $dodump $v4dobeg;
print $dodump sort @v2lines;
print $dodump $v4doend;
chmod 0755, $dodump;

# hack together the other-files...
my $cnt = 1;

for ( sort { $a <=> $b } keys %chkDays ) {
    my $Dday = $_;

    # we had dodump open for main-version, so loop-closed/reopen...
    close($dodump);
    my $Fname  = "./do_dumps$Ver-lvl$cnt-days$Dday.sh";
    my $setlvl = "LVL=$cnt";
    $cnt++;
    my $prehdr = <<"END_PREHEADER";
#!/bin/sh
# $Fname
END_PREHEADER

    # HERES THE OTHER-DUMPS FILE DATA...
    open( my $dodump, ">", "$Fname" ) or die "Cannot open $Fname.";
    print $dodump $prehdr;
    print $dodump $hdr;
    print $dodump $v4dobeg;
    my @dp = keys(%dsk2loc);
    my $d;
    foreach $d (@dp) {
        $d2d = $dsk2day{$d};
        if ( $d2d <= $Dday ) {
            print $dodump $dsk2fin{$d};
        }
    }
    print $dodump $v4doend;
    chmod 0755, $dodump;
}

# go ahead and printout the earlier-collected data...
print @prtlns;
print nsort @prtdls;
$cnt--;    # undo final increment, so...
print "Technically, Level-$cnt is equivalent to Level-0...\n";

close($fstab);
close($dodump);
exit 0;
