use YAML::Syck;
use Data::Dumper;
use strict;

##$YAML::Syck::ImplicitTyping = 1;

my $a = LoadFile('regexp.yml');
my $str = $ARGV[0];

my $r =  $a->{smtp_user}->{regex};
#$r =~ s/^\/|\/$//gc;

#my $r_c = eval($r);
my $r_c = eval("qr$r");
print "$r_c\n";


print "Comparando '$str' con regexp\n";

if($str =~ $r_c){
    print "chuta !!!\n";
    print "$1\n";
    print "$2\n";
    print "$3\n";
}
