#!/usr/bin/perl -w
# when run, it will show all definitions.

use lib qw[blib/lib blib/arch ../blib/lib ../blib/arch];

use Geo::Proj4;

my @ells = Geo::Proj4->listEllipsoids;
foreach my $ell (@ells)
{   my $def = Geo::Proj4->ellipsoidInfo($ell);
    print "$ell: ".join(';', %$def), "\n";
}

my @units = Geo::Proj4->listUnits;
foreach my $unit (@units)
{   my $def = Geo::Proj4->unitInfo($unit);
    print "$unit: ".join(';', %$def), "\n";
}

my @datums = Geo::Proj4->listDatums;
foreach my $datum (@datums)
{   my $def = Geo::Proj4->datumInfo($datum);
    $def{description} ||= '';
    print "$datum: ".join(';', %$def), "\n";
}

my @types = Geo::Proj4->listTypes;
foreach my $type (@types)
{   my $def = Geo::Proj4->typeInfo($type);
    print "$type: ".join(';', %$def), "\n";
}
