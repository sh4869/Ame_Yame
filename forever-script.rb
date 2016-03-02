require 'rubygems' unless defined?(Gem)
require 'forever'
require './ame_yame.rb'
require './keys.rb'

ame_yame = AmeYame.new do |config|
	config.twi_consumer_key = CONSUMER_KEY
	config.twi_consumer_secret = CONSUMER_SECRET
	config.twi_access_token = ACCESS_TOKEN
	config.twi_access_token_secret = ACCESS_SECRET
	config.yahoo_app_id = YAHOOAPPID
end

Forever.run do
	every 20.minutes do
		ame_yame.ame_yame_with_rest
	end
	
	every 60.minutes do
		ame_yame.ff_check
	end

	on_error do |e|
		puts "-" * 30
		puts e
		puts "-" * 30
	end
end
