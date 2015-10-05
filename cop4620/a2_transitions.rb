module A2Transitions
  def start
    goto :declaration_list
  end

  def declaration
    goto :type_specifier
    goto :id
    if current_token == "["
      accept("[")
      goto :integer
      accept("]")
    end
    if current_token == "("
      accept("(")
      goto :params
      accept(")")
      goto :compound_statement
    else
      accept(";)")
    end
  end

  def params
  end

  def compound_statement
  end

  def integer
    accept if token_type == 'CONSTANT' && current_token.gsub(/[0-9]/, '') == ''
  end

  def constant
    accept if token_type == 'CONSTANT'
  end

  def id
    accept if token_type == "IDENTIFIER"
  end

  def type_specifier
    accept if [
      "KEYWORD: INT",
      "KEYWORD: VOID",
      "KEYWORD: FLOAT",
    ].include? current_token or reject
  end

  def declaration_list
    accept if token_type == "INPUT" # get rid of input statement

    goto :declaration
    goto :declaration_list if token_type == 'KEYWORD'
  end

end
