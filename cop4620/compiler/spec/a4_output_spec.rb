require 'spec_helper'
RSpec.describe A4 do
  subject { described_class.new(input).codes.map { |x| x[1..-1] } }

  context "can do addition" do
    let(:input) do
      "
        void main(void) {
          int a;
          a = 1+2+3+4;
        }
      "
    end

    it "runs" do
      expect(subject).to eq [
        ["FUNC"   , "main" , "VOID" , "0"    ] ,
        ["BLOCK"  , ""     , ""     , ""     ] ,
        ["ALLOC"  , "4"    , ""     , "a"    ] ,
        ["ADD"    , "1"    , "2"    , "_t1"  ] ,
        ["ADD"    , "_t1"  , "3"    , "_t2"  ] ,
        ["ADD"    , "_t2"  , "4"    , "_t3"  ] ,
        ["ASSIGN" , "_t3"  , ""     , "a"    ] ,
        ["RETURN" , ""     , ""     , "VOID" ] ,
        ["END"    , "BLOCK", ""     , ""     ] ,
        ["END"    , "FUNC" , "main" , ""     ] ,
      ]
    end
  end

  context "can do subtraction" do
    let(:input) do
      "
        void main(void) {
          int a;
          a = 1-2-3-4;
        }
      "
    end

    it "runs" do
      expect(subject).to eq [
        ["FUNC"   , "main" , "VOID" , "0"    ] ,
        ["BLOCK"  , ""     , ""     , ""     ] ,
        ["ALLOC"  , "4"    , ""     , "a"    ] ,
        ["SUB"    , "1"    , "2"    , "_t1"  ] ,
        ["SUB"    , "_t1"  , "3"    , "_t2"  ] ,
        ["SUB"    , "_t2"  , "4"    , "_t3"  ] ,
        ["ASSIGN" , "_t3"  , ""     , "a"    ] ,
        ["RETURN" , ""     , ""     , "VOID" ] ,
        ["END"    , "BLOCK", ""     , ""     ] ,
        ["END"    , "FUNC" , "main" , ""     ] ,
      ]
    end
  end

  context "can do multiplication" do
    let(:input) do
      "
        void main(void) {
          int a;
          a = 1*2*3*4;
        }
      "
    end

    it "runs" do
      expect(subject).to eq [
        ["FUNC"   , "main" , "VOID" , "0"    ] ,
        ["BLOCK"  , ""     , ""     , ""     ] ,
        ["ALLOC"  , "4"    , ""     , "a"    ] ,
        ["MUL"    , "1"    , "2"    , "_t1"  ] ,
        ["MUL"    , "_t1"  , "3"    , "_t2"  ] ,
        ["MUL"    , "_t2"  , "4"    , "_t3"  ] ,
        ["ASSIGN" , "_t3"  , ""     , "a"    ] ,
        ["RETURN" , ""     , ""     , "VOID" ] ,
        ["END"    , "BLOCK", ""     , ""     ] ,
        ["END"    , "FUNC" , "main" , ""     ] ,
      ]
    end
  end

  context "can do division" do
    let(:input) do
      "
        void main(void) {
          int a;
          a = 1/2/3/4;
        }
      "
    end

    it "runs" do
      expect(subject).to eq [
        ["FUNC"   , "main" , "VOID" , "0"    ] ,
        ["BLOCK"  , ""     , ""     , ""     ] ,
        ["ALLOC"  , "4"    , ""     , "a"    ] ,
        ["DIV"    , "1"    , "2"    , "_t1"  ] ,
        ["DIV"    , "_t1"  , "3"    , "_t2"  ] ,
        ["DIV"    , "_t2"  , "4"    , "_t3"  ] ,
        ["ASSIGN" , "_t3"  , ""     , "a"    ] ,
        ["RETURN" , ""     , ""     , "VOID" ] ,
        ["END"    , "BLOCK", ""     , ""     ] ,
        ["END"    , "FUNC" , "main" , ""     ] ,
      ]
    end
  end

  context "can combine addition and multiplication" do
    let(:input) do
      "
        void main(void) {
          int a;
          a = 1+2*3-4/5*6;
        }
      "
    end

    it "runs" do
      expect(subject).to eq [
        ["FUNC"   , "main" , "VOID" , "0"    ] ,
        ["BLOCK"  , ""     , ""     , ""     ] ,
        ["ALLOC"  , "4"    , ""     , "a"    ] ,
        ["MUL"    , "2"    , "3"    , "_t1"  ] ,
        ["ADD"    , "1"    , "_t1"  , "_t2"  ] ,
        ["DIV"    , "4"    , "5"    , "_t3"  ] ,
        ["MUL"    , "_t3"  , "6"    , "_t4"  ] ,
        ["SUB"    , "_t2"  , "_t4"  , "_t5"  ] ,
        ["ASSIGN" , "_t5"  , ""     , "a"    ] ,
        ["RETURN" , ""     , ""     , "VOID" ] ,
        ["END"    , "BLOCK", ""     , ""     ] ,
        ["END"    , "FUNC" , "main" , ""     ] ,
      ]
    end
  end

  context "can combine arithmatic with functions!" do
    let(:input) do
      "
        int f(void) {
          return 3;
        }

        int g(void) {
          return 3;
        }
        void main(void) {
          int a;
          a = f()*3*g();
        }
      "
    end

    it "runs" do
      expect(subject).to eq [
        ["FUNC"   , "f"    , "INT"  , "0"    ] ,
        ["BLOCK"  , ""     , ""     , ""     ] ,
        ["RETURN" , ""     , ""     , "INT"  ] ,
        ["END"    , "BLOCK", ""     , ""     ] ,
        ["END"    , "FUNC" , "f"    , ""     ] ,
        ["FUNC"   , "g"    , "INT"  , "0"    ] ,
        ["BLOCK"  , ""     , ""     , ""     ] ,
        ["RETURN" , ""     , ""     , "INT"  ] ,
        ["END"    , "BLOCK", ""     , ""     ] ,
        ["END"    , "FUNC" , "g"    , ""     ] ,
        ["FUNC"   , "main" , "VOID" , "0"    ] ,
        ["BLOCK"  , ""     , ""     , ""     ] ,
        ["ALLOC"  , "4"    , ""     , "a"    ] ,
        ["CALL"   , "f"    , "0"    , "_t1"  ] ,
        ["MUL"    , "_t1"  , "3"    , "_t2"  ] ,
        ["CALL"   , "g"    , "0"    , "_t3"  ] ,
        ["MUL"    , "_t2"  , "_t3"  , "_t4"  ] ,
        ["ASSIGN" , "_t4"  , ""     , "a"    ] ,
        ["RETURN" , ""     , ""     , "VOID" ] ,
        ["END"    , "BLOCK", ""     , ""     ] ,
        ["END"    , "FUNC" , "main" , ""     ] ,
      ]
    end
  end

  context "while loops" do
    let(:input) do
      "
        void f(void) { }
        void main(void) {
          int a;
          while(a == 2) {
            f();
          }
        }
      "
    end

    it "runs" do
      expect(subject).to eq [
        ["FUNC"   , "f"    , "VOID" , "0"     ] ,
        ["BLOCK"  , ""     , ""     , ""      ] ,
        ["RETURN" , ""     , ""     , "VOID"  ] ,
        ["END"    , "BLOCK", ""     , ""      ] ,
        ["END"    , "FUNC" , "f"    , ""      ] ,
        ["FUNC"   , "main" , "VOID" , "0"     ] ,
        ["BLOCK"  , ""     , ""     , ""      ] ,
        ["ALLOC"  , "4"    , ""     , "a"     ] ,
        ["COMP"   , "a"    , "2"    , "_t1"   ] ,
        ["BRNEQ"  , ""     , ""     , "BACKP1"] ,
        ["BLOCK"  , ""     , ""     , ""      ] ,
        ["CALL"   , "f"    , "0"    , "_t2"   ] ,
        ["BR"     , ""     , ""     , "BACKP2"] ,
        ["END"    , "BLOCK", ""     , ""      ] ,
        ["RETURN" , ""     , ""     , "VOID"  ] ,
        ["END"    , "BLOCK", ""     , ""      ] ,
        ["END"    , "FUNC" , "main" , ""      ] ,
      ]
    end
  end

  context "if statements" do
    let(:input) do
      "
        void f(void) { }
        void main(void) {
          int a;
          if(a == 2) {
            f();
          }
        }
      "
    end

    it "runs" do
      expect(subject).to eq [
        ["FUNC"   , "f"    , "VOID" , "0"     ] ,
        ["BLOCK"  , ""     , ""     , ""      ] ,
        ["RETURN" , ""     , ""     , "VOID"  ] ,
        ["END"    , "BLOCK", ""     , ""      ] ,
        ["END"    , "FUNC" , "f"    , ""      ] ,
        ["FUNC"   , "main" , "VOID" , "0"     ] ,
        ["BLOCK"  , ""     , ""     , ""      ] ,
        ["ALLOC"  , "4"    , ""     , "a"     ] ,
        ["COMP"   , "a"    , "2"    , "_t1"   ] ,
        ["BRNEQ"  , ""     , ""     , "BACKP1"] ,
        ["BLOCK"  , ""     , ""     , ""      ] ,
        ["CALL"   , "f"    , "0"    , "_t2"   ] ,
        ["END"    , "BLOCK", ""     , ""      ] ,
        ["RETURN" , ""     , ""     , "VOID"  ] ,
        ["END"    , "BLOCK", ""     , ""      ] ,
        ["END"    , "FUNC" , "main" , ""      ] ,
      ]
    end
  end

  context "if statements" do
    let(:input) do
      "
        void f(void) { }
        void main(void) {
          int a;
          if(a == 2) {
            f();
          } else {
            f();
          }
        }
      "
    end

    it "runs" do
      expect(subject).to eq [
        ["FUNC"   , "f"    , "VOID" , "0"     ] ,
        ["BLOCK"  , ""     , ""     , ""      ] ,
        ["RETURN" , ""     , ""     , "VOID"  ] ,
        ["END"    , "BLOCK", ""     , ""      ] ,
        ["END"    , "FUNC" , "f"    , ""      ] ,
        ["FUNC"   , "main" , "VOID" , "0"     ] ,
        ["BLOCK"  , ""     , ""     , ""      ] ,
        ["ALLOC"  , "4"    , ""     , "a"     ] ,
        ["COMP"   , "a"    , "2"    , "_t1"   ] ,
        ["BRNEQ"  , ""     , ""     , "BACKP1"] ,
        ["BLOCK"  , ""     , ""     , ""      ] ,
        ["CALL"   , "f"    , "0"    , "_t2"   ] ,
        ["END"    , "BLOCK", ""     , ""      ] ,
        ["BR"     , ""     , ""     , "BACKP2"] ,
        ["BLOCK"  , ""     , ""     , ""      ] ,
        ["CALL"   , "f"    , "0"    , "_t3"   ] ,
        ["END"    , "BLOCK", ""     , ""      ] ,
        ["RETURN" , ""     , ""     , "VOID"  ] ,
        ["END"    , "BLOCK", ""     , ""      ] ,
        ["END"    , "FUNC" , "main" , ""      ] ,
      ]
    end
  end

  context "functions" do
    let(:input) do
      "
      int f(int x, int y) {
        return x + y;
      }

      int main(int z) {
        int a;
        int b;
        return f(a, b);
      }
      "
    end

    it "runs" do
      expect(subject).to eq [
        ["ALLOC"  , "4"     , ""    , "x"   ] ,
        ["ALLOC"  , "4"     , ""    , "y"   ] ,
        ["FUNC"   , "f"     , "INT" , "2"   ] ,
        ["BLOCK"  , ""      , ""    , ""    ] ,
        ["ADD"    , "x"     , "y"   , "_t1" ] ,
        ["RETURN" , ""      , ""    , "INT" ] ,
        ["END"    , "BLOCK" , ""    , ""    ] ,
        ["END"    , "FUNC"  , "f"   , ""    ] ,
        ["ALLOC"  , "4"     , ""    , "z"   ] ,
        ["FUNC"   , "main"  , "INT" , "1"   ] ,
        ["BLOCK"  , ""      , ""    , ""    ] ,
        ["ALLOC"  , "4"     , ""    , "a"   ] ,
        ["ALLOC"  , "4"     , ""    , "b"   ] ,
        ["ARG"    , ""      , ""    , "a"   ] ,
        ["ARG"    , ""      , ""    , "b"   ] ,
        ["CALL"   , "f"     , "2"   , "_t2" ] ,
        ["RETURN" , ""      , ""    , "INT" ] ,
        ["END"    , "BLOCK" , ""    , ""    ] ,
        ["END"    , "FUNC"  , "main", ""    ] ,
      ]
    end
  end
end
