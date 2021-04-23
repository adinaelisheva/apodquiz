#!/usr/bin/ruby

# WARNING: With no arguments, this script grabs the date off the server, which late at night will be
# ahead of the APOD servers and thus try to grab tomorrow's APOD before it's posted. If you're testing
# this in the evening and you get a nil error when trying to access the wget'd content... that's why.
# Pass in an explicit date and you'll be good to go.

apodRegex = /Explanation:(.|\n)*<center>/
apodImageParagraphOpeningString = "Discover the cosmos!</a>Each day a different image or photograph of our fascinating universe isfeatured, along with a brief explanation written by a professional astronomer."
apodImageParagraphRegex = /#{apodImageParagraphOpeningString} *<p>[\d\w ]*<br>(.|\n)*Credit/
apodBaseUrl = "https://apod.nasa.gov/apod/"

require_relative 'parsing'
require_relative 'printing'

# Grab the explanation block off the apod site
date = ""
if ARGV[0]
  date = ARGV[0]
else
  t = Time.now
  date = t.strftime("%y%m%d")
end
tail = "ap#{date}.html"
apodUrl = "#{apodBaseUrl}#{tail}"
content = `wget -q -O - #{apodUrl}`.force_encoding('iso-8859-1')
title =	/<b>([^<]*)<\/b>(<br>|<b>|\\n|\s)*(Image|Video) Credit/.match(content)[1]
puts "Found APOD '#{title.strip()}'"
imageTag = getImageOrVideoTag(apodImageParagraphRegex.match(content.gsub(/\n/,""))[0])
puts "Found image block '#{imageTag}'"
explanation = apodRegex.match(content)[0].gsub("Explanation:","")

# Grab a list of followup links from the explanation
links = []
explanation.gsub(/\n/,"").scan(/<a href="([^"]+)">([^<]+)</) {|link|
  url = link[0]
  text = link[1]
  if (not url.start_with?("http")) 
    url = "#{apodBaseUrl}#{url}"
  end
  if url.start_with?("#{apodBaseUrl}image/") or url.end_with?(".jpg") or url.end_with?(".png") or url.end_with?(".gif")
    next
  end
  links.push([url, text])
}

puts "found #{links.length} links"

linksAndQuestions = []

# First grab one question from the APOD itself, if any
puts "parsing apod"
explanation.gsub!(/\n/," ")
questions = grabQuestions(explanation, apodBaseUrl)
puts "found #{questions.length} questions"
if (questions.length > 0) 
  puts "adding 1"
  question = questions[0]
else
end
linksAndQuestions.push([
  ["", "the explanation above"],
  [questions.length > 0 ? questions[0] : []]
])

# For each explanation, grab some text if there is any and get a question 
# from it.
usedAnswers = []
links.each.with_index {|link, ind|
  url = link[0]
  linkText = link[1]
  puts "fetching link #{ind+1} of #{links.length}: #{url}"
  content = `wget -q -O - "#{url}"`.force_encoding('iso-8859-1')

  puts "parsing link"
  if (url.start_with?(apodBaseUrl)) 
    matchedText = apodRegex.match(content)
  else
    matchedText = /<body(.|\n)*<\/body[^>]*>/i.match(content)
  end
  if not matchedText
    linksAndQuestions.push([link, []])
    next
  end
  text = matchedText[0]

  questions = grabQuestions(text, url)
  if questions.length === 0
    linksAndQuestions.push([link, []])
    next
  end
  q = questions.pop()
  while q and usedAnswers.include?(q[1])
    q = questions.pop()
  end
  if q
    linksAndQuestions.push([link, q])
    usedAnswers.push(q[1])
  else
    linksAndQuestions.push([link, []])
  end
}

print(apodUrl, imageTag, explanation, linksAndQuestions, title, date)
