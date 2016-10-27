$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'validator/exporter'

options = {}

ARGV.each do |arg|

  key, value = arg.split('=', 2)

  options[key.to_sym] = value

end

unless ARGV && options.has_key?(:package_name)

    print "Usage: #{$0} package_name=<name> validations_file=<path to validations.yml>\n";
    exit 1;
end

print Validator::Exporter.new(options).dumpPackage
