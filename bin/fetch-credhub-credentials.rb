#!/usr/bin/env ruby
require 'open3'
require 'json'

env_dir = ARGV[0]

login_stdout, login_stderr, login_status = Open3.capture3('credhub login')
if login_status != 0
  STDERR.puts 'Could not login in to CredHub, check the contents of $CREDHUB_SERVER, $CREDHUB_CA_CERT, $CREDHUB_CLIENT and $CREDHUB_SECRET environment variables'
  STDERR.puts "CredHub error: #{login_stderr}"
  exit(login_status)
end

ENV.select do |env, _|
  env.start_with? 'CREDHUB_ENV_'
end.each_pair do |env, value|
  credential_query_parts = value.split '.'
  credential_name = credential_query_parts[0]
  credentials_json, stderr, status = Open3.capture3("credhub find -j -n #{credential_name}")
  if status != 0
    STDERR.puts "Could not find any variables that matched #{credential_name}"
    break
  end

  credentials = JSON.parse(credentials_json)['credentials']
  if credentials.length > 1
    STDERR.puts "Found #{credentials.length} credentials matching #{credential_name}: #{credentials.map do |c| c['name'] end.to_json}"
    break
  end

  selector_query = ['.value'] + credential_query_parts[1..-1]
  # This uses `jq` to make the selectors more familiar to people
  cmd = "credhub get -n #{credentials[0]['name']} -j | jq -r '#{selector_query.join '.'}'"
  credential_value, stderr, status = Open3.capture3(cmd)
  if status != 0
    STDERR.puts "Failed to extract value from credential using: #{cmd}"
    break
  end

  env_var = env.sub 'CREDHUB_ENV_', ''
  open("#{env_dir}/#{env_var}", 'w') do |env_var_file|
    env_var_file.puts credential_value
  end
  STDOUT.puts "CREDHUB: #{env_var} written to #{env_dir}/#{env_var}"
end