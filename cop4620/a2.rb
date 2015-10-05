class A2
  class RejectError < RuntimeError; end;

  include ::A2Transitions
  include Constants

  def initialize(input)
    @tokens = A1.new(input).to_a + ["EOF"]
    @current_token = 0
  end

  def next_token(offset=1)
    current_token offset
  end

  def current_token(offset=0)
    return @tokens[@current_token+offset]
  end

  def previous_token(offset=-1)
    current_token(offset)
  end

  # accepts the given token, provided that it matches the current_token
  # otherwise raises a RejectError
  def accept(token=current_token)
    if token == current_token
      puts "", "ACCEPT" + ("*"*25) + current_token, "" if $show_accept
      @current_token += 1
    else
      raise RejectError
    end
  end

  # accepts only if the given token is the current_token
  def soft_accept(token=current_token)
    (token == current_token).tap do |result|
      accept
    end
  end

  def reject
    raise RejectError
  end

  def token_text
    current_token && current_token.split(":")[1].strip
  end

  def token_type
    current_token && current_token.split(":")[0]
  end

  def to_s
    # !! This calls the program method in a2_transitions.rb !!
    # All the transitions are contained there
    begin
      goto :start
    rescue RejectError
      return "REJECT"
    end

    # if the above program didn't error, we're in the clear!
    if last_token?
      "ACCEPT"
    else
      "REJECT"
    end
  end

  def last_token?
    current_token == "EOF"
  end

  def relop?
    [
      "<=",
      "<",
      ">",
      ">=",
      "==",
      "!=",
    ].include? current_token
  end

  def type_keyword_specified?
    [INT, VOID, FLOAT].include? current_token
  end

  def try(method)
    current_location = @current_token
    begin
      goto method
      true
    rescue
      @current_token = current_location
      false
    end
  end

  def goto(method)
    method = method.to_s
    puts ("GOTO: " + method + (" " * (25-method.length))) + current_token if $show_goto
    send(method)
  end
end
