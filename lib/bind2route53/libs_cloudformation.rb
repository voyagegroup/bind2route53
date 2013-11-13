module Bind2Route53
  def load_template(cfm, template_path)
    unless File.exists?(template_path)
      warn "[Error][#{$config[:env]}] Template file doesn't exists."
      exit 1
    end
    template = File.open(template_path).read

    validate = cfm.validate_template(template)
    if validate.include?(:message) &&  validate.include?(:code)
      warn "[Error][#{$config[:env]}] Invalid template was specified."
      warn "[Error][#{$config[:env]}] Code:    #{validate[:code]}"
      warn "[Error][#{$config[:env]}] Message: #{validate[:message]}"
      exit 1
    end

    template_parsed = JSON.parse(template)
    if template_parsed["Resources"].length > 1
      warn "[Error][#{$config[:env]}] There is multiple Resource name in template."
      exit 1
    end

    zonename  = find_zonename_from_template(template_parsed)
    return zonename, template
  end

  def find_zonename_from_template(template_parsed)
    template_parsed["Resources"].shift[1]["Properties"]["HostedZoneName"]
  end

  def wait_update_stacke(cfm, stackname, interval = 10)
      30.times do |t|
        status = cfm.stacks[stackname].status
        return true  if status == 'CREATE_COMPLETE'
        return true  if status == 'UPDATE_COMPLETE'
        return false if status == 'ROLLBACK_COMPLETE'
        return false if status == 'UPDATE_ROLLBACK_COMPLETE'
        puts "[Info][#{$config[:env]}] Updating... (status: #{status})"
        sleep interval
      end
      return false
  end
end

