class Context
  attr_accessor :return_type, :variables, :prev_context, :params, :current_param, :id

  def initialize(prev_context=nil)
    @id = nil
    @variables = {}
    @return_type = 'VOID'
    @prev_context = prev_context
    @params = []
    @current_param = 0
  end
end

class RootContext
  attr_accessor :functions, :variables

  def initialize
    @variables = {}
    @functions = {}
  end
end
