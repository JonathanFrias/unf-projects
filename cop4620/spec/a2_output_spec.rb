require 'spec_helper'

  $show_goto = 1
  $show_accept = 1
RSpec.describe A2 do

  # start                -> declaration_list
  # declaration_list     -> declaration_list declaration | declaration
  # declaration          -> var_declaration | func_declaration
  # var_declaration      -> type_specifier ID; | type_specifier ID[NUM];
  # type_specifier       -> int | void | float
  # func_declaration     -> type_specifier ID ( params ) compound_statement
  # params               -> param_list | void
  # param_list           -> param_list , param | param
  # param                -> type_specifier ID | type_specifier ID [ ]
  # compound_statement   -> { local_declarations statement_list }
  # local_declarations   -> local_declarations var_declaration | EMPTY
  # statement_list       -> statement_list statement | EMPTY
  # statement            -> expression_statement | compound_statement | selection_statement | iteration_statement | return_statement
  # expression_statement -> expression; | ;
  # selection_statement  -> if ( expression ) statement | if ( expression ) statement else statement
  # iteration_statement  -> while ( expression ) statement
  # return_statement     -> return ; | return expression ;
  # expression           -> var = expression | simple_expression
  # var                  -> ID | ID [ expression ]
  # simple_expression    -> additive_expression relop additive_expression | additive_expression
  # relop                -> <= | < | > | >= | == | !=
  # additive_expression  -> additive_expression addop term | term
  # addop                -> + | -
  # term                 -> term mulop factor | factor
  # mulop                -> * | /
  # factor               -> ( expression ) | var | call | NUM
  # call                 -> ID ( args )
  # args                 -> args_list | EMPTY
  # args_list            -> args_list , expression | expression

  context "accepts and rejects" do
    subject { described_class }

    let(:function_decs) do
      "
        int a[2];

        int b;
      int main(void) {}
      float f(int x) {}

      void g( void) {};
      "
    end

    let(:func_and_var) do
      "
      int main(int a, float b, int c) {
      }

      int a;
      int f(float x) {

      }
      "
    end

    let(:if_statements) do
      "
      float main(void) {
      if(a==b)
        return 1 + 2;
       else
        return 1 > 2;
      }"
    end

    let(:multiply) do
      "
      int main(void) {
        result = a * b * (12* (23/c));
      }

      int f(float x, float y) {
        asdflkjsadlfkj = 12.231 * 2.1;
      }
      "
    end

    let(:add) do
      "
      int main(void) {
        result = a + b - (12+ (23-c));
      }

      int f(float x, float y) {
        asdflkjsadlfkj = 12.231 + 2.1;
      }
      "
    end

    let(:invalid1) do
      "
      int f(void) {
        int g(void) {
        }
      }
      "
    end

    let(:must_have_params) do
      "
      int main() {
      }
      "
    end

    let(:valid_compares) do
      "
      int main(void) {
        int a;
        float c;
        b[0] = 3;
        c = b[21];
        if(a[1] == f)
          if (g [1] == h[3]) return;
          else
            return 1+1;
      }
      "
    end

    let(:nested_ifs) do
      "
      int main(void) {
        if(3.2 == 1.2)
          return;
        else
          if(40.2 == 12E03)
            a = 23;
          else
            a = 23;
      }
      "
    end

    let(:addition) do
      "
      int main (void){
        a = 1 + 1;
        a = (1 + 1);
        a = (1 + 1)-(23*2);
        a = ((1 + 1)-(23*2))*31+85;
      }
      "
    end

    let(:arrays) do
      "
      int main(void) {
        int b[0];
        int asdfasdfslkdjf[2333];
      }
      "
    end

    let(:function_calls) do
      "
      int main(void) {
        f();
        f(x);
        f(x, y, z);
      }"
    end

    let(:compute_god) do
      # This is the program from textbook pg: 496
      "
      /* A program to perform Euclid's
         Algorithm to compute god. */
      int god(int u, int v) {
        if(v == 0) return u;
        else return gcd(v, u-u / v*v);
        /* u-u/v*v == u mod v */
      }

      void main(void)
      { int x; int y;
        x = input(); y = input();
        output(gcd(x, y));
      }
      "
    end

    let(:sort_integers) do
      "
      /* A program to perform selection sort on a 10
         element array*/
      int x[10];

      int minloc( int a[], int low, int high)
      { int i; int x; int k;
        k = low;
        x = a[low];
        i = low + 1;
        while( i < high) {
          if(a[i] < x) {
            x = a[i];
            k = i;
          }
          i = i + 1;
        }
        return k;
      }

      void sort(int a[], int lwo, int high) {
        int i; int k;
        i = low;
        while(i < high-1) {
          int t;
          k = minloc(a, i, high);
          t = a[k];
          a[k] = a[i];
          a[i] = t;
          i = i + 1;
        }
      }
      void main(void)
      {
        int i;
        i = 0;
        while(i < 10) {
          x[i] = input();
          i = i + 1;
        }
        sort(x, 0, 10);
        i = 0;
        while(i < 10) {
          output(x[i]);
          i = i + 1;
        }
      }
      "
    end

    let(:inputs) do
      [
        # [ TEST_NUMBER, TEST_CODE, EXPECTED_RESULT],
        [0 , "int a[1.2];"    , "REJECT" ],
        [1 , "int b"          , "ACCEPT" ],
        [2 , "b b"            , "REJECT" ],
        [3 , "b b(void)"      , "REJECT" ],
        [4 , "int b(void){}"  , "ACCEPT" ],
        [5 , "f(void)"        , "REJECT" ],
        [6 , function_decs    , "ACCEPT" ],
        [7 , invalid1         , "REJECT" ],
        [8 , if_statements    , "ACCEPT" ],
        [9 , func_and_var     , "ACCEPT" ],
        [10, valid_compares   , "ACCEPT" ],
        [11, addition         , "ACCEPT" ],
        [12, arrays           , "ACCEPT" ],
        [13, nested_ifs       , "ACCEPT" ],
        [14, multiply         , "ACCEPT" ],
        [15, add              , "ACCEPT" ],
        [16, function_calls   , "ACCEPT" ],
        [17, must_have_params , "REJECT" ],
        [18, compute_god      , "ACCEPT" ],
        [19, sort_integers    , "ACCEPT" ],
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
