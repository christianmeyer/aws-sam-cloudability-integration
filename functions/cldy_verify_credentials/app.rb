# Author:: Christian Meyer <christian.meyer@prosiebensat1.com>
# Copyright:: Copyright (c) 2020, ProSiebenSat.1 Tech Solutions GmbH
#
# Lambda to trigger the Cloudability API
# > Verify Credentials for an Account
#
# @env {String} CLDY_KEY - The Cloudability API authorization key (https://developers.cloudability.com/docs/getting-started#authentication)
# @env {String} BASE_URI - The Cloudability Vendor Credentials End Point (AWS) Base URI
#

require 'net/https'
require 'uri'
require 'json'

def lambda_handler(event:, context:)
  uri = URI.parse([ENV.fetch('BASE_URI'), event.fetch('vendorAccountId'), 'verification'].join('/'))
  request = Net::HTTP::Post.new(uri.to_s)
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
