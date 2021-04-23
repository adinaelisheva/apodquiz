def print(apodUrl, imageTag, explanation, linksAndQuestions, title, date)
  wd = "/home/radina/public/apodquiz"

  # linksAndQuestions is a list of [link, question] 
  #   where link is [url, text]
  #   and question is [question, answer]
  filename = ARGV[1] ? ARGV[1] : "index.html"
  puts "Deleting old #{filename} (if any)"
  `rm #{wd}/#{filename}`

  puts "Creating new #{filename}"

  output = File.open("#{wd}/#{filename}", "w")
  
  printdate = "#{date[2..3]}/#{date[4..5]}/#{date[0..1]}"

  output << "<html><head>"
  
  output << "<title>APOD Quiz</title>"
  output << "<script src=\"index.js\"></script>"
  output << "<meta name=\"viewport\" content=\"width=device-width\">"
  output << "<link rel=\"shortcut icon\" type=\"image/x-icon\" href=\"favicon.ico\" />"
  output << "<link href=\"https://fonts.googleapis.com/css?family=Bubblegum+Sans\" rel=\"stylesheet\">"
  output << "<link href=\"index.css\" type=\"text/css\" rel=\"stylesheet\">"  
  
  output << "</head><body>"
  output << "<div class=\"imageOrVideo\">"
  output << imageTag
  output << "</div>"

  linksAndQuestions.each { |data|
    link = data[0]
    output << "<a class=\"link hidden\" href=\"#{link[0]}\">_</a>"
  }

  output << "<div class=\"header invisible\">"
  output << "<h1>Quiz Time!</h1>"
  output << "<h2>#{printdate} - #{title}</h2>"
  output << "</div>"

  output << "<div class=\"main\">"
  output << "<div class=\"apod\">"
  output << "<div class=\"explanation invisible\">"
  output << "<p>#{explanation.gsub(/href="ap(\d+).html"/,'href="http://apod.nasa.gov/apod/ap\1.html"')}</p>"
  output << "<div class=\"openlinks isFakeLink\">Open all links in tabs</div>"
  output << "</div>"
  output << "</div>"
  output << "</div>"

  output << "<div class=\"quiz invisible\">"
  output << "<div class=\"score\">Completed: <span class=\"num\">0</span> of <span class=\"whole\"></span></div>"
  output << "<div class=\"finished invisible\">100%!</div>"

  output << "<div class=\"questions\">"
  output << "<button class=\"mobile hidden\">&lt;</button>"
  linksAndQuestions.each { |data|
    link = data[0]
    question = data[1]
    if question.length < 2 
      next
    end
    query = question[0]
    answer = question[1].downcase().tr("abcdefghijklmnopqrstuvwxyz0123456789", "nopqrstuvwxyz0123456789abcdefghijklm") #encode
    output << "<div class=\"questionContainer hidden\">"
    toRead = link[0] ? "the <a class=\"toRead\" href=#{link[0]}>#{link[1]}</a> link" : link[1] 
    output << "<div class=\"readPrompt\">Read #{toRead}</div>"
    output << "<div class=\"question\">"
    parts = query.split("_____")
    output << "<span class=\"part\">#{parts[0]}</span><input class=\"blank\" /><span class=\"part\">#{parts[1]}</span>"
    output << "<div class=\"answer hidden\">#{answer}</div>"
    output << "</div></div>"
  }
  output << "<button class=\"mobile hidden\">&gt;</button>"

  output << "</div></div></div>"

  output << "<div class=\"hideContainer invisible\"><div class=\"mobile hide\">Hide Text</div></div>"

  output << "</body></html>"

  output.close

  puts "Page created. Quitting."
end
