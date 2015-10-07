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

    let(:valid1) do
      "
        int a[2];

        int b;
      int main(void) {}
      float f(int x) {}

      void g( void) {};
      "
    end

    let(:valid3) do
      "
      int main(int a, float b, int c) {
      }
      "
    end

    let(:valid2) do
      "
      float main() {
      if(a==b)
        return 1 + 2;
       else
        return 1 > 2;
      }"
    end

    let(:multiply) do
      "
      int main() {
        a * a;
        a * a * (12* 23/a);
      }

      int f(float x, float y) {
        asdflkjsadlfkj = 12.231 * 2.1;
      }
      "
    end

    let(:invalid1) do
      "
      int f() {
        int g() {
        }
      }
      "
    end

    let(:valid_compares) do
      "
      int main() {
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
      int main() {
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
      int main (){
      a = 1 + 1;
      a = (1 + 1);
      a = (1 + 1)-(23*2);
      a = ((1 + 1)-(23*2))*31+85;
      }
      "
    end

    let(:valid5) do # array declarations
      "
      int main() {
        int b[0];
        int asdfasdfslkdjf[2333];
      }
      "
    end

    let(:inputs) do
      [
        # [ TEST_NUMBER, TEST_CODE, EXPECTED_RESULT],
        [0 , "int a[1.2];"  , "REJECT" ],
        [1 , "int b"        , "ACCEPT" ],
        [2 , "b b"          , "REJECT" ],
        [3 , "b b()"        , "REJECT" ],
        [4 , "int b() {}"   , "ACCEPT" ],
        [5 , "f()"          , "REJECT" ],
        [6 , valid1         , "ACCEPT" ],
        [7 , invalid1       , "REJECT" ],
        [8 , valid2         , "ACCEPT" ],
        [9 , valid3         , "ACCEPT" ],
        [10, valid_compares , "ACCEPT" ],
        [11, addition       , "ACCEPT" ],
        [12, valid5         , "ACCEPT" ],
        [13, nested_ifs     , "ACCEPT" ],
        [14, multiply       , "ACCEPT" ],
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
