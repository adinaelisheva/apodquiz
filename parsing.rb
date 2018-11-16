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
  if (s.length < 20 or 
      s.length > 300 or 
      s.include?("   "))
    return false
  end
  badstarts = ["it", "he", "she", "they", "this", "that", "there", "these", "those"]
  badstarts.each { |b|
    if s.start_with?(b)
      return false
    end
  }
  return true
end

def createQuestions(text)
  decimalRegex = /\b-?[0-9,]+\.?[0-9]*\b/
  questions = []
  # scan for any punctuation, followed by space, followed by a capital letter, 
  # followed by stuff, followed by more punctuation and a space
  scanRegex = /[.!>,;] +[A-Z][A-z0-9., '-()]*?[.!:;] /
  while text.length > 0
    sentence = text[scanRegex, 0]
    sIndex = text.index(scanRegex)
    if not sentence
      break
    end
    s = sentence[2...sentence.length-2]
    head = ""
    conjunctions = ["when", "and", "but", "because", "since", "if"]
    conjunctions.each { |c|
      if s.downcase().start_with?(c)
        len = c.length + 1 #add 1 for a space
        head = s[0...len]
        s = s[len...s.length]
      end
    }
    if (isValidSentence(s))
      s.gsub!(/ +/, " ")
      copulaInd = s.index(/\bis\b/)
      copulaLen = 2
      if (not copulaInd)
        copulaInd = s.index(/\bare\b/)
        copulaLen = 3
      end
      if (not copulaInd)
        copulaInd = s.index(/\bwas\b/)
        copulaLen = 3
      end
      if (not copulaInd)
        copulaInd = s.index(/\bwere\b/)
        copulaLen = 4
      end
      if (not copulaInd)
        copulaInd = s.index(/\bshould\b/)
        copulaLen = 6
      end
      if (not copulaInd)
        copulaInd = s.index(/\bshould be\b/)
        copulaLen = 9
      end
      if (copulaInd)
        part1 = s[0...copulaInd]
        part2 = s[copulaInd + copulaLen...s.length]
        len1 = part1.split(" ").length
        len2 = part2.split(" ").length
        if (len1 < 5 and not part1.include?(","))
          question = "#{head}_____ #{s[copulaInd...s.length]}"
          answer = part1
        elsif (len2 < 5 and not part2.include?(","))
          question = "#{head}#{s[0..copulaInd + copulaLen]} _____."
          answer = part2
        end
      end
      # TODO: support ordinal numbers
      decimalInd = s.index(decimalRegex)
      if (not question and decimalInd)
        decimal = s.match(decimalRegex)[0]
        part1 = s[0...decimalInd]
        part2 = s[decimalInd + decimal.length...s.length]
        question = "#{head}#{part1}_____#{part2}"
        answer = decimal
      end
      if (question and 
          question.split(" ").length > 5 and
          not question.include?("StellaNavigator") and
          not question.include?("for Windows") and
          not question.include?("your comment data"))
        questions.push([question, answer])
      end
      question = nil
      answer = nil
    end
    text = text[sIndex+sentence.length-2...text.length]
  end
  questions.sort { |a, b| b[0].length <=> a[0].length }
  return questions
end