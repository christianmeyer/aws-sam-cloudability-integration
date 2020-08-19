# SCP to protect the resources throughout the AWS Organization
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Deny",
            "Action": [
                "cloudformation:SetStackPolicy",
                "cloudformation:CancelUpdateStack",
                "cloudformation:SignalResource",
                "cloudformation:UpdateTerminationProtection",
                "cloudformation:CreateChangeSet",
                "cloudformation:DeleteChangeSet",
                "cloudformation:ContinueUpdateRollback",
                "cloudformation:CreateStack",
                "cloudformation:DeleteStack",
                "cloudformation:TagResource",
                "cloudformation:UpdateStack",
                "cloudformation:UntagResource",
                "cloudformation:ExecuteChangeSet"
            ],
            "Resource": "arn:aws:cloudformation:us-east-1:*:stack/StackSet-ApptioCloudability-*/*",
            "Condition": {
                "ForAllValues:StringNotEquals": {
                    "aws:CalledVia": [
                        "cloudformation.amazonaws.com"
                    ]
                },
                "StringNotLike": {
                    "aws:PrincipalARN": "arn:aws:iam::*:role/stacksets-exec-*"
                }
            }
        },
        {
            "Action": [
                "iam:AttachRolePolicy",
                "iam:CreateRole",
                "iam:DeleteRole",
                "iam:DeleteRolePermissionsBoundary",
                "iam:DeleteRolePolicy",
                "iam:DetachRolePolicy",
                "iam:PutRolePermissionsBoundary",
                "iam:PutRolePolicy",
                "iam:UpdateAssumeRolePolicy",
                "iam:UpdateRole",
                "iam:UpdateRoleDescription"
            ],
            "Resource": [
                "arn:aws:iam::*:role/CloudabilityRole"
            ],
            "Effect": "Deny",
            "Condition": {
                "ForAllValues:StringNotEquals": {
                    "aws:CalledVia": [
                        "cloudformation.amazonaws.com"
                    ]
                },
                "StringNotLike": {
                    "aws:PrincipalARN": "arn:aws:iam::*:role/stacksets-exec-*"
                }
            }
        },
        {
            "Action": [
                "iam:AttachRolePolicy",
                "iam:CreateRole",
                "iam:PutRolePermissionsBoundary",
                "iam:PutRolePolicy",
                "iam:UpdateAssumeRolePolicy",
                "iam:UpdateRole",
                "iam:UpdateRoleDescription"
            ],
            "Resource": [
                "arn:aws:iam::*:role/stacksets-exec-*"
            ],
            "Effect": "Deny",
            "Condition": {
                "StringNotLike": {
                    "aws:PrincipalARN": "arn:aws:iam::*:role/aws-service-role/member.org.stacksets.cloudformation.amazonaws.com/AWSServiceRoleForCloudFormationStackSetsOrgMember"
                }
            }
        },
        {
            "Action": [
                "iam:DeleteRole",
                "iam:DeleteRolePermissionsBoundary",
                "iam:DeleteRolePolicy",
                "iam:DetachRolePolicy"
            ],
            "Resource": [
                "arn:aws:iam::*:role/stacksets-exec-*"
            ],
            "Effect": "Deny",
            "Condition": {
                "StringNotLike": {
                    "aws:PrincipalARN": "arn:aws:iam::*:role/OrganizationAccountAccessRole"
                }
            }
        },
        {
            "Action": [
                "iam:AssumeRole"
            ],
            "Resource": [
                "arn:aws:iam::*:role/stacksets-exec-*"
            ],
            "Effect": "Deny",
            "Condition": {
                "ForAllValues:StringNotEquals": {
                    "aws:CalledVia": [
                        "cloudformation.amazonaws.com"
                    ]
                },
                "StringNotEquals": {
                    "aws:PrincipalAccount": "{{aws-organizations-payer-account-id}}"
                }
            }
        }
    ]
}
```
