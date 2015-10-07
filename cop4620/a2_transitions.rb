module A2Transitions
  class RejectError < RuntimeError; end;
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
  end

  def params
    return soft_accept VOID if previous_token == '(' and next_token == ')'

    goto :type_specifier
    goto :id
    soft_accept LEFT_BRACKET
    soft_accept RIGHT_BRACKET
    goto :params if soft_accept ','
  end

  def local_declarations
    return if current_token == '}'
    goto :var_declaration
    goto :local_declarations while type_keyword_specified?
  end

  def compound_statement
    accept "{"
    goto :local_declarations if type_keyword_specified?
    goto :statement_list if current_token != '}'
    accept "}"
  end

  def statement_list
    goto :statement
    statement_list unless current_token == '}'
  end

  def statement
    action ||= :return_statement if current_token == RETURN
    action ||= :selection_statement if current_token == SELECTION_STATEMENT
    action ||= :expression_statement
    goto action
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
    goto :expression unless current_token == ';'
    accept ';'
  end

  def expression
    if next_token == '=' || (@tokens[@current_token+4] == '=' && next_token == '[')
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
    if addop?
      goto :addop
      goto :term
    end
    goto :additive_expression if addop?
  end

  def relop
    accept if relop? or reject
  end

  def term
    goto :factor
    begin
      goto :mulop
      goto :factor
    rescue RejectError
    end
    goto :term if mulop?
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
    elsif current_token.size == 1
      return
    elsif token_type == 'IDENTIFIER' && next_token == LEFT_PAREN
      goto :call
    elsif token_type == 'IDENTIFIER'
      goto :var
    elsif token_type == 'CONSTANT'
      goto :number
    else
      reject
    end
  end

  def number
    accept if token_type == 'CONSTANT' or reject
  end

  def call
    goto :id
    accept LEFT_PAREN
    goto :args
    accept RIGHT_PAREN
  end

  def args
    return if current_token == ')'
    goto :expression
    goto :args if soft_accept ','
  end

  def mulop
    accept if mulop?
  end

  def mulop?
    ['*', '/'].include? current_token
  end

  def addop
    accept if addop?
  end

  def addop?
    ['+', '-'].include? current_token
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

    goto :declaration
    goto :declaration_list if token_type == 'KEYWORD'
  end

  def declaration
    if next_next_token == '('
      goto :func_declaration
    else
      goto :var_declaration
    end
  end
end
