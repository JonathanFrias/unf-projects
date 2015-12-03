require 'spec_helper'
RSpec.describe A4 do
  subject { described_class.new(input).codes }

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
        ['alloc' , '4'   , ''  , 'a'  ] ,
        ["ADD"   , "1"   , "2" , "_t1"] ,
        ["ADD"   , "_t1" , "3" , "_t2"] ,
        ["ADD"   , "_t2" , "4" , "_t3"] ,
        ["ASSIGN", "_t3" , ""  , "a"  ] ,
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
        ['alloc' , '4'   , ''  , 'a'  ] ,
        ["SUB"   , "1"   , "2" , "_t1"] ,
        ["SUB"   , "_t1" , "3" , "_t2"] ,
        ["SUB"   , "_t2" , "4" , "_t3"] ,
        ["ASSIGN", "_t3" , ""  , "a"  ] ,
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
        ['alloc' , '4'   , ''  , 'a'  ] ,
        ["MUL"   , "1"   , "2" , "_t1"] ,
        ["MUL"   , "_t1" , "3" , "_t2"] ,
        ["MUL"   , "_t2" , "4" , "_t3"] ,
        ["ASSIGN" , "_t3" , ""  , "a"  ] ,
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
        ['alloc' , '4'   , ''  , 'a'  ] ,
        ["DIV"   , "1"   , "2" , "_t1"] ,
        ["DIV"   , "_t1" , "3" , "_t2"] ,
        ["DIV"   , "_t2" , "4" , "_t3"] ,
        ["ASSIGN" , "_t3" , ""  , "a"  ] ,
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
        ['alloc' , '4'   , ''    , 'a']   ,
        ["MUL"   , "2"   , "3"   , "_t1"] ,
        ["ADD"   , "1"   , "_t1" , "_t2"] ,
        ["DIV"   , "4"   , "5"   , "_t3"] ,
        ["MUL"   , "_t3" , "6"   , "_t4"] ,
        ["SUB"   , "_t2" , "_t4" , "_t5"] ,
        ["ASSIGN", "_t5" , ""    , "a"  ] ,
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
        ["alloc" , "4"   , ""    , "a"  ] ,
        ["CALL"  , "f"   , ""    , "_t1"] ,
        ["MUL"   , "_t1" , "3"   , "_t2"] ,
        ["CALL"  , "g"   , ""    , "_t3"] ,
        ["MUL"   , "_t2" , "_t3" , "_t4"] ,
        ["ASSIGN", "_t4" , ""    , "a"  ] ,
      ]
    end
  end

  context "can compare stuff" do
    let(:input) do
      "
        void main(void) {
          int a;
          2 > 3;
        }
      "
    end

    it "runs" do
      expect(subject).to eq [
        ["alloc" , "4"  , ""  , "a"  ] ,
        ["COMP"   , "2" , "3" , "_t1"] ,
      ]
    end
  end
end
