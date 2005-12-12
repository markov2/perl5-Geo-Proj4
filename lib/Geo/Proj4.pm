package Geo::Proj4;

use strict;
use warnings;
#our $VERSION = '0.96';

use base 'DynaLoader';

use Scalar::Util   qw/dualvar/;
use Carp           qw/croak/;

# The library definitions
bootstrap Geo::Proj4; # $VERSION;

=chapter NAME

Geo::Proj4 - PROJ.4 cartographic projections library

=chapter SYNOPSIS

  use Geo::Proj4;

  my $proj = Geo::Proj4->new(proj => "merc",
     ellps => "clrk66", lon_0 => -96)
       or die "parameter error: ".Geo::Proj4->error. "\n";

  my $proj = Geo::Proj4->new("+proj=merc +ellps=clrk66 +lon_0=-96")
       or die "parameter error: ".Geo::Proj4->error. "\n";

  my ($x, $y) = $proj->forward($lat, $lon);

  if($proj->hasInverse)
  {   my ($lat, $lon) = $proj->inverse($x, $y);
  }

  my $point = [ 123.12, -5.4 ];
  my $projected_point = $from->transform($to, $point);
  my $projected_multi = $from->transform($to, \@points);

=chapter DESCRIPTION

The Open Source PROJ.4 library converts between geographic coordinate
systems.  It is able to convert between geodetic latitude and longitude
(LL, most commonly the WGS84 projection), into an enormous variety of
other cartographic projections (XY, usually UTM).

WARNING: It is not always clear what the source projection is when
M<forward()> or M<inverse()> are used, i.e. in what projection system the
source data is expected to be in.  Therefore, you can better be specific
on both source and destination projection and use M<transform()>.

=chapter METHODS

=section Instantiation

=c_method new STRING|OPTIONS
The object defines the target projection, but that's easier said than
done: projections have different parameter needs.  The parameters which
can (or need to) be used are listed with C<cs2cs -lP>.

Two ways are provided to define the projection.  Either, use a list
of OPTIONS, which are pairs of parameters, or pass one string which
contains all parameters at once.  You must supply a C<proj> parameter.

In case of an OPTION list: WARNING: Specify boolean parameters (e.g. the
south parameter to the UTM projection) with a matching value of undef.

=examples
 my $proj = Geo::Proj4->new(proj => "merc",
    ellps => "clrk66", lon_0 => -96 )
       or die Geo::Proj4->error;

 my $proj = Geo::Proj4->new("+proj=merc +ellps=clrk66 +lon_0=096")
    or die Geo::Proj4->error;
=cut

my $last_error;

sub new($@)
{   my $class = shift;

    my $def;
    if(@_==1)
    {   $def = shift;
    }
    else
    {   my @args;
        while(@_)
        {   my ($key, $val) = (shift, shift);
            push @args, "+$key".(defined $val ? "=$val" : '');
	}
        $def = join ' ', @args;
    }

    my ($self, $error, $errtxt) = new_proj4($def);

    defined $self
        or $last_error = dualvar($error, $errtxt);

    $self;
}

=section Accessors

=c_method error
Returns a dualvar (see M<Scalar::Util>) containing the
error number and error string of the last reported error.

=example
 my $proj = Geo::Proj4->new(...);
 unless(defined $proj)
 {   my $error = Geo::Proj4->error;
     warn "error-code: ".$error+0;
     warn "error-string: $error\n";
 }
=cut

sub error() { $last_error }

=method normalized
Returns a string which is produced by the library based on the data
extracted from the initiation parameters.  This string may be more
explicit than the passed values, and could be used for debugging.
=cut

sub normalized()
{   my $norm = normalized_proj4(shift);
    $norm =~ s/^\s+//;
    $norm;
}

=method datum
Tries to return a datum name for this projection.
=cut

sub datum()
{   my $norm = shift->normalized;
    $norm =~ m/\+datum\=(w+)/ ? $1 : undef;
}

=method projection
Returns the projection type.
=cut

sub projection()
{   my $norm = shift->normalized;
    $norm =~ m/\+proj\=(w+)/ ? $1 : undef;
}

=method dump
Write the definition in extended form to stdout.  This output cannot be
caught, because it is done on stdio level, below the reach of PerlIO.
=cut

sub dump() { dump_proj4(shift) }

=method isLatlong
Returns true when the source projection is using a geodetic coordinate
system; i.e. uses lat long coordinates.  Same as M<isGeodesic()>.

=method isGeodesic
Returns true when the source projection is using a geodetic coordinate
system; i.e. uses lat long coordinates.  Same as M<isLatlong()>
=cut

sub isLatlong()  { is_latlong_proj4(shift) }
sub isGeodesic() { is_latlong_proj4(shift) }

