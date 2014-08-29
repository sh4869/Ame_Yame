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
	if @user != status.user.screen_name  #二回同じ人が採用されるのを防ぐ。
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

	  if word != nil && word != "ー" && word != "!" && word != "(" 
		puts "#{word} from #{status.user.screen_name} at #{status.created_at}"
		@rest_client.favorite(status.id)
		@rest_client.update(word + "やめー!")
		@count = 1
	  end
	end
  end
end


puts @time
@rest_client.update("雨やめbotが起動したよ!(#{@time})")

@stream_client.user do |object|
  if object.is_a?(Twitter::Tweet)
	if @count == 30
	  ame_yame(object)
	  @count = 0
	end
	@count += 1
  end
end
