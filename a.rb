require 'yaml'
require_relative "reg.rb"

yamlxx =  YAML.dump(exp)
puts yamlxx

a =  YAML.load(yamlxx)
