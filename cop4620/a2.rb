
class A2
  include ::A2Transitions

  def initialize(input)
    @tokens = A1.new(input).to_a
    @current_token = 0
  end

  def current_token(offset=0)
    @tokens[@current_token+offset]
  end

  def accept(token=current_token)
    if token == current_token
      puts "ACCEPT              #{current_token}" if $show_accept
      @current_token += 1
    else
      raise "REJECT"
    end
  end

  def reject
    raise "REJECT"
  end

  def token_type
    current_token.split(":")[0]
  end

  def to_s
    # !! This calls the program method in a2_transitions.rb !!
    # All the transitions are contained there
    begin
      goto :start
    rescue
      "REJECT"
    end

    # if the above program didn't error, we're in the clear!
    if last_token?
      "ACCEPT"
    else
      "REJECT"
    end
  end

  def last_token?
    @current_token == @tokens.count-1
  end

  def goto(method)
    method = method.to_s
    puts (method + (" " * (20-method.length))) + current_token if $show_goto
    send(method)
  end
end
