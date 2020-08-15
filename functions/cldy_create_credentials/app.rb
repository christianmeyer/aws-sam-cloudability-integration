# Author:: Christian Meyer <christian.meyer@prosiebensat1.com>
# Copyright:: Copyright (c) 2020, ProSiebenSat.1 Tech Solutions GmbH
#
# Lambda to trigger the Cloudability API
# > Create Credential for Linked Account
#
# @env {String} CLDY_KEY - The Cloudability API authorization key (https://developers.cloudability.com/docs/getting-started#authentication)
# @env {String} BASE_URI - The Cloudability Vendor Credentials End Point (AWS) Base URI
#

require 'net/https'
require 'uri'
require 'json'

def lambda_handler(event:, context:)
  uri = URI.parse(ENV.fetch('BASE_URI'))
  request = Net::HTTP::Post.new(uri.to_s, 'Content-Type' => 'application/json')
  request.body = {
    'vendorAccountId' => event.fetch('vendorAccountId'),
    'type' => 'aws_role'
  }.to_json
  request.basic_auth(ENV.fetch('CLDY_KEY'), '')
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  response = http.request(request)
  result = JSON.parse(response.body).fetch('result', {})
  return {
    statusCode: response.code,
    body: result
  }
end
