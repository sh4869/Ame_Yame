require "./ame_yame/*"

word_extracter = Ame_Yame::WordExtracter.new("dj0zaiZpPUt3ZWM1OWFZNGg0eCZzPWNvbnN1bWVyc2VjcmV0Jng9NDk-")
puts word_extracter.extract("雨やめbotで日本語を解析するのにつかいます。","名詞")
