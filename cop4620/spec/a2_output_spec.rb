require 'spec_helper'

$show_goto = 1
RSpec.describe A2 do

  context "accepts and rejects" do
    subject { described_class }

    let(:valid1) do
      "
        int a[2];

        int b;
      int main(void) {}
      float f(int x);

      void g( void) {};
      "
    end

    let(:inputs) do
      [
        # [0, "int a[1.2];" , "REJECT" ],
        # [1, "int b"       , "ACCEPT" ],
        # [2, "b b"         , "REJECT" ],
        # [3, "b b()"       , "REJECT" ],
        # [4, "int b()"     , "ACCEPT" ],
        # [5, "f()"         , "REJECT" ],
        [6, valid1        , "ACCEPT" ],
      ]
    end

    it "accepts and rejects" do
      inputs.each do |number, code, result, debug_level|
        if (string = subject.new(code).to_s) != result
          puts number.to_s + " FAILED"
        end
        expect(string).to eq result
      end
    end
  end
end
