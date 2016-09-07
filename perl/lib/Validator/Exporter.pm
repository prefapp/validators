package Validator::Exporter;
use YAML::Syck;
use Data::Dumper;
use strict;

$Data::Dumper::Terse = 1;
#$Data::Dumper::Ident = 1;

my @TEMPLATE_VARS = qw(PACKAGE_NAME VERSION);

my %DEFAULT_OPTIONS = (
    package_name => 'Validator',
    version => 0.1,
    validations_file => '../validations.yml'
);


sub new {

    my ($class, %opts) = @_;



    my $self = bless(
        {
            validations_file => $opts{validations_file},

            validations => {},

            template_options => {
                version => $DEFAULT_OPTIONS{version},
                package_name => $opts{package_name} || $DEFAULT_OPTIONS{package_name},
            }
        
        },

        $class
    );

    $self->__loadValidations();

    $self;
}


sub dumpPackage{
    my ($self) = @_;

    my $template = $self->__data;

    my $package = $self->__fillTemplate(
        $template, 
        %{$self->{template_options}}
    );

    $self->__dumpPackage($package, $self->{validations});

}

##### methods
sub __loadValidations{
    my ($self) = @_;

    my $data = LoadFile($self->{validations_file});

    while(my ($type, $validations) = each(%{$data->{validations}})){
    
        if(my $v = delete($validations->{regex}) || delete($validations->{regexp})){
            $data->{validations}->{$type}->{regexp} = eval("qr$v");
        }
    
    }

    $self->{validations} = $data->{validations};
    $self->{template_options}->{version} = $data->{version} || $DEFAULT_OPTIONS{version};
    $self;
}


sub __dumpPackage{
    my ($self,$package, $validations) = @_;
    
    join '', $package, "\n", 
            'sub VALIDATIONS {', "\n",
            'return ',Dumper($validations),
           '}' ;
}


sub __fillTemplate {
    my ($self,$template, %options) = @_;

    foreach my $var (@TEMPLATE_VARS){

        die("Lack of template var value '$var'") unless(exists($options{lc($var)}));


        my $value = $options{lc($var)};

        $template =~ s/###$var###/$value/g;
        
    }

    $template;
}


sub __data {
    'package ###PACKAGE_NAME###;
use strict;

our $VERSION  = ###VERSION###;

sub new {
    my $validations = &VALIDATIONS();

    return bless({
        validations => $validations
    })
}

sub validate {
    my ($self, $type, $value) = @_;
    
    unless(exists($self->{validations}->{$type})){
        die ("Validation to type #{type} not exists!")
    }

    while(my ($validation_class, $validation) = each(%{$self->{validations}->{$type}})){

        if($validation_class =~ /^regex/){

            return undef unless($value =~ $validation);
        }
        
        if($validation_class eq \'fixed_values\'){

            return undef unless(grep {$_ eq $value} @$validation);
            
        }

        if($validation_class eq \'range\'){

            my ($lower_limit, $upper_limit) = ( $validation =~ /^(\d+)\.\.(\d+)$/) ;

            $value *= 1;
            $lower_limit *= 1;
            $upper_limit *= 1;

            #print "Validando $value entre $lower_limit y $upper_limit \n";
            
            return undef unless($value >= $lower_limit && $value <= $upper_limit);
        }
    }

    1;
}
'
}

1;
