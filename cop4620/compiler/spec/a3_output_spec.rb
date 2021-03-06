require 'spec_helper'
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
          void main(void) {
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
        int main(int a) {
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
        int main(int a) {
          float a;
        }
        "
      end
      it { is_not_valid }
    end

    describe "test3" do

      let(:input) do
        "
        int main(void) {
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
        int main(void) {
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
        void b;a /

        b
;
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

  context "array index agreement" do
    describe "test1" do
      let(:input) do
        "
        void printf(int stuff[]) {
          return;
        }
        void main(void) {
          int a[100];

          printf(a[3]); // function expects type int[] but int given
        }
        "
      end

      it { is_not_valid }
    end

    describe "test2" do
      let(:input) do
        "
        void printf(int stuff[]) {
          return;
        }
        void main(void) {
          int a[100];

          printf(a);
        }
        "
      end

      it { is_valid }
    end

    describe "test3" do
      let(:input) do
        "
        void printf(int stuff[]) {
          return;
        }
        void main(void) {
          int a;

          printf(a); // function expects type int[] but int given
        }
        "
      end

      it { is_not_valid }
    end

    describe "test4" do
      let(:input) do
        "
        void main(void) {
        float a[3];

        a[2.1]; // no float index access!
        }
        "
      end

      it { is_not_valid }
    end
  end

  context "nested function calls" do
    describe "test1" do
      let(:input) do
        "
        int f(int x) {
          return 1;
        }
        int g(int x) {
          return 0;
        }
        int main(void) {
        int x;
        x = 1;
          return f(g(1));
        }
        "
      end

      it { is_valid }
    end

    describe "test2" do
      let(:input) do
        "
        float f(int x, int y) {
          return 1.0E+1000;
        }
        int g(int x, float asdf) {
          return 0;
        }

        int h(float x) {
        return 0;
        }
        int main(void) {
        int x;
        x = 1;
          return h(f(g(1, 2.1), 3));
        }
        "
      end

      it { is_valid }
    end

    describe "test3" do
      let(:input) do
        "
        float f(int x, int y) {
          return 1.0E+1000;
        }
        void g(int x, float asdf) {
          return 0;
        }

        int h(float x) {
        return 0;
        }
        int main(void) {
        int x;
        x = 1;
          return h(f(g(1, 2.1), 3));
        }
        "
      end

      it { is_not_valid }
    end
  end

  context "nested scopes are correctly defined" do
    describe "test1" do
      let(:input) do
        "
        int main(void)
{ int a;
  { int a; }
  { int a; }
  { int a; }
  return a;
}
        "
      end

      it { is_valid }
    end

    describe "test2" do
      let(:input) do
        "
        void printf(int a) {
        return;
        }

        int main(void)
{ int a;
  { printf(a); }
  { int a; }
  { int a; }
  return a;
}
        "
      end

      it { is_valid }
    end

    describe "test3" do
      let(:input) do
        "
        void printf(int a) {
        return;
        }

        int main(void)
{ int a;
  { printf(a); }
  { int a; }
  { int a; }
  return a;
}
        "
      end

      it { is_valid }
    end

    describe "test4" do
      let(:input) do
        "
        int main(void)
{
  { int a; int a; }
  return 0;
}
        "
      end

      it { is_not_valid }
    end

    describe "test5" do
      let(:input) do
        "
        int main(void)
        {
          {
            return 0;
          }
        }
        "
      end

      it { is_valid }
    end

    describe "test6" do
      let(:input) do
        "
        int a;
        int main(void)
        {
          int a;
          return a;
        }
        "
      end

      it { is_valid }
    end

    describe "test7" do
      let(:input) do
        "
        int a;
        float b;

        int f(float b) {return 0;}
        int main(void)
        {
          int a;
          return f(b);
        }
        "
      end

      it { is_valid }
    end

  end

  context "id's should not be type void" do
    describe "test1" do
      let(:input) do
        "
      void main(void) {
        void a;
        return;
      }
        "
      end
      it { is_not_valid }
    end

    describe "test2" do
      let(:input) do
        "
      void main(void) {
        void a[];
        return;
      }
        "
      end
      it { is_not_valid }
    end

    describe "test3" do
      let(:input) do
        "
        void f(void) {
        }
      void main(void) {
        int a;
        a = f(); // function return value should be ignored.
        return;
      }
        "
      end
      it { is_not_valid }
    end
  end

  context "extra type checking " do
    describe "test1" do

      let(:input) do
        "
      float a[100];

      int f(void) {
      return 1;
      }
      float main(void) {
        return a[f()];
      }
        "
      end

      it { is_valid }
    end

    describe "test2" do

      let(:input) do
        "
      void a[100];

      float main(void) {
      return 0.0;
      }
        "
      end

      it { is_not_valid }
    end
  end

  context "each program must have one main function" do
    describe "test1" do

      let(:input) do
        "

      float main2(void) {
      return 0.0;
      }
      int main(void) {}
        "
      end

      it { is_not_valid }
    end
  end

  context "jake's examples" do
    describe "test1" do

      let(:input) do
        "
        void main(void x) {
        }
        "
      end

      it { is_not_valid }
    end

    describe "test2" do

      let(:input) do
        "
        void main(void) {
            int a;
            { int a; }
            int a;
            a = 5 + 7;
            return;
          }
        "
      end

      it { is_not_valid }
    end

    describe "test3" do

      let(:input) do
        "
        void main(int a, int b) {
            int a;
            int c;
            int d;
        }
        "
      end

      it { is_not_valid }
    end

    describe "test4" do

      let(:input) do
        "
        int a;
        void main(int b) {
            a = 5;
            return;
        }
        "
      end

      it { is_valid }
    end

    describe "test5" do

      let(:input) do
        "
        int a;
        void b(void) {
        }
        int c;

        void d(void) {
          c = 5;
        }

        void main(void) {
        }
        "
      end

      it { is_valid }
    end

    describe "test6" do

      let(:input) do
        "
        int a;
        void main(int b) {
            int c;
            a = 5;
            if (1) {
                c = 6;
                a = 7;
            }
        }
        "
      end

      it { is_valid }
    end

    describe "test6" do

      let(:input) do
        "
        int a;
        void f(int b) {
            a = b = 7;
        }
        void main(void) {
            b = 6;
        }
        "
      end

      it { is_not_valid }
    end

    describe "test6" do

      let(:input) do
        "
        void main(int hello) {
            int a;
            { int a; }
            a = 5 + 7;
            return;
        }
        "
      end

      it { is_valid }
    end
    describe "test7" do

      let(:input) do
        "
        void main(int hello) {
            return;
        }
// main should be the last function
void f(void) {}
        "
      end

      it { is_not_valid }
    end
  end
end
