require 'spec_helper'
require 'pry'
RSpec.describe A2 do

  subject { described_class.new(input).to_s }

  def is_valid
    expect(subject.to_s).to eq "ACCEPT"
  end

  def is_not_valid
    expect(subject.to_s).to eq "REJECT"
  end

  context "functions declared int or float  must have a return value of the correct type." do
    describe "test1" do
      let(:input) do
        "
          void main(void) {
            return;
          }
        "
      end

      it { is_valid }
    end

    describe "test2" do
      let(:input) do
        "
          int main(void) {
            int a;
          }
        "
      end

      it { is_not_valid }
    end

    describe "test3" do
      let(:input) do
        "
          int main(void) {
            return 1 + 1;
          }
        "
      end

      it { is_valid }
    end

    describe "test4" do
      let(:input) do
        "
          int main(void) {
            return 1 * 1;
          }
        "
      end

      it { is_valid }
    end

    describe "test5" do
      let(:input) do
        "
          int f(void) {
            return 1;
          }

          int main(void) {
            return f();
          }
        "
      end

      it { is_valid }
    end

    describe "test6" do
      let(:input) do
        "
          int f(void) {
            return 3.1;
          }

          int main(void) {
            return f();
          }
        "
      end

      it { is_not_valid }
    end

    describe "test7" do
      let(:input) do
        "
          int f(void) {
            return 10/2;
          }

          int main(void) {
            return f();
          }
        "
      end

      it { is_valid }
    end
  end

  context "void functions may or may not have a return, but must not return a value." do

    describe "test1" do
      let(:input) do
        "
        void f(void) {
          return;
        }
        "
      end

      it { is_valid }
    end

    describe "test2" do
      let(:input) do
        "
          void f(void) {
            return 1;
          }
        "
      end

      it { is_not_valid }
    end
  end

  context "parameters and arguments agree in number" do
    describe "test1" do
      let(:input) do
        "

        int f(int a, int b) {
          return a + b;
        }

        int main(void ) {
          int a;
          int b;
          return f(a, b);
        }

        "
      end

      it { is_valid }
    end

    describe "test2" do

      let(:input) do
        "

        int f(int a, int b) {
          return a + b;
        }

        int main(void ) {
          int a;
          int b;
          return f(a);
        }
        "
      end
      it { is_not_valid }
    end

    describe  "test3" do
      let(:input) do
        "

        int f(float a, int b) {
          return a + b;
        }

        int main(void ) {
          float a;
          int b;
          return f(a);
        }
        "
      end

      it { is_not_valid }
    end

    describe  "test3.5" do
      let(:input) do
        "

        int f(float a, int b) {
          return a + b;
        }

        int main(void ) {
          float a;
          int b;
          return f(a, b);
        }
        "
      end

      it { is_not_valid }
    end

    describe  "test4" do
      let(:input) do
        "

        int f(float a, int b) {
          return 12345435;
        }

        int main(void ) {
          float a;
          int b;
          return f(a, b);
        }
        "
      end

      it { is_valid }
    end

    describe "test5" do
      let(:input) do
        "

        int f(float a, float b) {
          return 12345435;
        }

        int main(void ) {
          float a;
          int b;
          return f(a, b);
        }
        "
      end

      it { is_not_valid }
    end
  end

  context "cannot redefine variables" do
    describe "test1" do

      let(:input) do
        "
        int f(int a) {
          int a;
          return 0;
        }
        "
      end
      it { is_not_valid }
    end

    describe "test2" do

      let(:input) do
        "
        int f(int a) {
          float a;
        }
        "
      end
      it { is_not_valid }
    end

    describe "test3" do

      let(:input) do
        "
        int f(void) {
          float a;
          int a;
        }
        "
      end
      it { is_not_valid }
    end

    describe "test4" do

      let(:input) do
        "
        int f(void) {
          int a;
          int a;
        }
        "
      end
      it { is_not_valid }
    end
  end

  context "cannot add or multiply void vars" do

    describe "test1" do

      let(:input) do
        "
      int main(void) {
        void a;
        void b;
        a * b;
        return 0;
      }
        "
      end
      it { is_not_valid }
    end

    describe "test2" do

      let(:input) do
        "
      int main(void) {
      void a;
      void b;
      a + b;
      return 0;
      }
        "
      end
      it { is_not_valid }
    end

    describe "test3" do

      let(:input) do
        "
      int main(void) {
      void a;
      void b;
      a / b;
      return 0;
      }
        "
      end
      it { is_not_valid }
    end

    describe "test3" do

      let(:input) do
        "
      int main(void) {
      void a;
      void b;
      a - b;
      return 0;
      }
        "
      end
      it { is_not_valid }
    end
  end

  context "operand agreement" do
    describe "test1" do
      let(:input) do
        "
        void main(void) {
          int a;
          int b;

          float aa;
          float bb;

          a + b;
          aa + bb;
        }
        "
      end
      it { is_valid }
    end

    describe "test2" do
      let(:input) do
        "
        void main(void) {
          int a;
          int b;

          float aa;
          float bb;

          a - b;
          aa - bb;
        }
        "
      end
      it { is_valid }
    end
    describe "test3" do
      let(:input) do
        "
        void main(void) {
          int a;
          int b;

          float aa;
          float bb;

          a / b;
          aa / bb;
        }
        "
      end
      it { is_valid }
    end

    describe "test4" do
      let(:input) do
        "
        void main(void) {
          int a;
          int b;

          float aa;
          float bb;

          a * b;
          aa * bb;
        }
        "
      end
      it { is_valid }
    end

    describe "test5" do
      let(:input) do
        "
        void main(void) {
          int a;
          float b;
          a * b;
        }
        "
      end
      it { is_not_valid }
    end

    describe "test6" do
      let(:input) do
        "
        void main(void) {
          int a;
          float b;
          a + b;
        }
        "
      end
      it { is_not_valid }
    end

    describe "test7" do
      let(:input) do
        "
        void main(void) {
          int a;
          float b;
          a - b;
        }
        "
      end
      it { is_not_valid }
    end

    describe "test8" do
      let(:input) do
        "
        void main(void) {
          int a;
          float b;
          a / b;
        }
        "
      end
      it { is_not_valid }
    end
  end

end
