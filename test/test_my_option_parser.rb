#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/test_helper.rb'
include Bind2Route53

class TestMyOptionParser < Test::Unit::TestCase
  def setup
  end

  def test_short_option
    args = [
      '-c', '/path/to/config', 
      '-f', '/path/to/zonefile', 
      '-z', 'zonename',
      '-t', '/path/to/template',
      '-s', 'stackname'
    ]

    options = MyOptionParser.new(args)
    options.add_option_c
    options.add_option_f
    options.add_option_z
    options.add_option_t
    options.add_option_s
    options.parse

    assert_equal '/path/to/config',   options.val(:config_path)
    assert_equal '/path/to/zonefile', options.val(:zonefile_path)
    assert_equal 'zonename.',         options.val(:zonename)
    assert_equal '/path/to/template', options.val(:template_path)
    assert_equal 'stackname',         options.val(:stackname)
  end

  def test_long_option
    args = [
      '--config-file',   '/path/to/config', 
      '--zone-file',     '/path/to/zonefile', 
      '--zone-name',     'zonename',
      '--template-file', '/path/to/template',
      '--stack-name',    'stackname'
    ]

    options = MyOptionParser.new(args)
    options.add_option_c
    options.add_option_f
    options.add_option_z
    options.add_option_t
    options.add_option_s
    options.parse

    assert_equal '/path/to/config',   options.val(:config_path)
    assert_equal '/path/to/zonefile', options.val(:zonefile_path)
    assert_equal 'zonename.',         options.val(:zonename)
    assert_equal '/path/to/template', options.val(:template_path)
    assert_equal 'stackname',         options.val(:stackname)
  end

  def test_no_option
    args = []

    options = MyOptionParser.new(args)
    options.parse

    assert_equal nil, options.val(:config_path)
    assert_equal nil, options.val(:zonefile_path)
    assert_equal nil, options.val(:zonename)
    assert_equal nil, options.val(:template_path)
    assert_equal nil, options.val(:stackname)
  end

end
