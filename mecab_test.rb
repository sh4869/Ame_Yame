#encoding: utf-8
require 'MeCab'
c = MeCab::Tagger.new
puts c.parse("すもももももももものうち")