=method isGeocentric
Returns true when the source projection is using a geocentric coordinate
system; i.e. uses x-y coordinates.
=cut

sub isGeocentric() { is_geocentric_proj4(shift) }

=method hasInverse
Returns whether the reverse function for the projection exists.  Some
projections are one-way.
=cut

sub hasInverse() { has_inverse_proj4(shift) }

=section Converters

=method forward LATITUDE, LONGITUDE

Perform a forward projection from LATITUDE and LONGITUDE (LL) to the
cartographic projection (XY) represented by the Geo::Proj4 instance.

WARNING: for historic reasons, latitude and longitude are assumed to be in 
(floating point) degrees, although the library expects rads.  See
M<forwardRad()>. A latitude south of the Equator and longitude west of
the Prime Meridian given with negative values.

Returned are two values, usually X and Y in meters, or whatever units are
relevant to the given projection.  When the destination projection also
than the order of parameters will be returned as LONG,LAT (not lat,long!)

On error, C<forward> will return undef for both values.

=example
 my ($x, $y) = $proj->forward($lat, $lon);
 my ($long2, $lat2) = $proj->forward($lat, $lon);

=cut

sub forward($$)
{   my ($self, $lat, $long) = @_;
    forward_degrees_proj4($self, $lat, $long);
}

=method forwardRad LATITUDE, LONGITUDE

Perform a forward projection from LATITUDE and LONGITUDE (LL) to the
cartographic projection (XY) represented by the Geo::Proj4 instance.
This function reflects to library function C<forward()>, expecting
radians, not degrees.

=cut

sub forwardRad($$)
{   my ($self, $lat, $long) = @_;
    forward_proj4($self, $lat, $long);
}

=method inverse (X,Y) | (LAT|LONG)

Perform an inverse projection from the (cartographic) projection represented
by this Geo::Proj4 object, back into latitude and longitude values.

WARNING: for historic reasons, latitude and longitude are assumed to be in 
(floating point) degrees, although the library expects rads.  See
M<inverseRad()>.

On error, C<inverse> will return undef for both values.

=example

  if($proj->hasInverse)
  {  my ($lat, $lon) = $proj->inverse($x, $y);
     ...
  }

=cut

sub inverse($$) { inverse_degrees_proj4(@_) }

=method inverseRad (X,Y) | (LAT|LONG)

Perform an inverse projection from the (cartographic) projection
represented by this Geo::Proj4 object, back into latitude and longitude
values.  Latitude and longitude are assumed to be in radians. See
M<inverse()>.
=cut

sub inverseRad($$) { inverse_proj4(@_) }

=method transform TO, POINT|ARRAY-OF-POINTS
Translate the POINTS into the projecten of TO.  Each point is specified
as two or three values in an ARRAY.  In case of latlong source or
destination projections, coordinates are translated into radians and/or
back.  Both input and output values are always in X-Y/LongLat order.
See M<transformRad()>

=example
 my $from  = Geo::Proj4->new("+proj=latlong +datum=NAD83");
 my $to    = Geo::Proj4->new("+proj=utm +zone=10 +datum=WGS84");

 my $point = [ 1.12, 3.25 ];  # See Geo::Point
 my $pr_point = $from->transform($to, $point);

 my $pr    = $from->transform($to, [ $point1, $point2 ]);
 my $pr_point1 = $pr->[0];
 my $pr_point2 = $pr->[1];

=cut

sub transform($$)
{   my ($self, $to, $points) = @_;

    croak "ERROR: expects point array"
        unless ref $points;

    my ($err, $errtxt, $pr);
    if(ref($points->[0]) eq 'ARRAY')
    {   ($err, $errtxt, $pr) = transform_proj4($self, $to, $points, 1);
    }
    else
    {   ($err, $errtxt, $pr) = transform_proj4($self, $to, [$points], 1);
        $pr = $pr->[0] if $pr;
    }

    $last_error = dualvar $err, $errtxt;
    $err ? () : $pr;
}

=method transformRad TO, POINT|ARRAY-OF-POINTS
Translate the POINTS into the projecten of TO.  Each point is specified
as two or three values in an ARRAY.  In case of latlong source or
destination projections, coordinates are expected to be in radians.
Both input and output values are always in X-Y/LongLat order.
See M<transform()>
=cut

sub transformRad($$)
{   my ($self, $to, $points) = @_;

    croak "ERROR: expects point array"
        unless ref $points;

    my ($err, $errtxt, $pr);
    if(ref($points->[0]) eq 'ARRAY')
    {   ($err, $errtxt, $pr) = transform_proj4($self, $to, $points, 0);
    }
    else
    {   ($err, $errtxt, $pr) = transform_proj4($self, $to, [$points], 0);
        $pr = $pr->[0] if $pr;
    }

    $last_error = dualvar $err, $errtxt;
    $err ? () : $pr;
}

