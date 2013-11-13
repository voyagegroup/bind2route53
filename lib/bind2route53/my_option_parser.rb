module Bind2Route53
  class MyOptionParser
    def initialize(args)
      @args       = args
      @options    = Hash.new
      @opt_parser = OptionParser.new
    end

    def add_option_c
      @opt_parser.on('-c val', '--config-file=val', 'Config file.') do |v| 
        @options[:config_path] = v 
      end
    end

    def add_option_f
      @opt_parser.on('-f val', '--zone-file=val', 'Zone file.') do |v| 
        @options[:zonefile_path] = v 
      end
    end

    def add_option_z
      @opt_parser.on('-z val', '--zone-name=val', 'Zone name.') do |v| 
        @options[:zonename] = v.gsub(/\.+$/,'').gsub(/$/, '.')
      end
    end

    def add_option_t
      @opt_parser.on('-t val', '--template-file=val', 'CloudFormation template.') do |v| 
        @options[:template_path] = v 
      end
    end

    def add_option_s
      @opt_parser.on('-s val', '--stack-name=val', 'Stack name for CloudFormation.') do |v| 
        @options[:stackname] = v 
      end
    end


    def parse
      @opt_parser.parse!(@args)
    end

    def val(index)
      @options[index]
    end
  end
end


