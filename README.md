bind2route53
============

Management tool for Route 53 with bind zone file.

# Setup

## Create IAM Account
 CloudFormation privileges. 
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
 Route 53 privileges.
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

## Clone and create config file.
```bash
$ git clone https://github.com/vg-s-tajima/bind2route53.git
$ cd bind2route53/config/
$ cp default.yml.template default.yml
$ cat default.yml
:env: default            # Name for this enviroment.
:region: ap-northeast-1  # Region for aws api.
:access_key_id:          # Access key id for AWS api.
:secret_key:             # Secret key for AWS api.
```



