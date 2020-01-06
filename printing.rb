def print(apodUrl, imageTag, explanation, links, title, date, questions)
  filename = ARGV[1] ? ARGV[1] : "index.html"
  puts "Deleting old #{filename} (if any)"
  `rm #{filename}`
  
  puts "Creating new #{filename}"

  output = File.open(filename, "w")
  
  printdate = "#{date[2..3]}/#{date[4..5]}/#{date[0..1]}"

  output << "<html><head>"
  
  output << "<title>APOD Quiz</title>"
  output << "<script src=\"index.js\"></script>"
  output << "<meta name=\"viewport\" content=\"width=device-width\">"
  output << "<link rel=\"shortcut icon\" type=\"image/x-icon\" href=\"favicon.ico\" />"
  output << "<link href=\"https://fonts.googleapis.com/css?family=Bubblegum+Sans\" rel=\"stylesheet\">"
  output << "<link href=\"index.css\" type=\"text/css\" rel=\"stylesheet\">"  
  
  output << "</head><body>"

  links.each { |l|
    output << "<a class=\"link hidden\" href=\"#{l}\">#{l}</a>"
  }

  output << "<div class=\"header\">"
  output << "<h1>Quiz Time!</h1>"
  output << "<h2>#{printdate} - #{title}</h2>"
  output << "</div>"

  output << "<div class=\"main\">"
  output << "<div class=\"apod\">"
  output << "<div class=\"imageOrVideo\">"
  output << imageTag
  output << "</div>"
  output << "<div class=\"explanation\">"
  output << "<p>#{explanation}</p>"
  output << "<div class=\"openlinks\">Open all links in tabs</div>"
  output << "</div>"
  output << "</div>"
  output << "</div>"

  output << "<div class=\"quiz hidden\">"
  output << "<div class=\"score\"><span class=\"num\">0</span> of <span class=\"whole\"></span></div>"
  output << "<div class=\"finished invisible\">100%!</div>"

  output << "<div class=\"questions\">"
  output << "<button class=\"mobile\">&lt;</button>"
  questions.each { |q|
    query = q[0]
    answer = q[1].downcase().tr("abcdefghijklmnopqrstuvwxyz0123456789", "nopqrstuvwxyz0123456789abcdefghijklm") #encode
    output << "<div class=\"question\">"
    parts = query.split("_____")
    output << "<span class=\"part\">#{parts[0]}</span><input class=\"blank\" /><span class=\"part\">#{parts[1]}</span>"
    output << "<div class=\"answer hidden\">#{answer}</div>"
    output << "</div>"
  }
  output << "<button class=\"mobile\">&gt;</button>"

  output << "</div></div></div>"

  output << "<div class=\"hideContainer\"><div class=\"mobile hide\">Hide Text</div></div>"

  output << "</body></html>"

  output.close

  puts "Page created. Quitting."
end
