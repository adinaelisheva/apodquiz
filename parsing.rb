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

def createQuestions(text)
  decimalRegex = /\b-?[0-9,]+\.?[0-9]*\b/
  questions = []
  # scan for any punctuation, followed by space, followed by a capital letter, 
  # followed by stuff, followed by more punctuation and a space
  text.scan(/[.!>,;] [A-Z][A-z0-9., '-()]*?[.!] /) { |s| 
    s = s[2...s.length]
    if (s.length > 20 and 
      s.length < 300 and 
      not s.include?("  ") and 
      not s.start_with?("It") and 
      not s.start_with?("He") and 
      not s.start_with?("She") and 
      not s.start_with?("They") and 
      not s.start_with?("This") and 
      not s.start_with?("That") and 
      not s.start_with?("There") and 
      not s.start_with?("These") and 
      not s.start_with?("Those"))
        # TODO: add a thing where if a sentence starts with a conjunction (And, But, Because, Since, etc) just
        # skip them in your counting. Eg "Because hydrogen is awesome" --> "Because ___ is awesome"
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
        if (copulaInd)
          part1 = s[0...copulaInd]
          part2 = s[copulaInd + copulaLen...s.length]
          len1 = part1.split(" ").length
          len2 = part2.split(" ").length
          if (len1 < 5 and not part1.include?(","))
            question = "_____ #{s[copulaInd...s.length]}"
            answer = part1
          elsif (len2 < 5 and not part2.include?(","))
            question = "#{s[0..copulaInd + copulaLen]} _____."
            answer = part2
          end
        end
        # TODO: support ordinal numbers
        decimalInd = s.index(decimalRegex)
        if (not question and decimalInd)
          decimal = s.match(decimalRegex)[0]
          part1 = s[0...decimalInd]
          part2 = s[decimalInd + decimal.length...s.length]
          question = part1 + "_____" + part2
          answer = decimal
        end
        if (question and question.split(" ").length > 5)
          questions.push([question, answer])
        end
    end
  }
  if (questions.length < 4) 
    return questions
  end
  #TODO: sort on a score (decimals are good, the longer the better. Words can be good... somehow?)
  questions.sort { |a, b| a[0].length <=> b[0].length }
  return [questions[0], questions[1], questions[2]]
end