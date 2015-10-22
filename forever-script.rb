require 'rubygems' unless defined?(Gem)
require 'forever'
require './ame_yame.rb'

ame_yame = AmeYame.new

Forever.run do
	every 15.minutes do
		ame_yame.ame_yame_with_rest
	end
	on_error do |e|
		puts "-" * 30
		puts e
		puts "-" * 30
	end
end
