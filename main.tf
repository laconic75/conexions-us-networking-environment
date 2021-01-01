terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.22.0"
    }
  }
}

provider "aws" {
  region = var.region
}

module "dns_zone" {
  source = "/home/joel/Source/terraform-aws-route-53-domain"

  dns_root = var.dns_root
  region   = var.region
}

# Add web-server role
resource "aws_iam_role" "web_server_role" {
  name = "web_server_${var.dns_root}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "acme_challenge" {
  role = aws_iam_role.web_server_role.name
  policy_arn = aws_iam_policy.resolve_certificate_challenge_route53.arn
}

# Add permission to resolve certificate challenge via dns
resource "aws_iam_policy" "resolve_certificate_challenge_route53" {
  name        = "resolve_certificate_challenge_route53"
  path        = "/"
  description = "Resolve ACME certificate challenge by updating a Route53 entry"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Id": "acme-dns-route53 policy",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "route53:ListHostedZones",
                "route53:GetChange"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect" : "Allow",
            "Action" : [
                "route53:ChangeResourceRecordSets"
            ],
            "Resource" : [
                "arn:aws:route53:::hostedzone/${module.dns_zone.dns_zone_id}"
            ]
        }
    ]
}
EOF
}
