# this file describes the transitions between methods.
# Transitions between states are reached using a custom build goto construct.
# This was primarility for debugging purposes.
# The functinos defined here correspond closely the the grammar
module A2Transitions
  class RejectError < RuntimeError; end;
  include ::Constants

  # this is the "Start" symbol
  def start
    goto :declaration_list
  end

  def var_declaration
    goto :type_specifier
    goto :id

    if current_token == '['
      accept "["
      goto :number
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
    action ||= :iteration_statement if current_token == WHILE
    action ||= :compound_statement if current_token == '{'
    action ||= :expression_statement
    goto action
  end

  def iteration_statement
    accept WHILE
    accept '('
    goto :expression
    accept ')'
    goto :statement
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
    return if [ ')', ';', '}', ']', ','].include? current_token

    if next_token == '[' || next_token == '='
      goto :simple_expression
      goto :expression if soft_accept '='
    end

    if current_token == '='

      accept '='
      goto :expression
    else
      goto :simple_expression
    end
  end

  def simple_expression
    return if [')', ';',  '}',  ']', ','].include? current_token
    goto :additive_expression
    if relop?
      goto :relop
      goto :additive_expression
      reject if [
        ']',
        ',',
        '<=',
        '>=',
        '<',
        '>',
        '!=',
        '+',
        '-',
        '==',
        '=',
      ].include? current_token
    end
  end

  def additive_expression
    goto :term
    while addop?
      goto :addop
      goto :term
    end
  end

  def relop
    accept if relop? or reject
  end

  def term
    goto :factor
    while mulop?
      goto :mulop
      goto :factor
    end
  end

  def var
    goto :id
    if current_token == LEFT_BRACKET
      accept LEFT_BRACKET
      goto :expression
      accept RIGHT_BRACKET
    end
  end

  def factor
    reject if ['*', '/', ')', ';', ']', ',', '<=', '>=', '<', '>', '!=', '+', '-', '=='].include? current_token
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
    accept if mulop? or reject
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
