class A4 < A2

  def initialize(input)
    super input
  end

  def codes
    start
    @assmebly
  end

  def to_s
    codes.map do |line|
      line.join("\t\t");
    end
  end
end
