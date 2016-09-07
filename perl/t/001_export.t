use t::base;

use_ok(Validator::Exporter);

my ($fh, $filename) = tempfile();

print $fh $_."\n" foreach(<DATA>);
close $fh;

my $module = "TestValidator";

my $package = Validator::Exporter->new(
   
   validations_file => $filename,
   package_name => $module,

)->dumpPackage;


ok(
    $package,

    "Package generated"
);


eval($package);
if($@){
    die("Package generated doesn't compile: $@");
}


ok(
    !$@,
    "package compiles and evaled right"
);

ok(
    $TestValidator::VERSION == 1.1 &&
    ref($module->new) eq 'TestValidator',

    "Version and package name correctly setted"
);


eval{
    $module->new->validate('asdfsafasvxc', 'xxxx@'),
};

ok(
    $@,
    "The validations of a type that not exists raise an exception"

);

ok(
    !$module->new->validate('tcp_port', 'asfdf'),

    "Range validation1 fails (tcp, asfdf)"
);

ok(
    $module->new->validate('tcp_port', '26'),

    "Range validation2 works (tcp_port, 26)"
);

ok(
    !$module->new->validate('tcp_port', '26000000'),

    "Range validation3 fails (tcp_port, 26000000)"
);

ok(
    !$module->new->validate('apache_module', 'status'),

    "Fixed_values validation1 works (apache_module, status)"
);

ok(
    !$module->new->validate('apache_module', '26000000'),

    "Fixed_values validation2 fails (apache_module, 26000000)"
);

ok(
    !$module->new->validate('email', 'test@xxx'),

    "Regexp validation1 fails (email, test\@xxx)"
);

ok(
    $module->new->validate('email', 'test@xxx.com'),

    "Regexp validation2 works (email, test\@xxx.com)"
);


done_testing();


__DATA__

version: 1.1
validations: 
  tcp_port:
    range: 1..65535
  email:
    regexp: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i 
  apache_module:
    fixed_values:
    - alias
    - apreq2
    - auth_basic
    - auth_digest
    - wsgi
    - xsendfile
    - access_compat
