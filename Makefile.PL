use ExtUtils::MakeMaker;
                                                                                
require 5.006;

my $libversion = '4.4.9';

# Should also work when you do not have FWTools installed...
my $FWTools    = $ENV{GEOPROJ_FWTOOLS_DIR}
              || $ENV{FWTOOLS_DIR}           # windows
              || '.';

# This is part is very UNIX/Linux centric.  Please help me with the
# required windows tests.
my $FWbin      = "$FWTools/bin_safe";
my $cs2cs      = -x "$FWbin/cs2cs" ? "$FWbin/cs2cs" : 'cs2cs';

die "ERROR: proj library too old or not found: require $libversion\n"
   unless open CS, "$cs2cs 2>&1 |";

my $got = <CS>;

die "ERROR: proj library version not known\n"
   unless $got =~ m/\ ([\d.]+)\,/;

my $version = $1;

die "ERROR: libproj too old, found $version required is $libversion\n"
   if $version lt $libversion;

WriteMakefile
 ( NAME     => 'Geo::Proj4'
 , VERSION  => '1.02'
 , AUTHOR   => 'Mark Overmeer'
 , ABSTRACT => 'Proj4 library for carthographic projections'
 , INC      => "-I$FWTools/include"
 , LIBS     => [ "-L$FWTools/lib -lproj" ]
 , LICENSE  => 'perl'
 );

### used by oodist during production of this distribution
sub MY::postamble { <<'__POSTAMBLE' }

# for DIST, see PODTAIL.txt as well
LICENSE		= artistic
RAWDIR          = ../public_html/geoproj4/raw
DISTDIR         = ../public_html/geoproj4/source
__POSTAMBLE
