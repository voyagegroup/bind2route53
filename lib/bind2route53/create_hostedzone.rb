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

      #AWS.config(:logger => Logger.new($stdout))
      r53 = AWS::Route53.new(
        :access_key_id     => $config[:access_key_id],
        :secret_access_key => $config[:secret_key],
        :region            => $config[:region]
      )

      check_hosted_zone(r53, zonename)
      confirm("Do you create hosted zone?") if $config[:confirm] 
      create_hosted_zone(r53, zonename)
      puts "[Info][#{$config[:env]}] Created hosted Zone."
    end
  end

  def check_hosted_zone(r53, zonename)
    unless r53.client.list_hosted_zones[:hosted_zones].find {|z| z[:name] =~ /#{zonename}\.?/}.nil?
      warn "[Warn][#{$config[:env]}] Hosted zone already exists. Skip to create hosted zone."
      exit 1
    end
  end

  def create_hosted_zone(r53, zonename)
    begin 
      r53.hosted_zones.create(zonename)
    rescue => ex
      warn "[Error][#{$config[:env]}] Create hosted zone failed."
      warn "[Error][#{$config[:env]}] #{ex.message}"
      exit 1
    end
  end
end
