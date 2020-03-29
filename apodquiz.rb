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
explanation.gsub(/\n/,"").scan(/<a href="([^"]+)">/) {|link|
  link = link[0]
  if (not link.start_with?("http")) 
    link = "#{apodBaseUrl}#{link}"
  end
  if link.start_with?("#{apodBaseUrl}image/") or link.end_with?(".jpg") or link.end_with?(".png") or link.end_with?(".gif")
    next
  end
  links.push(link)
}

puts "found #{links.length} links"

questionsBySite = []

# First grab one question from the APOD itself, if any
puts "parsing apod"
explanation.gsub!(/\n/," ")
questions = grabQuestions(explanation, apodBaseUrl)
puts "found #{questions.length} questions"
if (questions.length > 0) 
  puts "adding 1"
  question = questions[0] + [0] # q[2] is the hint - here, 0 for the base url
  questionsBySite.push([question])
end

# For each explanation, grab some text if there is any
links.each.with_index {|url, ind|
  puts "fetching link #{ind+1} of #{links.length}: #{url}"
  content = `wget -q -O - "#{url}"`.force_encoding('iso-8859-1')

  puts "parsing link"
  if (url.start_with?(apodBaseUrl)) 
    matchedText = apodRegex.match(content)
  else
    matchedText = /<body(.|\n)*<\/body[^>]*>/i.match(content)
  end
  if not matchedText
    puts "no body found"
    next
  end
  text = matchedText[0]

  questions = grabQuestions(text, url).map { |q|
    q + [ind]
  }
  if (questions.length > 0) 
    questionsBySite.push(questions)
  end
}

# The goal here is to get at least 1 question from every site that I can, and then to get up to 10
# questions if possible. If there are more than 10 sites, there will be more than 10 questions. If 
# there are less than 10 questions total from all sites then we'll only show the ones we have. In 
# all cases this tries to draw the questions as evenly from all sites as possible, and they will be
# mixed up together.
finalList = []
usedAnswers = []
questionsBySite.each { |list|
  q = list.pop()
  while q and usedAnswers.include?(q[1])
    q = list.pop()
  end
  if q
    finalList.push(q)
    usedAnswers.push(q[1])
  end
}

if finalList.length < 10
  numLeft = questionsBySite.inject(0) {|sum, l| sum + l.length }
  #don't have quite 10 questions, keep adding some
  ind = 0
  while numLeft > 0 and finalList.length < 10
    q = questionsBySite[ind].pop()
    if q and not usedAnswers.include?(q[1])
      finalList.push(q)
      usedAnswers.push(q[1])
    end
    numLeft = numLeft-1
    ind = (ind + 1) % questionsBySite.length
  end
end

print(apodUrl, imageTag, explanation, links, title, date, finalList.shuffle())
