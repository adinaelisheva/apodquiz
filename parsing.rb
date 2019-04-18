# -*- coding: utf-8 -*-
def removeExtraneousStuff(text)
  retText = ""
  isInScript = false
  isInComment = false

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
    if (not isInComment and not isInScript) 
      retText += c
    end
  }
  return retText
end

def isValidSentence(s)
  s = s.downcase()
  if s.length < 20 or 
      s.length > 300
      s.include?("   ")
    return false
  end
  # this is to prevent citations, eg: Bob Smith (1999 ed.).
  if (s.split(" ").length < 11 and /^[^()]+\([^()]+\)$/.match(s))
    return false
  end
  # This is to prevent mag. X from indicating a sentence
  if s.end_with?("mag")
    return false
  end
  return true
end

def isValidQuestion(q, a)
  if not q or not a or q.split(" ").length <= 7
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
    "Accessed on line"
  ]
  badTerms.each { |b| 
    if q.include?(b)
      return false
    end
  }
  badAnswers = ["it", "he", "she", "they", "this", "that", "there", "these", "those", "you"]
  badAnswers.each { |b|
    if a.start_with?(b) or a.end_with?(b)
      return false
    end
  }
  return true
end

def createQuestions(text, url)
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
    head = ""
    conjunctions = ["when", "and", "but", "because", "since", "if", "with", "although", "however,","furthermore,","as"]
    conjunctions.each { |c|
      if s.downcase().start_with?(c)
        len = c.length + 1 #add 1 for a space
        head = s[0...len]
        s = s[len...s.length]
      end
    }
    if (isValidSentence(s))
      s.gsub!(/ +/, " ")
      copulas = ["is","are","was","were","will be","should","should be"]
      copulaInd = nil
      copulaLen = 0
      copulas.each { |c|
        if not copulaInd
          copulaInd = s.index(/\b#{c}\b/)
          copulaLen = c.length
        end
      }
      if (copulaInd)
        part1 = s[0...copulaInd]
        part2 = s[copulaInd + copulaLen...s.length]
        len1 = part1.split(" ").length
        len2 = part2.split(" ").length
        if (len1 < 5 and not part1.include?(","))
          question = "#{head}_____ #{s[copulaInd...s.length]}"
          answer = part1
        elsif (len2 < 5 and not part2.include?(","))
          question = "#{head}#{s[0..copulaInd + copulaLen]} _____"
          answer = part2
        end
      end

      decimalInd = s.index(decimalRegex)
      if (not question and decimalInd)
        decimal = s.match(decimalRegex)[1]
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
        end
      end

      if (isValidQuestion(question, answer))
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
