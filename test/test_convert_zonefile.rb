#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/test_helper.rb'
include Bind2Route53

class TestConvertZonefile < Test::Unit::TestCase
  def setup
  end

  def test_zonename
    zonefile_path  = './zonefile_for_test/test_convert_zonefile_zonename.zone'
    zonename       = 'example.com'
    args = ['-f', zonefile_path, '-z', zonename]
    assert_equal true,  ConvertZonefile.new(args).template_hash["Resources"].include?("R53ExampleCom")

    zonefile_path = './zonefile_for_test/test_convert_zonefile_zonename.zone'
    zonename      = 'example.com.'
    args = ['-f', zonefile_path, '-z', zonename]
    assert_equal true,  ConvertZonefile.new(args).template_hash["Resources"].include?("R53ExampleCom")

    zonefile_path = './zonefile_for_test/test_convert_zonefile_zonename.zone'
    zonename      = 'example.com.'
    args = ['-f', zonefile_path, '-z', zonename]
    assert_equal false,  ConvertZonefile.new(args).template_hash["Resources"].include?("example.com.")
  end

  def test_a_record
    zonename      = 'example.com.'
    resource_name = zonename2resourcename(zonename, 'R53')

    zonefile_path  = './zonefile_for_test/test_convert_zonefile_a_record01.zone'
    args = ['-f', zonefile_path, '-z', zonename]
    recordsets = ConvertZonefile.new(args).template_hash["Resources"][resource_name]["Properties"]["RecordSets"]
    expects = [{"ResourceRecords"=>["192.168.4.1"], "TTL"=>"900", "Name"=>"example.com.",      "Type"=>"A"},
               {"ResourceRecords"=>["192.168.4.1"], "TTL"=>"100", "Name"=>"test.example.com.", "Type"=>"A"}]
    assert_equal [], expects - recordsets
    assert_equal [], recordsets - expects

    zonefile_path = './zonefile_for_test/test_convert_zonefile_a_record02.zone'
    args = ['-f', zonefile_path, '-z', zonename]
    recordsets = ConvertZonefile.new(args).template_hash["Resources"][resource_name]["Properties"]["RecordSets"]
    expects = [{"ResourceRecords"=> ["192.168.4.1", "192.168.4.2"], "TTL"=>"900", "Name"=>"example.com.", "Type"=>"A"}]
    assert_equal [], expects - recordsets
    assert_equal [], recordsets - expects
  end

  def test_cname_record
    zonename      = 'example.com.'
    resource_name = zonename2resourcename(zonename, 'R53')

    zonefile_path = './zonefile_for_test/test_convert_zonefile_cname_record01.zone'
    args = ['-f', zonefile_path, '-z', zonename]
    recordsets = ConvertZonefile.new(args).template_hash["Resources"][resource_name]["Properties"]["RecordSets"]
    expects = [{"ResourceRecords"=>["192.168.4.1"],       "TTL"=>"900", "Name"=>"test.example.com.",     "Type"=>"A"},
               {"ResourceRecords"=>["test.example.com."], "TTL"=>"900", "Name"=>"cname.example.com.",    "Type"=>"CNAME"},
               {"ResourceRecords"=>["example2.com."],     "TTL"=>"100", "Name"=>"example2.example.com.", "Type"=>"CNAME"},
               {"ResourceRecords"=>["example.com."],      "TTL"=>"900", "Name"=>"www.example.com.",      "Type"=>"CNAME"}]
    assert_equal [], expects - recordsets
    assert_equal [], recordsets - expects
  end

  def test_mx_record
    zonename      = 'example.com.'
    resource_name = zonename2resourcename(zonename, 'R53')

    zonefile_path = './zonefile_for_test/test_convert_zonefile_mx_record01.zone'
    args = ['-f', zonefile_path, '-z', zonename]
    recordsets = ConvertZonefile.new(args).template_hash["Resources"][resource_name]["Properties"]["RecordSets"]
    expects = [{"ResourceRecords"=>["192.168.4.1"],          "TTL"=>"900", "Name"=>"mail.example.com.", "Type"=>"A"},
               {"ResourceRecords"=>["10 mail.example.com."], "TTL"=>"900", "Name"=>"mail.example.com.", "Type"=>"MX"}]
    assert_equal [], expects - recordsets
    assert_equal [], recordsets - expects
  end

  def test_txt_record
    zonename      = 'example.com.'
    resource_name = zonename2resourcename(zonename, 'R53')

    zonefile_path = './zonefile_for_test/test_convert_zonefile_txt_record01.zone'
    args = ['-f', zonefile_path, '-z', zonename]
    recordsets = ConvertZonefile.new(args).template_hash["Resources"][resource_name]["Properties"]["RecordSets"]
    expects = [{"ResourceRecords"=>["\"v=spf1 +ip4:192.168.4.0/24 +ip4:10.0.0.0/24 ~all\""], "TTL"=>"900", "Name"=>"spf.example.com.",  "Type"=>"TXT"},
               {"ResourceRecords"=>["\"KdeSEn375EyXno10f2izhAp04ENSXW0LitQBYKJAG/c=\""],     "TTL"=>"100", "Name"=>"spf2.example.com.", "Type"=>"TXT"}]
    assert_equal [], expects - recordsets
    assert_equal [], recordsets - expects
  end

  def test_ptr_record
    zonename      = '4.168.192.in-addr.arpa.'
    resource_name = zonename2resourcename(zonename, 'R53')

    zonefile_path = './zonefile_for_test/test_convert_zonefile_ptr_record01.zone'
    args = ['-f', zonefile_path, '-z', zonename]
    recordsets = ConvertZonefile.new(args).template_hash["Resources"][resource_name]["Properties"]["RecordSets"]
    expects = [{"ResourceRecords"=>["test10.example.com."], "TTL"=>"900", "Name"=>"10.4.168.192.in-addr.arpa.", "Type"=>"PTR"},
               {"ResourceRecords"=>["test20.example.com."], "TTL"=>"100", "Name"=>"20.4.168.192.in-addr.arpa.", "Type"=>"PTR"}]
    assert_equal [], expects - recordsets
    assert_equal [], recordsets - expects
  end

  def test_ns_record
    zonename      = 'example.com.'
    resource_name = zonename2resourcename(zonename, 'R53')

    zonefile_path  = './zonefile_for_test/test_convert_zonefile_ns_record01.zone'
    args = ['-f', zonefile_path, '-z', zonename]
    recordsets = ConvertZonefile.new(args).template_hash["Resources"][resource_name]["Properties"]["RecordSets"]
    expects = [{"ResourceRecords"=>["ns-test1-1.example.com.", "ns-test1-2.example.com."], "TTL"=>"900", "Name"=>"ns-test1.example.com.", "Type"=>"NS"},
               {"ResourceRecords"=>["ns-test2-1.example.com.", "ns-test2-2.example.com."], "TTL"=>"200", "Name"=>"ns-test2.example.com.", "Type"=>"NS"}]
    assert_equal [], expects - recordsets
    assert_equal [], recordsets - expects

  end
end






