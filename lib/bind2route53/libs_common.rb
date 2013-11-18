module Bind2Route53
  def load_config(config_file)
    config_file = "#{$BASE_DIR}config/default.yml" if config_file.nil?
    YAML.load(File.open(config_file))
  end

  def confirm(message)
    loop do
      print "[#{$config[:env]}] #{message} (y/n): "
      input = gets.chomp
      if input == "y"
        break
      end

      if input == "n"
        puts "Canceled."
        exit 0
      end
    end
  end

  def zonename2stackname(zonename, prefix = '')
    prefix + zonename.gsub(/\.$/, '').gsub(/-([0-9])/, '-DASH\0').gsub(/\//, "-SLA-").gsub(/^\w|\.[\w]/){|w|w.upcase}.gsub(/\./, '-')
  end
  
  def zonename2resourcename(zonename, prefix = '')
    prefix + zonename.gsub(/[-\/]/, '').gsub(/^\w|\.[\w]/){|w|w.upcase}.gsub(/\./, '')
  end
end
