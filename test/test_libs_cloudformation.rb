#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/test_helper.rb'
include Bind2Route53

class TestLibsCloudFormation < Test::Unit::TestCase
  def setup
  end

  def read_and_parse(template_path)
    template_parsed = JSON.parse(File.open(template_path).read)
  end

  def test_find_zonename_from_template
    assert_equal('example.com.', find_zonename_from_template(read_and_parse('./template_for_test/test_find_zonename_from_template_01.template')))
  end

  def test_count_record_set_group
    assert_equal(1, count_record_set_group(read_and_parse('./template_for_test/test_count_record_set_group_01.template')))
    assert_equal(2, count_record_set_group(read_and_parse('./template_for_test/test_count_record_set_group_02.template')))
    assert_equal(0, count_record_set_group(read_and_parse('./template_for_test/test_count_record_set_group_03.template')))
  end

  def test_diff_records
    template_parsed_a = read_and_parse('./template_for_test/test_diff_records_01a.template')
    template_parsed_b = read_and_parse('./template_for_test/test_diff_records_01b.template')
    expect = [[{ "Name" => "example.com", "ResourceRecords" => ["192.168.4.1"], "TTL" => "60", "Type" => "A" }],
              [{ "Name" => "example.com", "ResourceRecords" => ["192.168.4.2"], "TTL" => "60", "Type" => "A" }]]
    assert_equal(expect, diff_records(template_parsed_a, template_parsed_b, 'R53Example1Com'))


    template_parsed_a = read_and_parse('./template_for_test/test_diff_records_02a.template')
    template_parsed_b = read_and_parse('./template_for_test/test_diff_records_02b.template')
    expect = [[], []]
    assert_equal(expect, diff_records(template_parsed_a, template_parsed_b, 'R53Example1Com'))
  end

  def test_diff_other_resources
    template_parsed_a = read_and_parse('./template_for_test/test_diff_resources_01a.template')
    template_parsed_b = read_and_parse('./template_for_test/test_diff_resources_01b.template')
    expect = [{}, {}]
    assert_equal(expect, diff_other_resources(template_parsed_a, template_parsed_b))

    template_parsed_a = read_and_parse('./template_for_test/test_diff_resources_02a.template')
    template_parsed_b = read_and_parse('./template_for_test/test_diff_resources_02b.template')

    expect = [{
      "R53HCExampleCom" => {
        "Properties"=> {
          "HealthCheckConfig" => {
            "FailureThreshold"          => "5",
            "FullyQualifiedDomainName"  => "example.com",
            "Port"                      => "443",
            "RequestInterval"           => "30",
            "ResourcePath"              => "/",
            "Type"                      => "HTTPS"
          }
        },
        "Type"=>"AWS::Route53::HealthCheck" 
      }}, { 
      "R53HCExampleCom" => {
        "Properties" => {
           "HealthCheckConfig" => {
             "FailureThreshold"         => "3",
             "FullyQualifiedDomainName" => "example.com",
             "Port"                     => "443",
             "RequestInterval"          => "30",
             "ResourcePath"             => "/",
             "Type"                     => "HTTPS"
           }
        },
        "Type"=>"AWS::Route53::HealthCheck"
    }}]
    assert_equal(expect, diff_other_resources(template_parsed_a, template_parsed_b))
  end
end
