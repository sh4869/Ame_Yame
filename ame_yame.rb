# Coding: UTF-8
require 'twitter'
require './keys.rb'
require 'MeCab'

@mecab = MeCab::Tagger.new
@f_1 = 0

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

def ame_yame(status)
  if status.uris? == false && status.media? == false && status.user_mentions? == false
	sentence = status.text
	node = @mecab.parseToNode(sentence)
	word_array = []
	begin
	  node = node.next
	  if /^名詞/ =~ node.feature.force_encoding("UTF-8")
		word_array << node.surface.force_encoding("UTF-8")
	  end
	end until node.next.feature.include?("BOS/EOS")
	word = word_array.sample
	if word != nil && word != "ー" && word != "!"
	  puts word
	  @rest_client.favorite(status.id)
	  @rest_client.update(word + "やめー!")
	  @f_1 = 1
	end
  end
end

loop do
  @stream_client.user do |object|
	if object.is_a?(Twitter::Tweet)  && object.user.screen_name != "sh4869bot"
	  ame_yame(object)
	end
	if @f_1 == 1
	  break
	end
  end
  sleep(900)
  @f_1 = 0
end