sub AUTOLOAD(@)
{   our $AUTOLOAD;
    die "$AUTOLOAD not implemented";
}

=section Library introspection

=ci_method libVersion
Returns the version of the proj4 library
=cut

sub libVersion()
{   my $version = libproj_version_proj4();
    $version =~ s/./$&./g;
    $version;
}

=c_method listTypes
Returns a list with all defined projection types.

=example
 foreach my $id (Geo::Proj4->listTypes)
 {   my $def = Geo::Proj4->type($id);
     print "$id = $def->{description}\n";
 }
=cut

sub listTypes() { &def_types_proj4 }

=c_method typeInfo LABEL
Returns a hash with information about the specified projection type.  With
M<listTypes()>, all defined LABELS can be found.
=cut

sub typeInfo($)
{   my $label = $_[1];
    my %def = (id => $label);
    my($descr) = type_proj4($label);
    $def{has_inverse} = not ($descr =~ s/(?:\,?\s+no\s+inv\.?)//);
    $def{description} = $descr;
    \%def;
}

=c_method listEllipsoids
Returns a list with all defined ellips labels.

=example
 foreach my $id (Geo::Proj4->listEllipsoids)
 {   my $def = Geo::Proj4->ellipsoid($id);
     print "$id = $def->{name}\n";
 }
=cut

sub listEllipsoids() { &def_ellps_proj4 }

=c_method ellipsoidInfo LABEL
Returns a hash with information about the specified ellipsis.  With
M<listEllipsoids()>, all defined LABELS can be found.
=cut

sub ellipsoidInfo($)
{   my $label = $_[1];
    my %def = (id => $label);
    @def{ qw/major ell name/ } = ellps_proj4($label);
    \%def;
}

=c_method listUnits
Returns a list with all defined unit labels.

=example
 foreach my $id (Geo::Proj4->listUnits)
 {   my $def = Geo::Proj4->unit($id);
     print "$id = $def->{name}\n";
 }
=cut

sub listUnits() { &def_units_proj4 }

=c_method unitInfo LABEL
Returns a hash with information about the specified unit.  With
M<listUnits()>, all defined LABELS can be found.
=cut

sub unitInfo($)
{   my $label = $_[1];
    my %def = (id => $label);
    @def{ qw/to_meter name/ } = unit_proj4($label);
    $def{to_meter} =~ s!^1\.?/(.*)!1/$1!e;  # 1/2 -> 0.5
    \%def;
}

=c_method listDatums
Returns a list with all defined datum labels.

=example
 foreach my $id (Geo::Proj4->listDatums)
 {   my $def = Geo::Proj4->datum($id);
     print "$id = $def->{ellips_id}\n";
 }
=cut

sub listDatums() { &def_datums_proj4 }

=c_method datumInfo LABEL
Returns a hash with information about the specified datum.  With
M<listDatums()>, all defined LABELS can be found.
=cut

sub datumInfo($)
{   my $label = $_[1];
    my %def = (id => $label);
    @def{ qw/ellipse_id definition comments/ } = datum_proj4($label);
    \%def;
}

=chapter DETAILS

=section Install

Geo::Proj4 uses XS to wrap the PROJ.4 cartographic projections library. You
will need to have the PROJ.4 library installed in order to build and use
this module. You can get source code and binaries for the PROJ.4 library
from its home page at L<http://www.remotesensing.org/proj/>.

=section Projections

Covering all the possible projections and their arguments in PROJ.4
is well beyond the scope of this document. However, the C<cs2cs(1)>
utility that ships with PROJ.4 will list the projections it knows about
by running B<cs2cs -lp>, the ellipsoid models it knows with the B<-le>
parameter, the units it knows about with B<-lu>, and the geodetic datums
it knows with B<-ld>. Read L<cs2cs(1)> for more details.

Alternately, you can read the PROJ.4 documentation, which can be found
on the project's homepage. There are links to PDFs, text documentation,
a FAQ, and more.

=section Bugs

One common source of errors is that latitude and longitude are
swapped: some projection systems use lat-long, other use x-y
which is a swapped order.  Especially the M<forward()> and M<inverse()>
cause this problem, always flipping the coordinate order.  The
M<transform()> method is much easier: input and output in x-y/long-lat
order.

Also be warned  that the values must have the right sign. Make sure you
give negative values for south latitude and west longitude.  For
calculating projections, this is more important than on maps.

=chapter REFERENCES

See the Geo::Point website at L<http://perl.overmeer.net/geopoint/> for
an html version of this and related modules.

Effusive thanks to Frank Warmerdam (maintainer of PROJ.4) and Gerald
Evenden (main contributor of PROJ.4). Their PROJ.4 library home page:
L<http://www.remotesensing.org/proj/>

proj(1), cs2cs(1), pj_init(3).

=cut

1;
