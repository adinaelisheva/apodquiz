def print(apodUrl, links, questions)
  filename = ARGV[1] ? ARGV[1] : "index.html"
  puts "Deleting old #{filename} (if any)"
  `rm #{filename}`
  
  puts "Creating new #{filename}"

  output = File.open(filename, "w")
  
  output << "<html><head>"
  
  output << "<title>APOD Quiz</title>"
  output << "<script src=\"index.js\"></script>"
  output << "<link href=\"https://fonts.googleapis.com/css?family=Bubblegum+Sans\" rel=\"stylesheet\">"
  output << "<link href=\"index.css\" type=\"text/css\" rel=\"stylesheet\">"  
  
  output << "</head><body>"

  links.each { |l|
    output << "<a class=\"link hidden\" href=\"#{l}\">#{l}</a>"
  }
  output << "<div class=\"main\">"

  output << "<div class=\"iframe\">"
  output << "<iframe width=\"800\" height=\"600\" src=\"#{apodUrl}\"></iframe>"
  output << "<div class=\"openlinks\">Open all links in tabs</div>"
  output << "</div>"

  output << "<div class=\"quiz hidden\">"
  output << "<h1>Quiz Time!</h1>"

  questions.each { |q|
    query = q[0]
    answer = q[1]
    output << "<div class=\"question\">"
    parts = query.split("_____")
    output << "<span class=\"part\">#{parts[0]}</span><input class=\"blank\" /><span class=\"part\">#{parts[1]}</span>"
    output << "<div class=\"answer hidden\">#{answer}</div>"
    output << "</div>"
  }

  output << "</div></div>"

  output << "</body></html>"

  output.close

  puts "Page created. Quitting."
end