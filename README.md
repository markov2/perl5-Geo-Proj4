# distribution Geo-Proj4

  * My extended documentation: <http://perl.overmeer.net/CPAN/>
  * Development via GitHub: <https://github.com/markov2/perl5-Geo-Proj4>
  * Download from CPAN: <ftp://ftp.cpan.org/pub/CPAN/authors/id/M/MA/MARKOV/>
  * Indexed from CPAN: <https://metacpan.org/release/Geo-Proj4>

The Open Source PROJ.4 library converts between geographic coordinate
systems.  It is able to convert between geodetic latitude and longitude
(LL, most commonly the WGS84 projection), into an enormous variety of
other cartographic projections (XY, usually UTM).

## DEPRECATION

After a stable period of about 25 years under "version 4", the proj
library has seen huge changes since 2018.  The changes are too
structural to adapt this module to match them.

You can still manually install this module with the '4' version with some
effort: see wiki in git.  I have no time or use to create a new module.
Sorry.

## Install

You first have to install the libproj4 library.  Most Linux distributions
offer this.  Otherwise, pick one of the following options.

### Build library from scratch

Geo::Proj4 uses XS to wrap the PROJ.4 cartographic projections library.
You will need to have at least version 4.4.9 of the PROJ.4 library
installed in order to build and use this module. You can get source
code and binaries for the PROJ.4 library from its home page at
<http://proj4.org>.

### FWTools

An other way to get the library is by installing FWTools, available
at http://fwtools.maptools.org/

In case you have installed FWTools, set environment variable
GEOPROJ\_FWTOOLS\_DIR to the right location, before running Makefile.PL

```bash
   export GEOPROJ\_FWTOOLS\_DIR=/home/myself/FWTools
   perl Makefile.PL
   make
   make test
   make install
```

## Development &rarr; Release

Important to know, is that I use an extension on POD to write the manuals.
The "raw" unprocessed version is visible on GitHub.  It will run without
problems, but does not contain manual-pages.

Releases to CPAN are different: "raw" documentation gets removed from
the code and translated into real POD and clean HTML.  This reformatting
is implemented with the OODoc distribution (A name I chose before OpenOffice
existed, sorry for the confusion)

Clone from github for the "raw" version.  For instance, when you want
to contribute a new feature.

On github, you can find the processed version for each release.  But the
better source is CPAN; to get it installed simply run:

```sh
   cpan -i Geo::Proj4
```

## Contributing

When you want to contribute to this module, you do not need to provide
a perfect patch... actually: it is nearly impossible to create a patch
which I will merge without modification.  Usually, I need to adapt the
style of code and documentation to my own strict rules.

When you submit an extension, please contribute a set with

1. code

2. code documentation

3. regression tests in t/

**Please note:**
When you contribute in any way, you agree to transfer the copyrights to
Mark Overmeer (you will get the honors in the code and/or ChangeLog).
You also automatically agree that your contribution is released under
the same license as this project: licensed as perl itself.

## Copyright and License

This project is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
See <http://dev.perl.org/licenses/>
