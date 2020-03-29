# -*- coding: utf-8 -*-
def removeExtraneousStuff(text)
  retText = ""
  isInScript = false
  isInComment = false
  isInTag = false

  text.each_char.with_index { |c, i|
    if (not isInScript and text[i..i+6] == "<script") 
      isInScript = true
    elsif (isInScript and text[i..i+7] == "</script")
      isInScript = false
    end
    if (not isInComment and text[i..i+4] == "<!--") 
      isInComment = true
    elsif (isInComment and text[i..i+3] == "-->")
      isInComment = false
    end
    if (not isInComment and not isInScript and text[i] == "<")
      isInTag = true
    elsif (isInTag and text[i] == ">")
      isInTag = false
      next
    end
    
    if (not isInComment and not isInScript and not isInTag) 
      retText += c
    end
  }
  return retText
end

def getImageOrVideoTag(imageParagraph)
  # first look for an image
  imageMatch = imageParagraph.match(/<br>\s*<a href="([^"]+)"/)
  if imageMatch
    image = imageMatch[1]
    if not image.start_with?("http") 
      image = "http://apod.nasa.gov/#{image}"
    end
    return "<img src=\"#{image}\">"
  end
  # otherwise it's probably a video or something, return the iframe
  iframeMatch = imageParagraph.match(/<iframe.+<\/iframe>/)
  if iframeMatch
    return iframeMatch[0]
  end
  return
end

def isValidSentence(s, verbose=false)
  s = s.downcase()
  if s.length < 20 or 
      s.length > 300
      s.include?("   ")
    if verbose
      puts "Not valid - Either length (#{s.length}) is bad or has too much whitespace"
    end
    return false
  end
  # this is to prevent citations, eg: Bob Smith (1999 ed.).
  if (s.split(" ").length < 11 and /^[^()]+\([^()]+\)$/.match(s))
    if verbose
      puts "Not valid - too much like a citation"
    end
    return false
  end
  # This is to prevent mag. X from indicating a sentence
  if s.end_with?("mag")
    if verbose
      puts "Not a real sentence - Mag. is an abbreviation :)"
    end
    return false
  end
  return true
end

def isValidQuestion(q, a, verbose=false)
  if not q or not a or q.split(" ").length <= 6
    if verbose and (not q or not a)
      puts "No copula, decimal, or ordinal found"
    elsif verbose
      puts "Not a valid question - too short"
    end
    return false
  end
  a = a.downcase().strip()
  badTerms = [
    "AstroBin index",
    "Byrd",
    "StellaNavigator",
    "for Windows",
    "your comment data",
    "Archived from the original",
    "Annual Progress Report",
    "Accessed on line",
    "permanently deleted",
    "post",
    "posts",
    "comment",
    "comments",
    "web sites",
    "Discover the cosmos",
  ]
  badTerms.each { |b| 
    if q.include?(b)
      if verbose
        puts "Not a valid question - includes bad term #{b}"
      end
      return false
    end
  }
  badAnswers = ["it", "he", "she", "they", "this", "that", "there", "these", "those", "you"]
  badAnswers.each { |b|
    if a.start_with?(b) or a.end_with?(b)
      if verbose
        puts "Not a valid question - starts or ends with unclear pronoun #{b}"
      end
      return false
    end
  }
  return true
end

