module A2Transitions
  include ::Constants

  def start
    goto :declaration_list
  end

  def var_declaration
    goto :type_specifier
    goto :id

    if current_token == '['
      accept "["
      goto :integer
      accept "]"
    end
    accept ";"
  end

  def func_declaration
    goto :type_specifier
    goto :id
    accept "("
    goto :params
    accept ")"
    goto :compound_statement
    accept if token_type == 'INPUT'
  end

  def params
    return if current_token == ')' || token_type == 'INPUT'
    return soft_accept VOID if previous_token == '(' and next_token == ')'

    goto :type_specifier
    goto :id
    soft_accept LEFT_BRACKET
    soft_accept RIGHT_BRACKET
    goto :params if soft_accept ','
  end

  def local_declarations
    accept if token_type == 'INPUT'
    return if current_token == '}'
    goto :var_declaration
    goto :local_declarations while type_keyword_specified?
  end

  def compound_statement
    accept "{"
    goto :local_declarations if type_keyword_specified?
    goto :statement_list unless current_token == '}'
    accept "}"
  end

  def statement_list
    goto :statement
    statement_list unless current_token == '}'
  end

  def statement
    binding.pry
    reject if token_type != 'KEYWORD'
    goto :return_statement if current_token == RETURN
    goto :selection_statement if current_token == SELECTION_STATEMENT
  end

  def return_statement
    accept RETURN
    goto :expression if current_token != ';'
    accept ";"
  end

  def selection_statement
    accept SELECTION_STATEMENT
    accept LEFT_PAREN
    goto :expression
    accept RIGHT_PAREN
    goto :statement
    if current_token == ELSE
      accept ELSE
      goto :statement
    end
  end

  def expression_statement
    goto :expression
  end

  def expression
    if current_token(2) == '=' # assignment
      goto :var
      accept '='
      goto :expression
    else
      goto :simple_expression
    end
  end

  def simple_expression
    goto :additive_expression
    if relop?
      accept
      goto :additive_expression
    end
  end

  def additive_expression
    goto :term
    goto :addop
    goto :term
  end

  def relop
    accept if relop? or reject
  end

  def term
    goto :factor
    goto :mulop
    goto :factor
  end

  def var
    goto :id
    if current_token == LEFT_BRACKET
      accept LEFT_BRACKET
      goto :integer
      accept RIGHT_BRACKET
    end
  end

  def factor
    if current_token == LEFT_PAREN
      accept LEFT_PAREN
      goto :expression
      accept RIGHT_PAREN
    elsif @tokens[@current_token+2] == LEFT_PAREN
      goto :call
    elsif token_type == 'IDENTIFIER'
      goto :var
    else
      goto :number
    end
  end

  def number
    accept if token_type == 'CONSTANT'
  end

  def call
    goto :id
    accept LEFT_PAREN
    goto :args
    accept RIGHT_PAREN
  end

  def args
    goto :expression
    goto :args if current_token == ','
  end

  def mulop
    accept if ['*', '/'].include? current_token
  end

  def addop
    accept if ['+', '-'].include? current_token
  end

  def integer
    accept if token_type == 'CONSTANT' && token_text.gsub(/[0-9]/, '') == '' or reject
  end

  def constant
    accept if token_type == 'CONSTANT' or reject
  end

  def id
    accept if token_type == "IDENTIFIER" or reject
  end

  def type_specifier
    accept if type_keyword_specified? or reject
  end

  def declaration_list
    accept if token_type == "INPUT" # get rid of input statement

    goto :declaration
    goto :declaration_list if token_type == 'KEYWORD' || token_type == 'INPUT'
  end

  def declaration
    if current_token(+2) == '('
      goto :func_declaration
    else
      goto :var_declaration
    end
  end
end
