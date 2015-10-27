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
		xml = yahoo_api(sentence)
		word = xml_parse(xml,"名詞")

		if word != nil 
			data = {:word => word,:user_screen_name => status.user.screen_name,:time => status.created_at}
			jsondata = data.to_json
			puts jsondata
			@rest_client.favorite(status.id)
			@rest_client.update(word + "やめー!")
		end
	end

	def check_tweet(tweet)
		if tweet.uris? == false && tweet.media? == false && tweet.user_mentions? == false
			return true
		end
		return false
	end

	def ame_yame_with_rest
		@rest_client.home_timeline.each do |tweet|
			if check_tweet(tweet)
				ame_yame(tweet)
				return
			end
		end
	end

	def ame_yame_with_stream
		count = 0
		@stream_client.user do |object|
			if object.is_a?(Twitter::Tweet) 
				if check_tweet(tweet)
					if count == 30
						ame_yame(object)
						count = 1
					end
					count += 1
				end
			end
		end
	end

	def ff_check
		followers =  @rest_client.follower_ids.to_h[:ids]
		friends =  @rest_client.friend_ids.to_h[:ids]
		# follow followers who @ame_yame don't follow
		nofollow_follower = followers - friends
		nofollow_follower.each do |user_id|
			begin 
				@rest_client.follow(user_id)
				puts "follow " + user_id.to_s 
				sleep(3)
			rescue => ex
				puts ex
			end
		end
		# unfollow following user who don't follow @ame_yame
		nofollowes_friend = friends - followers
		nofollowes_friend.each do |user_id|
			begin 
				@rest_client.unfollow(user_id)
				puts "unfollow " + user_id.to_s
				sleep(3)
			rescue => ex
				puts ex
			end
		end
	end

end

