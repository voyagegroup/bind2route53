require 'rubygems'
require 'json'
require 'aws-sdk'
require 'logger'
require 'pp'

module Bind2Route53
  class CreateHostedZone
    def initialize(args)
      options = MyOptionParser.new(args)
      options.add_option_c
      options.add_option_z
      options.parse

      config_path = options.val(:config_path)
      zonename    = options.val(:zonename)
      $config     = load_config(config_path)
      $logfile    = $config[:logdir].nil? ? nil : "#{$config[:logdir]}/#{$config[:env]}-#{zonename}.log" 
      $logger     = MyLogger.new($logfile)

      #AWS.config(:logger => Logger.new($stdout))
      r53 = AWS::Route53.new(
        :access_key_id     => $config[:access_key_id],
        :secret_access_key => $config[:secret_key],
        :region            => $config[:region]
      )

      check_hosted_zone(r53, zonename)
      confirm("Do you create hosted zone?") if $config[:confirm] 
      create_hosted_zone(r53, zonename)
      $logger.info "[Info][#{$config[:env]}] Created hosted Zone."
    end
  end

  def check_hosted_zone(r53, zonename)
    unless r53.client.list_hosted_zones[:hosted_zones].find {|z| z[:name] =~ /#{zonename}\.?/}.nil?
      $logger.warn "[Warn][#{$config[:env]}] Hosted zone already exists. Skip to create hosted zone."
      exit 1
    end
  end

  def create_hosted_zone(r53, zonename)
    begin 
      r53.hosted_zones.create(zonename)
    rescue => ex
      $logger.error "[Error][#{$config[:env]}] Create hosted zone failed."
      $logger.error "[Error][#{$config[:env]}] #{ex.message}"
      exit 1
    end
  end
end
