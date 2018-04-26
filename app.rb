require 'sinatra'
require 'rubygems'
require 'bundler/setup'
require 'json'
require 'rest-client'

post '/' do
  content_type :json
  return {"error" => "Unauthorised"}.to_json unless request.env["HTTP_AUTHORIZATION"] == "key"

  @params = JSON.parse(request.body.read)

  perform
  @data.to_json
end

def perform
  @data = {}

  if File.exist?(current_date_file)
    file = File.read(current_date_file)
    @data = JSON.parse(file)
    return
  end

  get_list_of_channels_from_server
  prepare_tv_program
  write_to_file
end

def get_list_of_channels_from_server
  request = RestClient.get "http://ott.watch/api/channel_now.json"
  @channel_list = JSON.parse(request.body)
end

def prepare_tv_program
  @params["channels"].each do |channel_name|

    found_channel = @channel_list["channels"].first.detect do |_,v|
      v["channel_name"].delete(" ").match(Regexp.new(channel_name.delete(" "), true))
    end

    chanel_program = if found_channel
      chanel_id = found_channel.first
      request_program = RestClient.get "http://ott.watch/api/channel/#{chanel_id}.json"
      JSON.parse(request_program.body)
    else
      {}
    end

    @data[channel_name] = chanel_program
  end
end

def write_to_file
  unless File.exist?(current_date_file)
    Dir["files_by_dates/*"].each {|f| File.delete(f) }

    File.open(current_date_file,"w") do |f|
      f.write(@data.to_json)
    end
  end
end

def current_date_file
  file_name = Time.now.getlocal('+02:00').strftime("%d-%m-%Y") + ".json"
  "files_by_dates/" + file_name
end