use ExtUtils::MakeMaker;
                                                                                
require 5.006;

my $libversion = '4.4.9';
my $FWTools    = $ENV{GEOPROJ_FWTOOLS_DIR} || '.';

# This is very UNIX/Linux centric.  Please help me with the
# required windows tests.

my $FWbin      = "$FWTools/bin_safe";
my $cs2cs      = -x "$FWbin/cs2cs" ? "$FWbin/cs2cs" : 'cs2cs';

die "ERROR: proj library too old or not found: require $libversion\n"
   unless open DIR, "$cs2cs -v 2>&1 |";

my $got = <DIR>;

die "ERROR: proj library version not known\n"
   unless $got =~ m/\ ([\d.]+)\,/;

my $version = $1;

die "ERROR: libproj too old, found $version required is $libversion\n"
   if $version lt $libversion;

WriteMakefile
  ( NAME         => 'Geo::Proj4'
  , VERSION_FROM => 'lib/Geo/Proj4.pm'
  , AUTHOR       => 'Mark Overmeer, Schuyler Erle, Rich Gibson'
  , ABSTRACT     => 'Proj4 library for carthographic projections'
  , CCFLAGS      => "-I$FWTools/include"
  , LIBS         => [ "-L$FWTools/lib -lproj" ]
  );
