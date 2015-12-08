#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/test_helper.rb'
include Bind2Route53

class TestConvertZonefile < Test::Unit::TestCase
  def setup
  end

  def test_zonename
    configfile_path = './config/default.yml'
  
    zonefile_path  = './zonefile_for_test/test_convert_zonefile_zonename.zone'
    zonename       = 'example.com'
    args = ['-f', zonefile_path, '-z', zonename, '-c', configfile_path]
    assert_equal true,  ConvertZonefile.new(args).template_hash["Resources"].include?("R53ExampleCom")

    zonefile_path = './zonefile_for_test/test_convert_zonefile_zonename.zone'
    zonename      = 'example.com.'
    args = ['-f', zonefile_path, '-z', zonename, '-c', configfile_path]
    assert_equal true,  ConvertZonefile.new(args).template_hash["Resources"].include?("R53ExampleCom")

    zonefile_path = './zonefile_for_test/test_convert_zonefile_zonename.zone'
    zonename      = '0/25.example.com.'
    args = ['-f', zonefile_path, '-z', zonename, '-c', configfile_path]
    assert_equal true,  ConvertZonefile.new(args).template_hash["Resources"].include?('R53025ExampleCom')

    zonefile_path = './zonefile_for_test/test_convert_zonefile_zonename.zone'
    zonename      = 'example.com.'
    args = ['-f', zonefile_path, '-z', zonename, '-c', configfile_path]
    assert_equal false,  ConvertZonefile.new(args).template_hash["Resources"].include?("example.com.")
  end

  def test_a_record
    configfile_path = './config/default.yml'
  
    zonename      = 'example.com.'
    resource_name = zonename2resourcename(zonename, 'R53')

    zonefile_path  = './zonefile_for_test/test_convert_zonefile_a_record01.zone'
    args = ['-f', zonefile_path, '-z', zonename, '-c', configfile_path]
    recordsets = ConvertZonefile.new(args).template_hash["Resources"][resource_name]["Properties"]["RecordSets"]
    expects = [{"ResourceRecords"=>["192.168.4.1"], "TTL"=>"600", "Name"=>"example.com.",      "Type"=>"A"},
               {"ResourceRecords"=>["192.168.4.1"], "TTL"=>"100", "Name"=>"test.example.com.", "Type"=>"A"}]
    assert_equal [], expects - recordsets
    assert_equal [], recordsets - expects

    zonefile_path = './zonefile_for_test/test_convert_zonefile_a_record02.zone'
    args = ['-f', zonefile_path, '-z', zonename, '-c', configfile_path]
    recordsets = ConvertZonefile.new(args).template_hash["Resources"][resource_name]["Properties"]["RecordSets"]
    expects = [{"ResourceRecords"=> ["192.168.4.1", "192.168.4.2"], "TTL"=>"900", "Name"=>"example.com.", "Type"=>"A"}]
    assert_equal [], expects - recordsets
    assert_equal [], recordsets - expects
  end

  def test_cname_record
    configfile_path = './config/default.yml'

    zonename      = 'example.com.'
    resource_name = zonename2resourcename(zonename, 'R53')

    zonefile_path = './zonefile_for_test/test_convert_zonefile_cname_record01.zone'
    args = ['-f', zonefile_path, '-z', zonename, '-c', configfile_path]
    recordsets = ConvertZonefile.new(args).template_hash["Resources"][resource_name]["Properties"]["RecordSets"]
    expects = [{"ResourceRecords"=>["192.168.4.1"],       "TTL"=>"700", "Name"=>"test.example.com.",     "Type"=>"A"},
               {"ResourceRecords"=>["test.example.com."], "TTL"=>"700", "Name"=>"cname.example.com.",    "Type"=>"CNAME"},
               {"ResourceRecords"=>["example2.com."],     "TTL"=>"100", "Name"=>"example2.example.com.", "Type"=>"CNAME"},
               {"ResourceRecords"=>["example.com."],      "TTL"=>"700", "Name"=>"www.example.com.",      "Type"=>"CNAME"}]
    assert_equal [], expects - recordsets
    assert_equal [], recordsets - expects
  end

  def test_mx_record
    configfile_path = './config/default.yml'

    zonename      = 'example.com.'
    resource_name = zonename2resourcename(zonename, 'R53')

    zonefile_path = './zonefile_for_test/test_convert_zonefile_mx_record01.zone'
    args = ['-f', zonefile_path, '-z', zonename, '-c', configfile_path]
    recordsets = ConvertZonefile.new(args).template_hash["Resources"][resource_name]["Properties"]["RecordSets"]
    expects = [{"ResourceRecords"=>["192.168.4.1"],           "TTL"=>"900", "Name"=>"mail2.example.com.", "Type"=>"A"},
               {"ResourceRecords"=>["10 mail.other.com."],    "TTL"=>"900", "Name"=>"mail.example.com.", "Type"=>"MX"},
               {"ResourceRecords"=>["10 mail2.example.com."], "TTL"=>"900", "Name"=>"org.example.com.",  "Type"=>"MX"}]
    assert_equal [], expects - recordsets
    assert_equal [], recordsets - expects
  end

  def test_txt_record
    configfile_path = './config/default.yml'

    zonename      = 'example.com.'
    resource_name = zonename2resourcename(zonename, 'R53')

    zonefile_path = './zonefile_for_test/test_convert_zonefile_txt_record01.zone'
    args = ['-f', zonefile_path, '-z', zonename, '-c', configfile_path]
    recordsets = ConvertZonefile.new(args).template_hash["Resources"][resource_name]["Properties"]["RecordSets"]
    expects = [{"ResourceRecords"=>["\"v=spf1 +ip4:192.168.4.0/24 +ip4:10.0.0.0/24 ~all\""], "TTL"=>"900", "Name"=>"spf.example.com.",  "Type"=>"TXT"},
               {"ResourceRecords"=>["\"KdeSEn375EyXno10f2izhAp04ENSXW0LitQBYKJAG/c=\""],     "TTL"=>"100", "Name"=>"spf2.example.com.", "Type"=>"TXT"},
               {"ResourceRecords"=>["\"txt-test-1\" \"txt-test-2\""],                        "TTL"=>"900", "Name"=>"spf3.example.com.", "Type"=>"TXT"},
               {"ResourceRecords"=>["\"txt-test-1\"", "\"txt-test-2\""],                     "TTL"=>"900", "Name"=>"spf4.example.com.", "Type"=>"TXT"}]
    assert_equal [], expects - recordsets
    assert_equal [], recordsets - expects
  end

  def test_ptr_record
    configfile_path = './config/default.yml'

    zonename      = '4.168.192.in-addr.arpa.'
    resource_name = zonename2resourcename(zonename, 'R53')

    zonefile_path = './zonefile_for_test/test_convert_zonefile_ptr_record01.zone'
    args = ['-f', zonefile_path, '-z', zonename, '-c', configfile_path]
    recordsets = ConvertZonefile.new(args).template_hash["Resources"][resource_name]["Properties"]["RecordSets"]
    expects = [{"ResourceRecords"=>["test10.example.com."], "TTL"=>"900", "Name"=>"10.4.168.192.in-addr.arpa.", "Type"=>"PTR"},
               {"ResourceRecords"=>["test20.example.com."], "TTL"=>"100", "Name"=>"20.4.168.192.in-addr.arpa.", "Type"=>"PTR"}]
    assert_equal [], expects - recordsets
    assert_equal [], recordsets - expects

    zonename      = '0/25.4.168.192.in-addr.arpa.'
    resource_name = zonename2resourcename(zonename, 'R53')

    zonefile_path = './zonefile_for_test/test_convert_zonefile_ptr_record02.zone'
    args = ['-f', zonefile_path, '-z', zonename, '-c', configfile_path]
    hosted_zonename = ConvertZonefile.new(args).template_hash["Resources"][resource_name]["Properties"]["HostedZoneName"]
    assert_equal '0\05725.4.168.192.in-addr.arpa.', hosted_zonename
  end

  def test_ns_record
    configfile_path = './config/default.yml'

    zonename      = 'example.com.'
    resource_name = zonename2resourcename(zonename, 'R53')

    zonefile_path  = './zonefile_for_test/test_convert_zonefile_ns_record01.zone'
    args = ['-f', zonefile_path, '-z', zonename, '-c', configfile_path]
    recordsets = ConvertZonefile.new(args).template_hash["Resources"][resource_name]["Properties"]["RecordSets"]
    expects = [{"ResourceRecords"=>["ns-test1-1.example.com.", "ns-test1-2.example.com."], "TTL"=>"900", "Name"=>"ns-test1.example.com.", "Type"=>"NS"},
               {"ResourceRecords"=>["ns-test2-1.example.com.", "ns-test2-2.example.com."], "TTL"=>"200", "Name"=>"ns-test2.example.com.", "Type"=>"NS"}]
    assert_equal [], expects - recordsets
    assert_equal [], recordsets - expects
  end

  def test_srv_record
    configfile_path = './config/default.yml'

    zonename      = 'example.com.'
    resource_name = zonename2resourcename(zonename, 'R53')

    zonefile_path  = './zonefile_for_test/test_convert_zonefile_srv_record01.zone'
    args = ['-f', zonefile_path, '-z', zonename, '-c', configfile_path]
    recordsets = ConvertZonefile.new(args).template_hash["Resources"][resource_name]["Properties"]["RecordSets"]

    expects = [{"ResourceRecords"=>["1 0 21 example.com."], "TTL"=>"600", "Name"=>"test-srv.example.com.", "Type"=>"SRV"},
               {"ResourceRecords"=>["1 0 21 test2-a.example.com.", "2 0 22 test2-a.example.com."], "TTL"=>"600", "Name"=>"test2-srv.example.com.", "Type"=>"SRV"}]
    assert_equal [], expects - recordsets
    assert_equal [], recordsets - expects
  end

  def test_aws_specific
    configfile_path = './config/default.yml'

    zonename      = 'example.com.'
    resource_name = zonename2resourcename(zonename, 'R53')

    zonefile_path  = './zonefile_for_test/test_convert_zonefile_aws_specific.zone'
    args = ['-f', zonefile_path, '-z', zonename, '-c', configfile_path]
    recordsets = ConvertZonefile.new(args).template_hash["Resources"][resource_name]["Properties"]["RecordSets"]
    expects = [
      {"ResourceRecords"=>["192.168.4.1"], "TTL"=>"900", "Name"=>"test.example.com.", "Type"=>"A"},
      {
        "ResourceRecords" => [], 
        "Name" => "example.com.",
        "AliasTarget" => {
          "HostedZoneId" => "ABCDEFGHIJKLMN",
          "DNSName"      => "aliastest-123456789.ap-northeast-1.elb.amazonaws.com."
        },
        "Type" => "A"
      }, {
        "ResourceRecords" => [], 
        "Name" => "aliastest1.example.com.",
        "AliasTarget" => {
          "HostedZoneId" => "ABCDEFGHIJKLMN",
          "DNSName"      => "aliastest1-123456789.ap-northeast-1.elb.amazonaws.com."
        },
        "Type" => "A"
      }, {
        "ResourceRecords" => [], 
        "Name" => "alias-test2.example.com.",
        "AliasTarget" => {
          "HostedZoneId" => "ABCDEFGHIJKLMN",
          "DNSName"      => "alias-test2-123456789.ap-northeast-1.elb.amazonaws.com."
        },
        "Type" => "A"
      }, {
        "ResourceRecords" => [], 
        "Name" => "aliastest3.example.com.",
        "AliasTarget" => {
          "HostedZoneId" => "ABCDEFGHIJKLMN",
          "DNSName"      => "aliastest3-123456789.ap-northeast-1.elb.amazonaws.com."
        },
        "Type" => "A"
      }, {
        "ResourceRecords" => [], 
        "Name" => "10.example.com.",
        "AliasTarget" => {
          "HostedZoneId" => "ABCDEFGHIJKLMN",
          "DNSName"      => "10-123456789.ap-northeast-1.elb.amazonaws.com."
        },
        "Type" => "A"
      }, {
        "ResourceRecords" => [], 
        "Name" => "20.example.com.",
        "AliasTarget" => {
          "HostedZoneId" => "ABCDEFGHIJKLMN",
          "DNSName"      => "20-123456789.ap-northeast-1.elb.amazonaws.com."
        },
        "Type" => "A"
      }, {
        "ResourceRecords" => [], 
        "Name" => "example.com.",
        "AliasTarget" => {
          "HostedZoneId" => "ABCDEFGHIJKLMN",
          "DNSName"      => "30-123456789.ap-northeast-1.elb.amazonaws.com."
        },
        "Type" => "A"
      }, {
        "ResourceRecords" => ["192.168.4.1"],
        "TTL"             => "300",
        "SetIdentifier"    => "Test for weighted policy 10.",
        "Name"            => "policytest-weighted.example.com.",
        "Weight"          => "10",
        "Type"            => "A"
      }, {
        "ResourceRecords" => ["192.168.4.2"],
          "TTL"           => "300",
          "SetIdentifier"  => "Test for weighted policy 3",
          "Name"          => "policytest-weighted.example.com.",
          "Weight"        => "3",
          "Type"          => "A"
      }, {
        "ResourceRecords" => ["192.168.5.1"],
        "TTL"             => "900",
        "SetIdentifier"    => "weighted_a.example.com. to 192.168.5.1 weight 100",
        "Name"            => "weighted_a.example.com.",
        "Weight"          => "100",
        "Type"            => "A"
      }, {
        "ResourceRecords" => ["192.168.5.2"],
        "TTL"             => "900",
        "SetIdentifier"    => "weighted_a.example.com. to 192.168.5.2 weight 200",
        "Name"            => "weighted_a.example.com.",
        "Weight"          => "200",
        "Type"            => "A"
      }, {
        "ResourceRecords" => ["cnametest.example.com."],
        "TTL"             => "900",
        "SetIdentifier"    => "weighted_cname.example.com. to cnametest.example.com. weight 100",
        "Name"            => "weighted_cname.example.com.",
        "Weight"          => "100",
        "Type"            => "CNAME"
      }, {
        "ResourceRecords" => ["cnametest.example2.com."],
        "TTL"             => "900",
        "SetIdentifier"    => "weighted_cname.example.com. to cnametest.example2.com. weight 200",
        "Name"            => "weighted_cname.example.com.",
        "Weight"          => "200",
        "Type"            => "CNAME"
      } 
    ]

    assert_equal [], expects - recordsets
    assert_equal [], recordsets - expects
  end

  def test_additional_resources
    configfile_path = './config/default.yml'

    zonename      = 'example.com.'

    zonefile_path  = './zonefile_for_test/test_convert_zonefile_additional_resources.zone'
    args = ['-f', zonefile_path, '-z', zonename, '-c', configfile_path]
    results = ConvertZonefile.new(args).template_hash["Resources"]["R53HCExampleCom"]

    expects = {
      "Type"       => "AWS::Route53::HealthCheck",
      "Properties" => {
        "HealthCheckConfig"=> {
          "Port"=>"80",
          "Type"=>"HTTP",
          "ResourcePath"=>"/",
          "FullyQualifiedDomainName"=>"example.com",
          "RequestInterval"=>"30",
          "FailureThreshold"=>"3"
        }
      }
    }

    assert_equal [], expects.to_a - results.to_a
    assert_equal [], results.to_a - expects.to_a
  end
end

