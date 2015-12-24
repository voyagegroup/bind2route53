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

      $config  = load_config(config_path)

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

      $logfile = $config[:logdir].nil? ? nil : "#{$config[:logdir]}/#{$config[:env]}-#{zonename.gsub(/\//, '\\\057')}log"
      $logger  = MyLogger.new($logfile)

      added_records, deleted_records = diff_records(JSON.parse(new_template), JSON.parse(cur_template), resource_name)
      added_resources, deleted_resources = diff_other_resources(JSON.parse(new_template), JSON.parse(cur_template))

      if added_records.empty? && deleted_records.empty? && added_resources.empty? && deleted_resources.empty?
        $logger.warn "[Warn][#{$config[:env]}] Template is updated. No need to update stack."
        exit
      end

      $logger.info "[Info][#{$config[:env]}] Diff are below."
      display_records(added_records,   '+')
      display_records(deleted_records, '-')
      display_resources(added_resources,   '+')
      display_resources(deleted_resources, '-')

      confirm("Do you update hosted zone stack?") if $config[:confirm] 
      cfm.stacks[stackname].update(:template => new_template)

      $logger.info "[Info][#{$config[:env]}] Update hosted zone stack start. (#{Time.now.strftime("%Y-%m-%d %H:%M:%S")})"
      unless wait_update_stacke(cfm, stackname, 10)
        $logger.error "[Error][#{$config[:env]}] Update hosted zone stack failed. (#{Time.now.strftime("%Y-%m-%d %H:%M:%S")})"
        exit 1
      end
      $logger.info "[Info][#{$config[:env]}] Update hosted zone stack complete. (#{Time.now.strftime("%Y-%m-%d %H:%M:%S")})"
    end

    def display_records(records, prefix = '+')
      records.each do |r|
        $logger.info "#{prefix} #{r["Name"].ljust(40)} #{r["Type"].ljust(8)} #{r["ResourceRecords"].join(" ")}"
      end
    end

    def display_resources(resources, prefix = '+')
      resources.each do |r|
        $logger.info "#{prefix} #{r.to_s}"
      end
    end

  end
end
