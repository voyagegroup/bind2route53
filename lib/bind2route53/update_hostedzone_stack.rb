require 'rubygems'
require 'json'
require 'aws-sdk'
require 'logger'
require 'pp'

module Bind2Route53
  class UpdateHostedZoneStack
    def initialize(args)
      options = MyOptionParser.new(args)
      options.add_option_c
      options.add_option_t
      options.parse

      config_path   = options.val(:config_path)
      template_path = options.val(:template_path)

      $config = load_config(config_path)

      #AWS.config(:logger => Logger.new($stdout))
      cfm = AWS::CloudFormation.new(
        :access_key_id     => $config[:access_key_id],
        :secret_access_key => $config[:secret_key],
        :region            => $config[:region]
      )

      zonename, new_template = load_template(cfm, template_path)
      resource_name = zonename2resourcename(zonename, "R53")
      stackname     = zonename2stackname(zonename, "R53-")
      cur_template = cfm.stacks[stackname].template

      new_records = JSON.parse(new_template)['Resources'][resource_name]['Properties']["RecordSets"]
      cur_records = JSON.parse(cur_template)['Resources'][resource_name]['Properties']["RecordSets"]

      added_records   = new_records - cur_records
      deleted_records = cur_records - new_records

      if added_records.empty? && deleted_records.empty?
        warn "[Warn][#{$config[:env]}] Template is updated. No need to update stack."
        exit
      end

      puts "[Info][#{$config[:env]}] Record sets diff are below."
      display_records(added_records,   '+')
      display_records(deleted_records, '-')

      confirm("Do you update hosted zone stack?") if $config[:confirm] 
      cfm.stacks[stackname].update(:template => new_template)

      puts "[Info][#{$config[:env]}] Update hosted zone stack start. (#{Time.now.strftime("%Y-%m-%d %H:%M:%S")})"
      unless wait_update_stacke(cfm, stackname, 10)
        puts "[Error][#{$config[:env]}] Update hosted zone stack failed. (#{Time.now.strftime("%Y-%m-%d %H:%M:%S")})"
        exit 1
      end
      puts "[Info][#{$config[:env]}] Update hosted zone stack complete. (#{Time.now.strftime("%Y-%m-%d %H:%M:%S")})"
    end

    def display_records(records, prefix = '+')
      records.each do |r|
        puts "#{prefix} #{r["Name"].ljust(40)} #{r["Type"].ljust(8)} #{r["ResourceRecords"].join(" ")}"
      end
    end

  end
end
