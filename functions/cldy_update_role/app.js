/**
 * Author:: Christian Meyer <christian.meyer@prosiebensat1.com>
 * Copyright:: Copyright (c) 2020, ProSiebenSat.1 Tech Solutions GmbH
 *
 * Lambda to update the externalId of the CloudFormation StackSet.
 *
 * @env {String} STACK_SET_NAME - The name of the CloudFormation StackSet used to maintain the Cloudability Templates accross the Organization
 */

let ENV = process.env;

let AWS = require('aws-sdk');

let cloudformation = new AWS.CloudFormation({
  apiVersion: '2010-05-15'
});

exports.lambdaHandler = async (event, context) => {
  try {
    const updateStackInstancesResult = await cloudformation.updateStackInstances({
      Regions: [
        ENV.AWS_REGION
      ],
      StackSetName: ENV.STACK_SET_NAME,
      DeploymentTargets: {
        Accounts: [
          event.vendorAccountId
        ]
      },
      OperationPreferences: {
        FailureToleranceCount: '0',
        MaxConcurrentCount: '1',
        RegionOrder: [
          ENV.AWS_REGION
        ]
      },
      ParameterOverrides: [{
        ParameterKey: 'ExternalId',
        ParameterValue: event.authorization.externalId
      }]
    }).promise();
    return {
      statusCode: 200,
      body: { ...event, ...{ operationId: updateStackInstancesResult.OperationId } }
    };
  } catch (error) {
    console.error(error.stack);
    throw error;
  }
};
