#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/test_helper.rb'
include Bind2Route53

class TestLibsCloudFormation < Test::Unit::TestCase
  def setup
  end

  def test_find_zonename_from_template
    template_path   = './template_for_test/test_find_zonename_from_template_01.template'
    template        = File.open(template_path).read
    template_parsed = JSON.parse(template)
    assert_equal = 'example.com.', find_zonename_from_template(template_parsed)
  end

end
