# Coding: UTF-8
require 'twitter'
require './keys.rb'
require 'net/http'
require 'uri'
require 'rexml/document'

@rest_client = Twitter::REST::Client.new do |config|
  config.consumer_key        = CONSUMER_KEY
  config.consumer_secret     = CONSUMER_SECRET
  config.access_token        = ACCESS_TOKEN
  config.access_token_secret = ACCESS_SECRET
end

@stream_client = Twitter::Streaming::Client.new do |config|
  config.consumer_key       = CONSUMER_KEY
  config.consumer_secret    = CONSUMER_SECRET
  config.access_token        = ACCESS_TOKEN
  config.access_token_secret = ACCESS_SECRET
end

@Time = Time.now
@time = @Time.strftime("%x %H:%M")
@user = ""
@count = 0
@id = YAHOOAPPID

#言語解析部分
def ame_yame(status)
  if status.uris? == false && status.media? == false && status.user_mentions? == false
	sentence = status.text
	@user = status.user.screen_name
	word_array = []

	#YahooJaParse
	response = Net::HTTP.post_form(URI.parse('http://jlp.yahooapis.jp/MAService/V1/parse'),
								   {'appid'=> @id,'sentence' => sentence,'results' => 'ma'})
	xml = REXML::Document.new(response.body)
	xml.elements.each('ResultSet/ma_result/word_list/word') do |element|
	  if element.elements['pos'].text == "名詞"
		word_array << element.elements['surface'].text
	  end	
	end
	word = word_array.sample

	if word != nil 
	  puts "#{word} | #{status.created_at} "
	  data = {:word => word,:user_screen_name => status.user.screen_name,:time => status.created_at}
	  jsondata = data.to_json
	  @rest_client.favorite(status.id)
	  @rest_client.update(word + "やめー!")
	  @count = 1
	end
	
	#File output
	file = File.open("output.json","a")
	file.write(jsondata)
	file.close
  end
end

def talk(status)
  text = status.text 
  response = Net::HTTP.post_form(URI.parse('http://jlp.yahooapis.jp/MAService/V1/parse'),
								 {'appid'=> @id,'sentence' => text,'results' => 'ma'})
  xml = REXML::Document.new(response.body)
  greetings = []
  noun = []
  xml.elements.each('ResultSet/ma_result/word_list/word') do |element|
	case element.elements['pos'].text 
	when "感動詞"
	  greetings << element.elements['surface'].text
	when "名詞"
	  noun << element.elements['surface'].text
	end
  end
  noun.delete("ame")
  noun.delete("yame")
  if greetings.empty? == false
	greet = greetings.sample
	@rest_client.update("@#{status.user.screen_name} #{greet}!",:in_reply_to_status_id => status.id)
  else noun.empty? == false
	nou = noun.sample
	@rest_client.update("@#{status.user.screen_name} #{nou}って何?",:in_reply_to_status_id => status.id)
  end	
end

puts "Up: #{@time}"
@rest_client.update("雨やめbotが起動したよ!(#{@time})")

@stream_client.user do |object|
  if object.is_a?(Twitter::Tweet)
	if object.in_reply_to_screen_name == "ame_yame"
	  talk(object)
	end
	if @count == 30
	  ame_yame(object)
	  @count = 0
	end
	@count += 1
  end
end
