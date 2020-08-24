# AWS Organizations Cloudability StackSet Setup

1. create S3 bucket
    ```bash
    aws s3 mb s3://{{aws-organizations-cf-governance-bucket}} --region us-east-1
    ```

2. put org wide read policy on it
    ```bash
    aws s3api put-bucket-policy --bucket {{aws-organizations-cf-governance-bucket}} --policy file://policy.json
    ```

    policy.json:
    ```json
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Sid": "AllowGetObject",
          "Effect": "Allow",
          "Principal": "*",
          "Action": "s3:GetObject",
          "Resource": "arn:aws:s3:::{{aws-organizations-cf-governance-bucket}}/*",
          "Condition": {
            "StringEquals": {
              "aws:PrincipalOrgID": "{{aws-organizations-root-id}}"
            }
          }
        }
      ]
    }
    ```

3. upload cloudability template
    ```bash
    aws s3api put-object --bucket {{aws-organizations-cf-governance-bucket}} --key cf-cloudability-role.yaml --body cf-cloudability-role.yaml
    ```

    cf-cloudability-role.yaml:
    ```yaml
    AWSTemplateFormatVersion: '2010-09-09'
    Description: Creates the Cloudability Role for a Linked Account
    Parameters:
      RoleName:
        Type: String
        Description: The name of the role Cloudability will use.
        MinLength: '1'
        MaxLength: '255'
        Default: CloudabilityRole
      TrustedAccountId:
        Type: String
        Description: The Cloudability account this role will trust.
        MinLength: '1'
        MaxLength: '255'
        Default: '165736516723'
      ExternalId:
        Type: String
        Description: The external identifier to use, given to you by Cloudability
        MinLength: '1'
        MaxLength: '255'
        Default: '01234567-0123-0123-0123-01234567890a'
    Resources:
      Role:
        Type: AWS::IAM::Role
        Properties:
          Description: AWS ReadOnly role used to support integration with Apptio Cloudability.
          AssumeRolePolicyDocument:
            Version: '2012-10-17'
            Statement:
              - Effect: Allow
                Principal:
                  AWS: !Sub 'arn:aws:iam::${TrustedAccountId}:user/cloudability'
                Action: sts:AssumeRole
                Condition:
                  StringEquals:
                    sts:ExternalId: !Ref 'ExternalId'
          Policies:
            - PolicyName: CloudabilityVerificationPolicy
              PolicyDocument:
                Version: '2012-10-17'
                Statement:
                  Sid: VerifyRolePermissions
                  Effect: Allow
                  Action: iam:SimulatePrincipalPolicy
                  Resource: !Sub 'arn:aws:iam::*:role/${RoleName}'
            - PolicyName: CloudabilityMonitorResourcesPolicy
              PolicyDocument:
                Version: '2012-10-17'
                Statement:
                  - Effect: Allow
                    Action:
                      - cloudwatch:GetMetricStatistics
                      - dynamodb:DescribeTable
                      - dynamodb:ListTables
                      - ec2:DescribeImages
                      - ec2:DescribeInstances
                      - ec2:DescribeRegions
                      - ec2:DescribeReservedInstances
                      - ec2:DescribeReservedInstancesModifications
                      - ec2:DescribeSnapshots
                      - ec2:DescribeVolumes
                      - ec2:GetReservedInstancesExchangeQuote
                      - ecs:DescribeClusters
                      - ecs:DescribeContainerInstances
                      - ecs:ListClusters
                      - ecs:ListContainerInstances
                      - elasticache:DescribeCacheClusters
                      - elasticache:DescribeReservedCacheNodes
                      - elasticache:ListTagsForResource
                      - elasticmapreduce:DescribeCluster
                      - elasticmapreduce:ListClusters
                      - elasticmapreduce:ListInstances
                      - rds:DescribeDBClusters
                      - rds:DescribeDBInstances
                      - rds:DescribeReservedDBInstances
                      - rds:ListTagsForResource
                      - redshift:DescribeClusters
                      - redshift:DescribeReservedNodes
                      - redshift:DescribeTags
                      - savingsplans:DescribeSavingsPlans
                      - ce:GetSavingsPlansPurchaseRecommendation
                    Resource: '*'
          RoleName: !Ref 'RoleName'

    ```

4. create an organization wide stackset
    ```bash
    aws cloudformation create-stack-set \
      --region us-east-1 \
      --stack-set-name 'ApptioCloudability' \
      --description 'Creates the Cloudability Role for a Linked Account' \
      --template-url https://{{aws-organizations-cf-governance-bucket}}.s3.amazonaws.com/cf-cloudability-role.yaml \
      --capabilities CAPABILITY_NAMED_IAM \
      --permission-model SERVICE_MANAGED \
      --auto-deployment Enabled=true,RetainStacksOnAccountRemoval=false

    aws cloudformation create-stack-instances \
      --region us-east-1 \
      --stack-set-name 'ApptioCloudability' \
      --deployment-targets OrganizationalUnitIds='{{aws-organizations-root-id}}' \
      --regions us-east-1 \
      --operation-preferences RegionOrder=us-east-1,FailureToleranceCount=50,MaxConcurrentCount=50
    ```
