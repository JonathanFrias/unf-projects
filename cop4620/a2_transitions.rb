# this file describes the transitions between methods.
# Transitions between states are reached using a custom build goto construct.
# This was primarility for debugging purposes.
# The functions defined here correspond closely the the grammar
module A2Transitions
  class RejectError < RuntimeError; end;
  include ::Constants
  attr_accessor :root_context, :current_context

  # this is the "Start" symbol
  def start
     @current_context = Context.new
     @root_context = RootContext.new
    goto :declaration_list
  end

  def var_declaration
    type = goto :type_specifier
    id = goto :id

    if current_token == '['
      accept "["
      goto :number
      accept "]"
    end
    accept ";"
    def_variable(type, id)
    type
  end

  def func_declaration
    new_context
    type = goto :type_specifier
    id = goto :id

    accept "("
    params = goto :params, []
    accept ")"
    def_function(type, id, params || [])
    goto :compound_statement

    @current_context = current_context.prev_context
    type
  end

  def params(start_value=[])
    return start_value if previous_token == '(' and next_token == ')' && soft_accept(VOID)

    type = goto :type_specifier
    id = goto :id
    start_value << type
    soft_accept LEFT_BRACKET
    soft_accept RIGHT_BRACKET
    def_variable(type, id)
    goto :params, start_value if soft_accept ','
    start_value
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
    type = 'VOID'
    type = goto(:expression) if current_token != ';'
    defined_return_type = root_context.functions[current_context.id].return_type
    reject("returned type '#{type}' does not match function defition '#{current_context.id}'->'#{defined_return_type}'") if current_context.return_type != type
    accept ";"
    type
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
    result = goto :expression unless current_token == ';'
    accept ';'
    result
  end

  def expression
    return if [ ')', ';', '}', ']', ','].include? current_token
    result = nil

    if next_token == '[' || next_token == '='
      result = goto :simple_expression
      result = goto :expression if soft_accept '='
    end

    result ||= goto :simple_expression
    result
  end

  def simple_expression
    return if [')', ';',  '}',  ']', ','].include? current_token
    type1 = goto :additive_expression
    if relop?
      goto :relop
      type2 = goto :additive_expression
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
      reject("Cannot compare #{type1} against #{type2}") if type2 != type1
    end
    type1
  end

  def additive_expression
    type1 = goto :term
    while addop?
      goto :addop
      type2 = goto :term
      reject("Cannot add #{type1} and #{type2}") if type1 != type2
    end
    type1
  end

  def relop
    accept if relop? or reject
  end

  def term
    type1 = goto :factor
    while mulop?
      goto :mulop
      type2 = goto :factor
      reject("Cannot multiply #{type1} with #{type2}") if type1 != type2
    end
    type1
  end

  def var
    id = goto :id
    if current_token == LEFT_BRACKET
      accept LEFT_BRACKET
      goto :expression
      accept RIGHT_BRACKET
    end

    #TODO use prev context

    reject("Could not find #{id}") if current_context.variables[id].nil?
    current_context.variables[id]
  end

  def factor
    result = 'VOID'
    reject if ['*', '/', ')', ';', ']', ',', '<=', '>=', '<', '>', '!=', '+', '-', '=='].include? current_token
    if current_token == LEFT_PAREN
      accept LEFT_PAREN
      result = goto :expression
      accept RIGHT_PAREN
      result
    elsif current_token.size == 1
      result
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
    result = 'INT' if integer?
    result ||= 'FLOAT'
    accept if token_type == 'CONSTANT' or reject
    result
  end

  def call
    id = goto :id
    accept LEFT_PAREN
    reject("function #{id} not defined") if root_context.functions[id].nil?
    result = goto :args, root_context.functions[id].params.dup
    reject("argument count mismatch for function call #{id}") if result.count != 0
    accept RIGHT_PAREN
    root_context.functions[id].return_type
  end

  def args(params)
    return params if current_token == ')'
    type = goto :expression
    reject("failed to determine type of expression") if type.nil?
    current_arg_type = params.shift
    reject("'#{type}' does not match '#{current_arg_type}'") if type != current_arg_type
    goto :args, params if soft_accept ','
    params
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
    token_text.tap do
      accept if token_type == "IDENTIFIER" or reject
    end
  end

  def type_specifier
    token_text.tap do
      accept if type_keyword_specified? or reject("type expected between '#{previous_token}' and '#{current_token}'")
    end
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

  def def_function(return_type, id, params)

    reject("function #{id} already defined") if root_context.functions[id]
    current_context.return_type = return_type
    current_context.id = id
    current_context.params = params

    root_context.functions[id] = current_context
  end

  def def_variable(type, id)
    reject("Variable #{id} already defined") if current_context.variables[id]
    current_context.variables[id] = type
  end

  def new_context
    prev_context = current_context
    @current_context = Context.new(prev_context)
  end

  def integer?
    token_type == 'CONSTANT' && token_text.gsub(/[0-9]/, '') == ''
  end
end
