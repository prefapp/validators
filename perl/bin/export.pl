use strict;
use Cwd qw(abs_path);
use File::Basename;

my %options = ();

BEGIN{
	my $ruta = abs_path(join('/', dirname(__FILE__), '..', 'lib'));

	push @INC, $ruta;	
}


use Validator::Exporter;

foreach my $arg (@ARGV){
    my ($key, $value) = split /\=/, $arg;
    $options{$key} = $value;
}

unless(@ARGV && $options{package_name}){

    print "Usage: $0 package_name=<name> validations_file=<path to validations.yml>\n";
    exit 1;
}



print Validator::Exporter->new(%options)->dumpPackage;
