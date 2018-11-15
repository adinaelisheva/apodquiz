apodRegex = /Explanation:(.|\n)*Tomorrow's picture:/
apodUrl = "https://apod.nasa.gov/apod/"

require_relative 'parsing'
require_relative 'printing'

# Grab the explanation block off the apod site
content = `wget -q -O - http://apod.nasa.gov/apod/astropix.html`
explanation = apodRegex.match(content)[0]

# Grab a list of followup links from the explanation
links = []
explanation.gsub!(/\n/,"").scan(/<a href="([^"]+)">/) {|link|
  link = link[0]
  if (not link.start_with?("http")) 
    link = "#{apodUrl}#{link}"
  end
  if (link.start_with?("#{apodUrl}image/") or link.end_with?(".jpg") or link.end_with?(".png") or link.end_with?(".gif"))
    next
  end
  links.push(link)
}

puts "found #{links.length} links"

all = []

# For each explanation, grab some text if there is any
links.each.with_index {|url, ind|
  puts "fetching link #{ind+1} of #{links.length}: #{url}"
  content = `wget -q -O - #{url}`.force_encoding(Encoding::UTF_8)

  puts "parsing link"
  if (url.start_with?(apodUrl)) 
    text = apodRegex.match(content)[0]
  else
    text = /<body(.|\n)*<\/body[^>]*>/.match(content)[0]
  end
  text = removeExtraneousStuff(text)
  text.gsub!(/<[^>]*>/, " ").gsub!(/\n/," ")

  puts "creating questions"
  questions = createQuestions(text)
  puts "added #{questions.length} questions"
  all = all.concat(questions) 
}

print(links, all)