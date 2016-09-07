use strict;
use warnings;

use Test::More;
use Data::Dumper;
use Carp;
use File::Basename;
use Cwd qw(abs_path);
use File::Temp qw(tempfile);


BEGIN{
	my $ruta = abs_path(join('/', dirname(__FILE__), '..', 'lib'));

	push @INC, $ruta;	
}

1;
