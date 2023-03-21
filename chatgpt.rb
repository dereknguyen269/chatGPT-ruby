require 'net/http'
require 'uri'
require 'json'

class ChatGpt
  def initialize(open_api_key)
    @open_api_key = open_api_key
    init_http_client
  end

  def send_message(content)
    @http_client.body = set_body(content)
    http = Net::HTTP.new(@open_api_uri.host, @open_api_uri.port)
    http.use_ssl = true
    response = http.request(@http_client)
    format_chat_response(response.body)
  end

  private

  def init_http_client
    @open_api_uri = URI('https://api.openai.com/v1/chat/completions')
    @http_client = Net::HTTP::Post.new(@open_api_uri.path)
    @http_client['Content-Type'] = 'application/json'
    @http_client['Authorization'] = "Bearer #{@open_api_key}"
  end

  def set_body(content)
    {
      "model": "gpt-3.5-turbo",
      "messages": [{ "role": "user", "content": content }]
    }.to_json
  end

  def format_chat_response(response_body)
    body = JSON.parse(response_body)
    puts body["choices"][0]["message"]["content"]
  rescue
    puts "Please try again! \n"
  end
end

open_api_key = nil
in_chat = true
while in_chat
  unless open_api_key
    puts "Enter `exit` to quit \n"
    puts "Please enter your OpenAi API Key: "
    message = gets.chomp
    break if message == 'exit'

    open_api_key = message
    puts "Your OpenAi API Key: #{open_api_key}"
    @chatgpt ||= ChatGpt.new(open_api_key)
  end

  puts "Please enter your message: "
  message = gets.chomp
  puts "\n"
  break if message == 'exit'

  puts "ChatGPT:"
  @chatgpt.send_message(message)
  puts "\n"
end
