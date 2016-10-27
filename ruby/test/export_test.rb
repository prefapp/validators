require 'validator/exporter'

class TestExport < Test::Unit::TestCase

  def setup

    @file = "#{File.dirname(__FILE__)}/fixtures/test_validations.yml"
    
    @mod_contents = Validator::Exporter.new(
      validations_file: @file,
      package_name: "ValidatorTest"
    ).dumpPackage
    
  end


  def test_module_generation


    assert(!@mod_contents.empty?, "Module generated")

  end


  def test_module

    eval(@mod_contents)

    assert_raise  "Trying to validate an non existent type cause exception" do
      ValidatorTest.new.validate('asjdofdjaso','xxx@')
    end

    validator = ValidatorTest.new

    assert(!validator.validate('email', 'fjdso@sfjo'), "Invalid email must fail validation")

    assert(
      validator.error =~ /validation of email not match pattern/,
      "Invalid email must set correct error: #{validator.error}")

  end

end
