#!/usr/bin/perl
use v5.14;
use TAP::Harness ();
use lib 'lib';


my @files = glob( "t/*.t" );
my $tap = TAP::Harness->new({
    lib => 'lib',
});
$tap->runtests( @files );
