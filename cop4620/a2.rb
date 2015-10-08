class A2

  include ::A2Transitions
  include Constants

  def initialize(input)
    @tokens = A1.new(input).to_a + ["EOF"]
    @current_token = 0
  end

  def next_token
    @tokens[@current_token+1]
  end

  def next_next_token
    @tokens[@current_token+2]
  end

  def current_token
    token = @tokens[@current_token]
    if token_type(token) == 'INPUT' && ! ['(', ')', '}', '{'].include?(token)
      puts "", "ACCEPT" + ("*"*25) + token, "" if $debug
      @current_token += 1
      return current_token
    end
    @tokens[@current_token]
  end

  def previous_token()
    @tokens[@current_token-1]
  end

  def back
    @current_token -= 1
  end

  # accepts the given token, provided that it matches the current_token
  # otherwise raises a RejectError
  def accept(token=current_token)
    if token == current_token
      puts "", "ACCEPT" + ("*"*25) + current_token, "" if $debug
      @current_token += 1
    else
      raise A2Transitions::RejectError
    end
  end

  def around(num)
    (@current_token-num..@current_token+num).each do |i|
      puts @tokens[i] if $debug
    end
  end

  # accepts only if the given token is the current_token
  def soft_accept(token=current_token)
    (token == current_token).tap do |result|
      accept if result
    end
  end

  def reject
    raise A2Transitions::RejectError
  end

  def token_text
    current_token && current_token.split(":")[1].strip
  end

  def token_type(token=current_token)
    token && token.split(":") && token.split(":")[0]
  end

  def to_s
    # !! This calls the program method in a2_transitions.rb !!
    # All the transitions are contained there
    begin
      goto :start
    rescue A2Transitions::RejectError
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

  def print(method)
    method = method.to_s
    debug = ("GOTO: " + method + (" " * (25-method.length))) + current_token
    puts debug if $debug
  end

  def goto(method)
    print(method)
    send(method)
  end
end
