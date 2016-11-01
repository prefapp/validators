require 'yaml'
require 'to_regexp'

module Validator
  class Exporter
  
    DEFAULT_OPTIONS = {
        package_name: 'Validator',
        version: 0.1,
        validations_file: '../validations.yml'
    }

    TEMPLATE_VARS = [:package_name, :version]
    
    attr_accessor :template_options, :validations_file
    
    def initialize(opts={})
    
      @template_options = {
        package_name: opts[:package_name] || DEFAULT_OPTIONS[:package_name],
        version: opts[:version] || DEFAULT_OPTIONS[:version],
      }
    
      @validations_file = opts[:validations_file] || DEFAULT_OPTIONS[:validations_file]
    
    end
    
    def dumpPackage
    
      template = getTemplate

      loadValidations

      template_completed = fillTemplate(template, @template_options)
    
      return template_completed
    
    end
    
    def fillTemplate(template, options)

      TEMPLATE_VARS.concat([:validations]).each do |var|

        regexp = "####{var.to_s.upcase}###"

        if var == :validations
          
          substitution = "{\n"

          @validations.each do |type, vals|
            substitution += "  \"#{type}\" => #{vals.to_s},\n"

          end
          substitution += '}'
          
          #substitution = @validations.to_s

        else
          substitution = options[var].to_s
        end
    
        template.gsub!(regexp, substitution)

      end

      return template
    end

    def loadValidations

      data = YAML.load_file(@validations_file)
      validations_copy  = data["validations"].clone

      data["validations"].each do |type, validation|
        
        if validation.include?("regexp") || validation.include?("regex")

          regexp = validation["regexp"] || validation["regex"]
          
          validations_copy[type].delete("regex")
          validations_copy[type].delete("regexp")

          validations_copy[type]["regexp"] = regexp.to_regexp

        end

        @validations = validations_copy

      end



      @template_options[:version] = data["version"] || DEFAULT_OPTIONS[:version]

    end
    
    
    def getTemplate

'class ###PACKAGE_NAME###

  VERSION = ###VERSION###

  attr_accessor :error

  def get_validations

    ###VALIDATIONS###
    
  end

  def initialize

    @validations = get_validations
    @error = nil

  end

  def validate(type, value)

    unless validations = @validations[type]
      raise "Validation to type #{type} not exists!"
    end

    validations.each do |validation_class, validation|

      begin
        if validation_class =~ /regex/
          
          validation = /#{validation}/ unless validation.is_a?(Regexp)

          unless value =~ validation
            raise "Input value (#{value}) is not a valid \"#{type}\"" 
          end

        elsif validation_class == "range"
          # si a validacion e unha string, construimos o Range
          unless validation.is_a?(Range)
            validation =~ /\A([+-]?\d+)\.\.([+-]?\d+)\z/
            validation = $1.to_i..$2.to_i 

            unless(value =~ /^[+-]?\d+$/)
              raise "Input value #{value} is not valid" 
            end
            
            ## convertimos os strings a int, senon non se dan comparao
            value = value.to_i if value.is_a?(String)
          end

          raise "#{validation} isn\'t Range" unless validation.is_a?(Range)

          unless validation.include?(value)
            raise "Input value #{value} not in range #{validation}"
          end

        elsif validation_class == "fixed_values"
          raise "#{validation} isn\'t Array" unless validation.is_a?(Array)
          
          unless validation.include?(value)
            raise "Input value #{value} invalid. Must be one of (#{validation.join(\',\')}"
          end
        end
      rescue Exception => e
        @error = e.message
        return false

      end

    end

    return true

  end

end
'
    end
  end
end
