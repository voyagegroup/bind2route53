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
    assert_equal('example.com.', find_zonename_from_template(template_parsed))
  end

  def test_count_record_set_group
    template_path   = './template_for_test/test_count_record_set_group_01.template'
    template        = File.open(template_path).read
    template_parsed = JSON.parse(template)
    assert_equal(1, count_record_set_group(template_parsed))

    template_path   = './template_for_test/test_count_record_set_group_02.template'
    template        = File.open(template_path).read
    template_parsed = JSON.parse(template)
    assert_equal(2, count_record_set_group(template_parsed))

    template_path   = './template_for_test/test_count_record_set_group_03.template'
    template        = File.open(template_path).read
    template_parsed = JSON.parse(template)
    assert_equal(0, count_record_set_group(template_parsed))
  end
end