def createQuestions(text, url, verbose=false)
  decimalRegex = /\b(-?[0-9,]+\.?[0-9]*(st|nd|rd|th)?)(%|lb|ms|s|kg|°|°C|°F|C|F|deg|ml)?\b/
  questions = []
  # scan for any punctuation, followed by space, followed by a capital letter, 
  # followed by stuff, followed by more punctuation and a space
  scanRegex = /[.!>,;] +[A-Z][A-z0-9., '-()]*?[.!;] /
  
  # Regexes don't allow for overlap, so have to scan for each sentence one at 
  # a time, then chop it off the front of the text
  while text.length > 0
    sentence = text[scanRegex, 0]
    sIndex = text.index(scanRegex)
    # cut off the punctuation on either end.
    if not sentence
      break
    end
    s = sentence[2...sentence.length-2].strip()
    if not s
      next
    end
    if verbose
      puts "\nLooking at sentence \"#{s}\""
    end
    head = ""
    conjunctions = ["when", "and", "but", "because", "since", "if", "with", "although", "however,","furthermore,","as"]
    conjunctions.each { |c|
      if s.downcase().start_with?("#{c} ") or s.downcase().start_with?("#{c},")
        len = c.length + 1 #add 1 for extra character
        head = s[0...len]
        s = s[len...s.length]
      end
    }
    if (isValidSentence(s, verbose))
      s.gsub!(/ +/, " ")
      copulas = [" is "," are "," was "," were "," will be "," should "," should be "," have been "," has been "," in "," of "," for "," with "," to "," from "," on "," since "," has "," had "," have "]
      copulaInd = nil
      copulaLen = 0
      copulas.each { |c|
        if not copulaInd
          copulaInd = s.index(/#{c}/)
          copulaLen = c.length
        end
      }
      if (copulaInd)
        if (verbose)
          puts "Found a copula! \"#{s[copulaInd ... copulaInd + copulaLen]}\" at #{copulaInd}"
        end
        part1 = s[0...copulaInd]
        part2 = s[copulaInd + copulaLen...s.length]
        len1 = part1.split(" ").length
        len2 = part2.split(" ").length
        if (len1 < 5 and not part1.include?(","))
          question = "#{head}_____#{s[copulaInd...s.length]}"
          answer = part1
        elsif (len2 < 5 and not part2.include?(","))
          question = "#{head}#{s[0..copulaInd + copulaLen - 1]}_____"
          answer = part2
        elsif verbose
          puts "Can't use - both sides are too long or include commas"
        end
      end

      decimalInd = s.index(decimalRegex)
      if (not question and decimalInd)
        decimal = s.match(decimalRegex)[1]
        if (verbose)
          puts "No copula, but found decimal #{decimal} at #{decimalInd}\""
        end
        part1 = s[0...decimalInd]
        part2 = s[decimalInd + decimal.length...s.length]
        question = "#{head}#{part1}_____#{part2}"
        answer = decimal.gsub(",","")
      end

      ordinals = ["first","second","third","fourth","fifth","sixth","seventh","eighth","ninth","tenth"]
      ordinalInd = nil
      ordinalLen = 0
      ordinals.each { |o|
        if not ordinalInd
          ordinalInd = s.index(/\b#{o}\b/)
          ordinalLen = o.length
        end
      }
      if (not question and ordinalInd)
        if (verbose)
          puts "No copulas or decmials, but found ordinal \"#{s[ordinalInd ... ordinalInd + ordinalLen]} at #{ordinalInd}\""
        end
        part1 = s[0...ordinalInd]
        part2 = s[ordinalInd + ordinalLen...s.length]
        len1 = part1.split(" ").length
        len2 = part2.split(" ").length
        if (len1 < 5 and not part1.include?(","))
          question = "#{head}_____ #{s[ordinalInd...s.length]}"
          answer = part1
        elsif (len2 < 5 and not part2.include?(","))
          question = "#{head}#{s[0..ordinalInd + ordinalLen]} _____"
          answer = part2
        elsif verbose
          puts "Can't use - both sides are too long or include commas"
        end
      end

      if question and verbose
        puts "Found question: #{question}"
      end
      if (isValidQuestion(question, answer, verbose))
        if verbose
          puts "Keeping it!"
        end
        questions.push([question + ".", answer])
      end
      question = nil
      answer = nil
    end
    text = text[sIndex+sentence.length-2...text.length]
  end
  commonsites = [
    "https://spaceplace.nasa.gov/oreo-moon/en/"
  ]
  if commonsites.include?(url)
    # if this is a commonly seen site, shuffle the questions so we don't keep seeing the same ones
    # (this may lead to lower quality questions, but repeats are even worse)
    questions.shuffle()
  else
    questions.sort { |a, b| b[0].length <=> a[0].length }
  end
  return questions
end


def grabQuestions(text, url, verbose=false)
  # The wikipedia references section is full of bad content. Kill it.
  if url.start_with?("https://en.wikipedia.org/wiki/")
    i = text.index("id=\"References\"")
    if i
      text = text[0...i]
    end
  end

  text = removeExtraneousStuff(text)
  text.gsub!(/ <[^>]*> */, " ")
  text.gsub!(/ *<[^>]*> /, " ")
  text.gsub!(/<[^>]>/, "")
  text.gsub!(/\n/," ")
  text.gsub!(/ +/," ")

  puts "creating questions..."
  questions = createQuestions(text, url, verbose)
  puts "created #{questions.length} questions"
  return questions
end