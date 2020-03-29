require_relative 'parsing'

if not ARGV[0]
  puts "Parses a URL for questions and gives helpful output about how it does so."
  puts "Usage: ruby testparseurl.rb [URL]"
  exit
end

content = `wget -q -O - "#{ARGV[0]}"`.force_encoding('iso-8859-1')
matchedText = /<body(.|\n)*<\/body[^>]*>/i.match(content)
if not matchedText
  puts "no body found"
  exit
end
text = matchedText[0]
qs = grabQuestions(text, ARGV[0], true)
qs.each{|q| puts q[0] }
