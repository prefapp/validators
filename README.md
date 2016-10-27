# General validations and exporters to diferent languages

The idea behind this project, is to get a list of common validations, expressed in a agnostic language (yaml)
and then, through exporters in diferent langs, obtain automatically the translated module corresponding to
platform.

## Common usage

### perl
- First you must generate the validator module
  - to perl:
```bash
  perl bin/exportar.pl package_name=ValidatorModule validations_file=<path to validatios.yml>
```

- Then use it in your projects
```perl
if(ValidatorModule->new->validate('email', $var)){
  print "OK\n";
}
else{
  print "KO\n";
}
```

### ruby
```
validator = Validator.new

if validator.validate('email', var)
    puts "OK"
else
    puts "KO. error: #{validator.error}"
end
```

## validation types

There is three type of validations that can be used in any key:

- **regexp**: value must match the regexp specified
- **range**: value must be numerical, and be in range specified 
- **fixed_values**: list of acceptable values that passed val can hold
