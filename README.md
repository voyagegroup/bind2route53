bind2route53
============

Management tool for Route 53 with bind zone file.

## Setup
### 1. Create IAM Account
#### CloudFormation privileges. 
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "cloudformation:CreateStack",
        "cloudformation:DescribeStackEvents",
        "cloudformation:DescribeStacks",
        "cloudformation:GetTemplate",
        "cloudformation:ListStacks",
        "cloudformation:UpdateStack",
        "cloudformation:ValidateTemplate"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
```
#### Route 53 privileges.
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "route53:ChangeResourceRecordSets",
        "route53:CreateHostedZone",
        "route53:GetChange",
        "route53:GetHostedZone",
        "route53:ListHostedZones",
        "route53:ListResourceRecordSets"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
```
### 2. Clone and create config file.
```bash
$ git clone https://github.com/vg-s-tajima/bind2route53.git
$ cd bind2route53/config/
$ cp default.yml.template default.yml
$ cat default.yml
:env: default            # Name for this enviroment.
:region: ap-northeast-1  # Region for aws api.
:access_key_id:          # Access key id for AWS api.
:secret_key:             # Secret key for AWS api.
:confirm:                # If true, This scripts confirms before create/update AWS Resources(HostedZone/Stack).
```

### 3. Start Using bind2route53. 
Let's run bind2route53 commands below.


## Usage

#### Common Option.

    -c, --config-file=val  Config file. (default: config/default.yml) [Optional]
    -h                     Show Help.

#### Convert bind zone file to CloudFormation template. 

    $ bin/convert_zonefile [options]
    -f, --zone-file=val    Zone file. [Required]
    -z, --zone-name=val    Zone name. [Required]
    
    ex.) 
    $ bin/convert_zonefile -z example.com. -f /path/to/zonefile.zone > /path/to/templatefile.template

#### Create Route 53 Hosted Zone.

    $ bin/create_hostedzone [options]
    -z, --zone-name=val    Zone name. [Required]
    
    ex.) 
    $ bin/create_hostedzone -z example.com.

    
#### Create CloudFormation Stack.

    $ bin/create_hostedzone_stack [options]
    -t, --template-file=val CloudFormation template. [Required]

    ex.) 
    $ bin/create_hostedzone_stack -t /path/to/templatefile.template

#### Update CloudFormation Stack.

    $ bin/update_hostedzone_stack [options]
    -t, --template-file=val CloudFormation template. [Required]

    ex.) 
    $ bin/update_hostedzone_stack -t /path/to/templatefile.template

## License
This Tool is distributed under the Apache License, Version 2.0.

