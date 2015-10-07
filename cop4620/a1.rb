require 'bigdecimal';
class A1
  attr_accessor :input, :raw_input, :paren_level, :formatted, :bracket_level, :bracket_level

  # initilize the world
  def initialize(input)
    @raw_input = input
    @paren_level = 0
    @bracket_level = 0
    @brace_level = 0
  end

  # Finds where all the comments are located in the given program
  # Returns an array of length 2 tuples
  def find_comments
    start_index = 0
    indicies = []
    comment_level = 0
    while start_index < raw_input.length
      end_index = start_index + 1
      comment_level = 0 if comment_level < 0
      two_chars = raw_input[start_index..end_index]

      if two_chars == '/*'
        comment_level += 1
        if comment_level == 1
          start_comment_index = start_index
        end
        start_index += 1
      end

      if two_chars == '*/'
        comment_level -= 1
        if comment_level == 0
          indicies = indicies + [[start_comment_index, end_index]]
        end
        start_index += 1
      end

      if two_chars == '//'
        start_comment_index = start_index
        until raw_input[start_index] == "\n"[0] || start_index == raw_input.length-1 do
          start_index += 1
        end
        indicies = indicies + [[start_comment_index, start_index]]
      end
      start_index += 1
    end
    indicies
  end

  # Convert comments to be " ". That way they can just be consumed.
  def process_comments
    comments = find_comments
    program = raw_input.dup
    comments.each do |start, stop|
      (start..stop).each do |index|
        program[index] = " "
      end
    end
    program
  end

  # Returns only logical lines; ignore blank stuff
  def lines
    format_raw!.map(&:strip).delete_if { |a| a == "" }
  end

  # returns true if the given token is a keyword. (Key words must be lowercase)
  def keyword?(word)
    return word.upcase if [
      "true",
      "false",
      "int",
      "void",
      "return",
      "if",
      "else",
      "float",
      "while",
    ].include? word
  end

  def keyword_output(word)
    if keyword?(word)
      return "KEYWORD: #{word.upcase}\n"
    end
    ""
  end

  # checks matching token levels for (){}[]
  def paren_brace_bracket_output(token)
    result = ""
    token.each_char do |c|
      result += "#{c}\n" if c == '(' || c == ')'
      @paren_level += 1 if c == '('
      @paren_level -= 1 if c == ')'
      @paren_level = -100 if @paren_level < 0
    end

    token.each_char do |c|
      result += "#{c}\n" if c == '[' || c == ']'

      @bracket_level += 1 if c == '['
      @bracket_level -= 1 if c == ']'
      @bracket_level = -100 if @bracket_level < 0
    end

    token.each_char do |c|
      result += "#{c}\n" if c == '{' || c == '}'

      @brace_level += 1 if c == '{'
      @brace_level -= 1 if c == '}'
      @brace_level = -100 if @brace_level < 0
    end
    result
  end

  # Returns true if the given token is a logical operator
  def logical_operator?(token)
    return token if [
      '==',
      '!=',
      '>=',
      '<=',
      '>',
      '<',
    ].include? token
  end

  # Returns true if the given token is a special character
  def special_char?(char)
    return char if [
      '=',
      '(',
      ')',
      ']',
      '[',
      '{',
      '}',
      '*',
      '/',
      '+',
      '-',
      ','
    ].include?(char)
  end

  def identifier_output(token)
    return "IDENTIFIER: #{token}\n" unless \
      keyword?(token) || \
      logical_operator?(token) || \
      special_char?(token) || \
      number?(token)
    ""
  end

  # Regex to match number (supports floating points)
  # The following are sample matches
  # 1
  # 1.3
  # 2.4E1
  # 2.4E3
  # 2E+3
  # 1.2E-4
  def number?(number)
    !!number.match(/^\d+((\.\d+)?)(E(\+|\-)?\d+)?$/)
  end

  def special_char_output(token)
    return "#{token}\n" if special_char?(token) &&
      ! ['(', ')', '{', '}', '[', ']'].include?(token)
    ""
  end

  def number_output(number)
    return "CONSTANT: #{number}\n" if number?(number)
    ""
  end

  # format the given program using given regexes
  # This mostly just adds spaces so tokens can be
  # detected via whitespace
  # Sidenote: I really hate parsing char by char
  def format_raw!
    result = ""
    result = process_comments
    result = result.gsub(/\}/, '};') # put ; after }
    result = result.gsub(/\{/, '{;') # put ; before }
    result = result.gsub(/([^=!><])=([^=])/, '\1 = \2')
    result = result.gsub(/(.)!=(.)/, '\1 != \2') # puts spaces around all '!='
    result = result.gsub(/([^\s])==([^\s])/, '\1 == \2') # put spaces around == compares
    result = result.gsub(/==([^\s])/, ' == \1') # put spaces after == compares
    result = result.gsub(/([^\s])==/, '\1 == ') # put spaces before == compares
    result = result.gsub(/(.)<=/, '\1 <=') # spaces before <=
    result = result.gsub(/(.)>=/, '\1 >=') # spaces before >=
    result = result.gsub(/<=(.)/, '<= \1') # spaces after <=
    result = result.gsub(/>=(.)/, '>= \1') # spaces after >=

    result = result.gsub(/\*([^\s])/, '* \1') # put spaces after *
    result = result.gsub(/\/([^\s])/, '/ \1') # put spaces after /
    result = result.gsub(/([^E])\+([^\s])/, '\1+ \2') # put spaces after +
    result = result.gsub(/([^E])\+([^\s])/, '\1+ \2') # put spaces after +
    result = result.gsub(/([^E])\-([^\s])/, '\1- \2') # put spaces after -
    result = result.gsub(/([^E])\-([^\s])/, '\1- \2') # put spaces after -

    result = result.gsub(/([^\s])\*/, '\1 *') # put spaces before *
    result = result.gsub(/([^\s])\//, '\1 /') # put spaces before /
    result = result.gsub(/([^\sE])\+/, '\1 +') # put spaces before +
    result = result.gsub(/([^\sE])\-/, '\1 -') # put spaces before -


    result = result.gsub(/\)([^\s])/, ') \1') # space after )
    result = result.gsub(/\(([^\s])/, '( \1') # space after (
    result = result.gsub(/([^\s])\(/, '\1 (') # space before (
    result = result.gsub(/([^\s])\)/, '\1 )') # space before )

    result = result.gsub(/\)([^\s])/, ') \1') # space after )
    result = result.gsub(/\(([^\s])/, '( \1') # space after (
    result = result.gsub(/([^\s])\(/, '\1 (') # space before (
    result = result.gsub(/([^\s])\)/, '\1 )') # space before )

    result = result.gsub(/\]([^\s])/, '] \1') # space after ]
    result = result.gsub(/\[([^\s])/, '[ \1') # space after [
    result = result.gsub(/([^\s])\[/, '\1 [') # space before [
    result = result.gsub(/([^\s])\]/, '\1 ]') # space before ]

    result = result.gsub(/\]([^\s])/, '] \1') # space after ]
    result = result.gsub(/\[([^\s])/, '[ \1') # space after [
    result = result.gsub(/([^\s])\[/, '\1 [') # space before [
    result = result.gsub(/([^\s])\]/, '\1 ]') # space before ]

    result = result.gsub(/\{([^\s])/, '{ \1') # space after {
    result = result.gsub(/\}([^\s])/, '} \1') # space after }
    result = result.gsub(/([^\s])\{/, '\1 {') # space before {
    result = result.gsub(/([^\s])\}/, '\1 }') # space before }

    result = result.gsub(/([^\s])\,/, '\1 ,') # space before ,
    result = result.gsub(/\,([^\s])/, ', \1') # space after ,

    result = result.gsub(/\)\)/, ' ) ) ') # case ))
    result = result.gsub(/\)\)/, ' ) ) ')
    result = result.gsub(/\)\)/, ' ) ) ')
    result = result.gsub(/\)\)/, ' ) ) ')
    result = result.gsub(/\)\)/, ' ) ) ')
    result = result.gsub(/\)\)/, ' ) ) ')
    result = result.gsub(/\)\)/, ' ) ) ')
    result = result.gsub(/\)\)/, ' ) ) ')
    result = result.gsub(/\)\)/, ' ) ) ')
    result = result.gsub(/\)\)/, ' ) ) ')
    result = result.gsub(/\)\)/, ' ) ) ')
    result = result.gsub(/\(\(/, ' ( ( ') # case ((
    result = result.gsub(/\(\(/, ' ( ( ')
    result = result.gsub(/\(\(/, ' ( ( ')
    result = result.gsub(/\(\(/, ' ( ( ')
    result = result.gsub(/\(\(/, ' ( ( ')
    result = result.gsub(/\(\(/, ' ( ( ')
    result = result.gsub(/\(\(/, ' ( ( ')
    result = result.gsub(/\(\(/, ' ( ( ')
    result = result.gsub(/\(\(/, ' ( ( ')
    result = result.gsub(/\(\(/, ' ( ( ')
    result = result.gsub(/\(\(/, ' ( ( ')
    result = result.gsub(/\(\(/, ' ( ( ')
    result = result.gsub(/\(\(/, ' ( ( ')
    result = result.gsub(/\((\s+)?\)/, ' ( ) ') # case ()
    result = result.gsub(/\s\s/, ' ') # remove extra spaces
    result = result.gsub(/\s+/, ' ')
    result = result.delete("\n").split(';')
    result.map(&:strip)
  end

  def logical_operator_output(token)
    operator = logical_operator?(token)
    return operator + "\n" if ! operator.nil?
    ""
  end

  # Checks whether the given token contains
  # characters that belong in the language
  def valid_token?(token)
    !token.match(/[^A-Za-z0-9!=<>\n;\(\)\*\-\+\/\.\}\{\]\[],/)
  end

  def to_s
    result = ""
    separated_lines = lines
    (0..lines.length-1).each do |i|
      result += "INPUT: #{separated_lines[i].strip};\n"
      for token in lines[i].split(' ')
        current_token_result = ""

        current_token_result += keyword_output(token)
        current_token_result += paren_brace_bracket_output(token)
        current_token_result += special_char_output(token)
        current_token_result += identifier_output(token)
        current_token_result += number_output(token)
        current_token_result += logical_operator_output(token)

        if ! valid_token?(token)
          current_token_result = "ERROR processing '#{token}' on line #{i+1}!\n"
        end
        result += current_token_result
      end
      result += "ERROR: Mismatched parenthesis on line #{i+1}\n" if @paren_level != 0
      result += "ERROR: Mismatched brackets on line #{i+1}\n" if @bracket_level != 0
      @paren_level = 0
      @bracket_level = 0
      result += ";\n"
    end
    result += "ERROR: Mismatched braces\n" if @brace_level != 0
    result \
      .gsub(/\{(\s*);/, '{') \
      .gsub(/\}(\s*);/, '}')

  end

  def to_a
    to_s.split("\n")
  end
end
