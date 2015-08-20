require 'rubygems'
require 'optparse'
require 'zonefile'
require 'json'
require 'pp'

module Bind2Route53
  class ConvertZonefile
    def initialize(args)

      options = MyOptionParser.new(args)
      options.add_option_c
      options.add_option_f
      options.add_option_z
      options.parse

      config_path    = options.val(:config_path)
      zonefile_path  = options.val(:zonefile_path)
      zonename       = options.val(:zonename)
      zonefile_name  = File.basename(zonefile_path)
      type           = zonefile_name.scan(/^.*\.(zone|rev)$/).flatten[0]
      resources_neme = zonename2resourcename(zonename, 'R53')

      $config  = load_config(config_path)
      $logfile = $config[:logdir].nil? ? nil : "#{$config[:logdir]}/#{$config[:env]}-#{zonename.gsub(/\//, '\\\057')}log"
      $logger  = MyLogger.new($logfile)

      zf = Zonefile.from_file(zonefile_path)
      if zf.empty?
        $logger.error "[Error][#{$config[:env]}] You specified invalid zone file." 
        exit 1
      end

      @template = {
        "AWSTemplateFormatVersion" => "2010-09-09",
        "Resources" => {
          "#{resources_neme}" => {
            "Type" => "AWS::Route53::RecordSetGroup",
            "Properties" => {
              "HostedZoneName" => "#{zonename.gsub(/\//, '\\\057')}",
              "RecordSets"     => []
            }
          }
        }
      }

      @default_ttl = zf.ttl
      
      zf.records.each do |record_type, records|
        supported_records_type = [:a, :txt, :cname, :mx, :ptr, :ns, :srv]
        ignore_records_type    = [:soa]
      
        next if records.empty? || ignore_records_type.include?(record_type)
      
        if !supported_records_type.include?(record_type)
          $logger.warn "[Warn][#{$config[:env]}] unsupported record type exists! (#{record_type})"
          next
        end
      
        record_sets = self.send("parse_records_#{record_type.to_s}", zonename, records)
        @template["Resources"]["#{resources_neme}"]["Properties"]["RecordSets"] += record_sets
      end

      zonefile = File.read(zonefile_path)
      @template["Resources"]["#{resources_neme}"]["Properties"]["RecordSets"] += parse_records_alias(zonename, zonefile)

      aws_specific = zonefile.scan(/^; AWS SPECIFIC BEGIN\n(.*); AWS SPECIFIC END$/m).flatten[0]
      if aws_specific
        @template["Resources"]["#{resources_neme}"]["Properties"]["RecordSets"] += JSON.parse(aws_specific.gsub(/^;/, ''))
      end
      @template
    end

    def parse_records_a(zonename, records)
      record_sets = []
    
      records.each do |record| 
        ttl_a  = record[:ttl] || @default_ttl
        name_a = zonename
        name_a = "#{record[:name]}.#{zonename}" unless record[:name].nil?

        weight_info = record[:host].scan(/(.*)@WEIGHT(\d+)/).flatten
        unless weight_info.empty?
          record[:host]   = weight_info[0]
          record[:weight] = weight_info[1]
        end

        if !record_sets.select {|r| r["Name"] == "#{name_a}" }.empty? && weight_info.empty?
           record_sets.select {|r| r["Name"] == "#{name_a}" }[0]["ResourceRecords"] << record[:host]
           next
        end
    
        record_set = {
          "Name" => name_a,
          "Type" => "A",
          "TTL"  => "#{ttl_a}",
          "ResourceRecords" => [record[:host]]
        }

        unless weight_info.empty?
          record_set["SetIdentifier"] = "#{name_a} to #{record[:host]} weight #{record[:weight]}"
          record_set["Weight"]       = "#{record[:weight]}"
        end

        record_sets << record_set
      end
    
      record_sets
    end
  
    def parse_records_cname(zonename, records)
      record_sets = []
    
      records.each do |record| 
        ttl_cname  = record[:ttl] || @default_ttl
        name_cname = zonename
        name_cname = "#{record[:name]}.#{zonename}" unless record[:name].nil?

        weight_info = record[:host].scan(/(.*)@WEIGHT(\d+)/).flatten
        unless weight_info.empty?
          record[:host]   = weight_info[0]
          record[:weight] = weight_info[1]
        end
        
        record[:host] = "#{zonename}"                  if     record[:host] == '@'
        record[:host] = "#{record[:host]}.#{zonename}" unless record[:host] =~ /\.$/
    
        record_set = {
          "Name" => name_cname,
          "Type" => "CNAME",
          "TTL"  => "#{ttl_cname}",
          "ResourceRecords" => [record[:host]]
        }

        unless weight_info.empty?
          record_set["SetIdentifier"] = "#{name_cname} to #{record[:host]} weight #{record[:weight]}"
          record_set["Weight"]       = "#{record[:weight]}"
        end

        record_sets << record_set
      end
    
      record_sets
    end
  
    def parse_records_mx(zonename, records)
      record_sets = []
    
      records.each do |record| 
        ttl_mx  = record[:ttl] || @default_ttl
        name_mx = zonename
        name_mx = "#{record[:name]}.#{zonename}" unless record[:name].nil?
  
        record[:host] = record[:pri].to_s + " " + record[:host] unless record[:pri].nil?
        record[:host] = "#{record[:host]}.#{zonename}"          unless record[:host] =~ /\.$/
  
        unless record_sets.select {|r| r["Name"] == "#{name_mx}" }.empty?
           record_sets.select {|r| r["Name"] == "#{name_mx}" }[0]["ResourceRecords"] << record[:host]
           next
        end
  
        record_set = {
          "Name" => name_mx,
          "Type" => "MX",
          "TTL"  => "#{ttl_mx}",
          "ResourceRecords" => [record[:host]]
        }
        record_sets << record_set
      end
    
      record_sets
    end
  
    def parse_records_txt(zonename, records)
      record_sets = []
    
      records.each do |record| 
        ttl_txt  = record[:ttl] || @default_ttl
        name_txt = zonename
        name_txt = "#{record[:name]}.#{zonename}" unless record[:name].nil?
  
        unless record_sets.select {|r| r["Name"] == "#{name_txt}" }.empty?
           record_sets.select {|r| r["Name"] == "#{name_txt}" }[0]["ResourceRecords"] << record[:text]
           next
        end
  
        record_set = {
          "Name" => name_txt,
          "Type" => "TXT",
          "TTL"  => "#{ttl_txt}",
          "ResourceRecords" => [record[:text]]
        }
        record_sets << record_set
      end
    
      record_sets
    end
  
    def parse_records_ptr(zonename, records)
      record_sets = []
    
      records.each do |record| 
        ttl_ptr  = record[:ttl] || @default_ttl
        name_ptr = zonename
        name_ptr = "#{record[:name]}.#{zonename}" unless record[:name].nil?
  
        record_set = {
          "Name" => name_ptr,
          "Type" => "PTR",
          "TTL"  => "#{ttl_ptr}",
          "ResourceRecords" => [record[:host]]
        }
        record_sets << record_set
      end
    
      record_sets
    end

    def parse_records_ns(zonename, records)
      record_sets = []
    
      records.each do |record| 
        ttl_ns  = record[:ttl] || @default_ttl
        name_ns = zonename
        next if record[:name].nil?
        name_ns = "#{record[:name]}.#{zonename}"
    
        unless record_sets.select {|r| r["Name"] == "#{name_ns}" }.empty?
           record_sets.select {|r| r["Name"] == "#{name_ns}" }[0]["ResourceRecords"] << record[:host]
           next
        end
    
        record_set = {
          "Name" => name_ns,
          "Type" => "NS",
          "TTL"  => "#{ttl_ns}",
          "ResourceRecords" => [record[:host]]
        }
        record_sets << record_set
      end

      record_sets
    end

    def parse_records_srv(zonename, records)
      record_sets = []

      records.each do |record|
        ttl_srv  = record[:ttl] || @default_ttl
        name_srv = zonename
        name_srv = "#{record[:name]}.#{zonename}" unless record[:name].nil?

        record[:host] = record[:pri].to_s + " " + record[:weight] + " " + record[:port] + " " + record[:host]
        record[:host] = "#{record[:host]}.#{zonename}"          unless record[:host] =~ /\.$/

        unless record_sets.select {|r| r["Name"] == "#{name_srv}" }.empty?
           record_sets.select {|r| r["Name"] == "#{name_srv}" }[0]["ResourceRecords"] << record[:host]
           next
        end

        record_set = {
          "Name" => name_srv,
          "Type" => "SRV",
          "TTL"  => "#{ttl_srv}",
          "ResourceRecords" => [record[:host]]
        }
        record_sets << record_set
      end

      record_sets
    end

    def parse_records_alias(zonename, zonefile)
      record_sets = []

      zonefile_alias = zonefile.split("\n").select{|l| l =~ /IN\s+ALIAS/ }
      return record_sets if zonefile_alias.empty?
      alias_records = zonefile_alias.map{|l| l.scan(/^([\w\-\.]*)[ \t]+(\d*[wdhms]?)[ \t]*IN\s+ALIAS\s+(.*?)_(.*\.)[\s;]*/).flatten}
      alias_records.each do |record|
        name_alias = zonename
        name_alias = "#{record[0]}.#{zonename}" unless record[0].empty?

        record_set = {
          "Name" => name_alias,
          "Type" => "A",
          "ResourceRecords" => [],
          "AliasTarget" => {
              "HostedZoneId" => record[2],
              "DNSName"      => record[3]
          }
        }
        record_sets << record_set
      end
      return record_sets
    end

    def template_json
      JSON.pretty_generate(@template)
    end

    def template_hash
      @template
    end
  end
end
