#!/usr/bin/env ruby
require 'open3'
require 'json'

$base_path = ARGV[0]
env_dir = ARGV[1]
file_dir = ARGV[2]

login_stdout, login_stderr, login_status = Open3.capture3('credhub login')
if login_status != 0
  STDERR.puts 'Could not login in to CredHub, check the contents of $CREDHUB_SERVER, $CREDHUB_CA_CERT, $CREDHUB_CLIENT and $CREDHUB_SECRET environment variables'
  STDERR.puts "CredHub error: #{login_stderr}"
  exit(login_status)
end

vcap_application = JSON.parse ENV['VCAP_APPLICATION']
$cf_env = {
  'CF_ORG' => vcap_application['organization_name'],
  'CF_SPACE' => vcap_application['space_name'],
  'CF_APP' => vcap_application['application_name'],
}

class CredHubException < StandardError
end

def get_credhub_credential(credential)
  query_parts = credential.split '.'
  credential_name = "#{$base_path}/#{query_parts[0]}".gsub /\/+/, '/'
  # Select `.value` + everything after the `.` in the credential query
  query = ['.value'] + query_parts[1..-1]
  # This uses `jq` to make the selectors more familiar to people
  cmd = "credhub get -n #{credential_name} -j | jq -r '#{query.join '.'}'"
  credential_value, stderr, status = Open3.capture3($cf_env, cmd)
  if status != 0
    raise CredHubException "Failed to extract value from credential using: #{cmd}"
  end
  return credential_value
end

ENV.select do |env, _|
  env.start_with? 'CREDHUB_ENV_'
end.each_pair do |env_var_name, credential|
  begin
    credential_value = get_credhub_credential credential
  rescue CredHubException => e
    STDERR.puts e.message
  end
  env_var = env_var_name.sub 'CREDHUB_ENV_', ''
  open("#{env_dir}/#{env_var}", 'w') do |env_var_file|
    env_var_file.puts credential_value
  end
  STDOUT.puts "CREDHUB ENV: #{env_var} written to #{env_dir}/#{env_var}"
end

ENV.select do |env, _|
  env.start_with? 'CREDHUB_FILE_'
end.each_pair do |file_name, credential|
  begin
    credential_value = get_credhub_credential credential
  rescue CredHubException => e
    STDERR.puts e.message
  end
  file_name = file_name.sub 'CREDHUB_FILE_', ''
  open("#{file_dir}/#{file_name}", 'w') do |file|
    file.puts credential_value
  end
  STDOUT.puts "CREDHUB FILE: #{file_name} written to #{file_dir}/#{file_name}"
end