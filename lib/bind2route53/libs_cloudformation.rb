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
    if count_record_set_group(template_parsed) > 1
      warn "[Error][#{$config[:env]}] There is multiple RecordSetGroup in template."
      exit 1
    end

    zonename  = find_zonename_from_template(template_parsed)
    return zonename, template
  end

  def find_zonename_from_template(template_parsed)
    template_parsed["Resources"].shift[1]["Properties"]["HostedZoneName"]
  end

  def count_record_set_group(template_parsed)
    template_parsed["Resources"].select { |k, r| r["Type"] == 'AWS::Route53::RecordSetGroup' }.size
  end

  def diff_records(new_template_parsed, cur_template_parsed, resource_name)
    new_records = new_template_parsed['Resources'][resource_name]['Properties']["RecordSets"]
    cur_records = cur_template_parsed['Resources'][resource_name]['Properties']["RecordSets"]

    added_records   = new_records - cur_records
    deleted_records = cur_records - new_records

    return added_records, deleted_records
  end

  def diff_other_resources(new_template_parsed, cur_template_parsed)
    new_resources = new_template_parsed['Resources'].to_a
    cur_resources = cur_template_parsed['Resources'].to_a

    added_resources   = Hash[(new_resources - cur_resources)]
    deleted_resources = Hash[(cur_resources - new_resources)]

    added_resources.reject! {|key, val| val["Type"] == 'AWS::Route53::RecordSetGroup' }
    deleted_resources.reject! {|key, val| val["Type"] == 'AWS::Route53::RecordSetGroup' }

    return added_resources, deleted_resources
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

