use ExtUtils::MakeMaker;
                                                                                
require 5.006;

WriteMakefile
  ( NAME         => 'Geo::Proj4'
  , VERSION_FROM => 'lib/Geo/Proj4.pm'
  , AUTHOR       => 'Schuyler Erle, Rich Gibson, Mark Overmeer'
  , ABSTRACT     => 'Wrapper around proj4 library'
  , CCFLAGS      => "-I/home/satfoto/FWTools/include"
  , LIBS         => [ "-L/home/satfoto/FWTools/lib -lproj" ]
  );
