# Coding: UTF-8
require 'twitter'
require './keys.rb'
require 'net/http'
require 'uri'
require 'rexml/document'

class AmeYame
	def initialize
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
		@count = 30
		@id = YAHOOAPPID
	end

	def yahoo_api(sentence)
		response = Net::HTTP.post_form(URI.parse('http://jlp.yahooapis.jp/MAService/V1/parse'),
									   {'appid'=> @id,'sentence' => sentence,'results' => 'ma'})
		xml = REXML::Document.new(response.body)
		return xml
	end

	def xml_parse(xml,part_speech)
		word_array = []
		xml.elements.each('ResultSet/ma_result/word_list/word') do |element|
			if element.elements['pos'].text == part_speech
				word_array << element.elements['surface'].text
			end	
		end
		return word_array.sample
	end

	def ame_yame(status)
		sentence = status.text
		@user = status.user.screen_name
		word_array = []

		xml = yahoo_api(sentence)
		word = xml_parse(xml,"名詞")

		if word != nil 
			data = {:word => word,:user_screen_name => status.user.screen_name,:time => status.created_at}
			jsondata = data.to_json
			puts jsondata
			@rest_client.favorite(status.id)
			@rest_client.update(word + "やめー!")
			@count = 1
		end
	end

	def ame_yame_with_rest
		@rest_client.home_timeline.each do |tweet|
			if tweet.uris? == false && tweet.media? == false && tweet.user_mentions? == false
				ame_yame(tweet)
				return
			end
		end
	end

	def ame_yame_with_stream
		@rest_client.update("雨やめbotが起動したよ!(#{@time})")

		@stream_client.user do |object|
			if object.is_a?(Twitter::Tweet)
				if object.uris? == false && object.media? == false && object.user_mentions? == false
					if @count == 30
						ame_yame(object)
					end
					@count += 1
				end
			end
		end
	end
end

