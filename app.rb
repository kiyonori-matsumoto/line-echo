# Mostly taken from http://qiita.com/masuidrive/items/1042d93740a7a72242a3

require 'sinatra/base'
require 'json'
require 'rest-client'
require 'open-uri'

class App < Sinatra::Base
  post '/linebot/callback' do
    params = JSON.parse(request.body.read)

    params['result'].each do |msg|
      request_content = {
        to: [msg['content']['from']],
        toChannel: 1383378250, # Fixed  value
        eventType: "138311608800106203", # Fixed value
        content: msg['content']
      }

      stage_json = nil
      open("http://splapi.retrorocket.biz/gachi/now") do |fp|
        stage_json = JSON.load(fp)
      end
      return_string = "今のステージは#{stage_json["result"][0]["maps"][0]}と#{stage_json["result"][0]["maps"][1]}だよ!"

      endpoint_uri = 'https://trialbot-api.line.me/v1/events'
      request_content[:content] = return_string
      content_json = request_content.to_json

      RestClient.proxy = ENV['FIXIE_URL'] if ENV['FIXIE_URL']
      RestClient.post(endpoint_uri, content_json, {
        'Content-Type' => 'application/json; charset=UTF-8',
        'X-Line-ChannelID' => ENV["LINE_CHANNEL_ID"],
        'X-Line-ChannelSecret' => ENV["LINE_CHANNEL_SECRET"],
        'X-Line-Trusted-User-With-ACL' => ENV["LINE_CHANNEL_MID"],
      })
    end

    "OK"
  end
end
