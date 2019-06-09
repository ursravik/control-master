#!/usr/bin/perl -w
use strict;
use LWP::Simple;
use Carp;

#use File::Temp qw/tempdir tempfile/;
use Net::Domain qw(hostfqdn);
use Net::FTP;

my $tstamp   = time;
my $lssecdir = "/tmp/.lssec.$tstamp";
`mkdir -p $lssecdir`;
my $lssecfile   = "$lssecdir/$tstamp.tar";
my $hostname    = hostfqdn();
my $localip     = join qw{.}, unpack 'C*', gethostbyname $hostname ;
my $lssecreport = $lssecdir . qw{/} . $hostname . qw{-} . $localip;
my $lssectar    = get
'http://rchgsa.rchland.ibm.com/projects/r/rchisgsecurity/tools/lssecfixes/lssecfixes.tar.gz';

my $LSSEC;
open $LSSEC, '>', $lssecfile or croak 'Could not open lssec output file';
print {$LSSEC} $lssectar or croak 'Could not write lssec output file';
close $LSSEC or croak 'Could not close lssec output file';

my $extract     = `cd $lssecdir && gunzip -c $lssecfile | tar xf -`;
my $lssecver    = `$lssecdir/bin/lssecfixes --version`;
my $lssecoutput = `$lssecdir/bin/lssecfixes -a -F -H -s other 2>&1`;

open $LSSEC, '>', $lssecreport or croak 'Could not open report file';
print {$LSSEC} <<"EOF";
Hostname: $hostname
IP: $localip
Version: $lssecver
$lssecoutput;
EOF
close $LSSEC or croak 'Could not close report file';

my $ftp = Net::FTP->new( 'rchgsa.ibm.com', Timeout => 240 )
  or croak 'could not start FTP';
$ftp->login( 'anonymous', 'stgsec@us.ibm.com' )
  or croak 'could not login as anonymous';
$ftp->cwd('/projects/r/rchisgsecurity/apar_status')
  or croak 'could not change directory';
$ftp->put($lssecreport) or croak 'could not upload results';
$ftp->quit;

`rm -rf $lssecdir`;
