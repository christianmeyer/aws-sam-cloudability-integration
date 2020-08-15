# Author:: Christian Meyer <christian.meyer@prosiebensat1.com>
# Copyright:: Copyright (c) 2020, ProSiebenSat.1 Tech Solutions GmbH
#
# Lambda to trigger the Cloudability API
# > Retrieve Associated Accounts
#
# @env {String} CLDY_KEY - The Cloudability API authorization key (https://developers.cloudability.com/docs/getting-started#authentication)
# @env {String} BASE_URI - The Cloudability Vendor Credentials End Point (AWS) Base URI
# @env {String} PAYER_ID - The AWS AccountID of the master payer account whereof we review the linked accounts
#

require 'net/https'
require 'uri'
require 'json'

def lambda_handler(event:, context:)
  uri = URI.parse([ENV.fetch('BASE_URI'), ENV.fetch('PAYER_ID')].join('/'))
  params = { 'include' => 'associatedAccounts' }
  uri.query = URI.encode_www_form(params)
  request = Net::HTTP::Get.new(uri.to_s)
  request.basic_auth(ENV.fetch('CLDY_KEY'), '')
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  response = http.request(request)
  result = JSON.parse(response.body).fetch('result', {}).fetch('associatedAccounts', [])
  noCredentials = result.select{ |h| !h.key?('authorization') }.map{ |h| h.merge('itemState' => 'noCredentials') }
  unVerified = result.select{ |h| h.key?('authorization') && !h.fetch('verification', {}).fetch('state', '').eql?('verified') }.map{ |h| h.merge('itemState' => 'unVerified') }
  return {
    statusCode: response.code,
    body: [].concat(noCredentials).concat(unVerified)
  }
end
