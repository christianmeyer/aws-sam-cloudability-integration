/**
 * Author:: Christian Meyer <christian.meyer@prosiebensat1.com>
 * Copyright:: Copyright (c) 2020, ProSiebenSat.1 Tech Solutions GmbH
 *
 * Lambda to check for the status of a CloudFormation StackSet operation.
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
    const describeStackSetOperationResult = await cloudformation.describeStackSetOperation({
      OperationId: event.operationId,
      StackSetName: ENV.STACK_SET_NAME
    }).promise();
    return {
      statusCode: 200,
      body: { ...event, ...{ operationState: describeStackSetOperationResult.StackSetOperation.Status } }
    };
  } catch (error) {
    console.error(error.stack);
    throw error;
  }
};
