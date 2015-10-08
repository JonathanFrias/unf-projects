require 'spec_helper'

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

      void g( void) {}
      "
    end

    let(:function_decs2) do
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

    let(:function_call2) do
      "
      int main(void) {
        f(a[2.2], b[3], 3 == 3);
      }
      "
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

    let(:jake_sample1) do
      "
        int main(int x, float joe) {
            int x;
            float y;
            void z;

            if (1) {
                void a;
                float b;
            } else {
                while(5) {
                    int x;
                    float a;
                    x = a + 5;
                    ;;;;;;;;;;;;;;;;;;;;;;;
                }
            }
            ;;;;;;;;;;;;;;;;;;;;;;
            y = 5 * 7 / x + 64 * 8;
            x = sqrt(64) + (5 * 7) / (9 + nickdaman);
            ;;;;;;;;;;;;;;;
            return sqrt(64);
            ;;;;
        }
      "
    end

    let(:jake_sample2) do
      "
        void main(int arg, float martino) {
            printf(5, 7, hello);
            return 5 + 7;
            x;
        }
      "
    end

    let(:almost_correct) do
      "
      int main(void) {
        return 5+7++;
      }
      "
    end

    let(:only_if) do
      "
      if(0) {
        printf(1+1); // reject because statement without func
      }
      "
    end

    let(:comments) do
      '
      // comment!
      int main(void) {//{ { {

        foo();
        // asdd!@#$%(@*&#$(*&!@(#*(*%&!)(@*&#*!^%#&*^_+!@#/.,<>:"{}\
        /* asdd!@#$%(@*&#$(*&!@(#*(*%&!)(@*&#*!^%#&*^_+!@#/.,<>:"{}\ */
      }
      '
    end

    let(:no_curly) do
      "
      int main(void) {
      }
      float foo(int x)
        return stuff;
      "
    end

    let(:bad_param1) do
      "
      int a(int[2] a) { // [2] is not allowed here
      }
      "
    end

    let(:bad_param2) do
      "
      int a(int[] a;) {
      }
      "
    end

    let(:blah) do
      "
      int main(void) {
        if(1) return; else return 1.2;
      }
      "

    end

    let(:sample_project) do
      "
      /* A program to perform Euclid's
   Algorithm to compute cfd. */

int gcd (int u, int v)
{  if (v == 0) return u ;
   else return gcd(v,u-u/v*v);
   /* u-u/v*v == u mod v */
}

void main(void)
{ int x; int y;
  x = input(); y = input();
  output(gcd(x,y));
}

/* A program to perform selection sort on a 10
// element array.
*/

int x[10];

int minloc (int a[], int low, int high )
{ int i; int x; int k;
  k = low;
  x = a[low];
  i = low + 1;
  while (i < high)
  { if (a[i] < x)
    {
        x = a[i];
        k = i;
    }
    i = i + 1;
  }
  return k;
}

void sort( int a[], int low, int high )
{ int i; int k;
  i = low;
  while (i < high - 1)
  {
    int t;
    k = minloc(a,i,high);
    t = a[i];
    a[i] = t;
    i = i + 1;
  }
}

void main (void)
{ int i;
  i = 0;
  while (i < 10)
  {  x[i] = input();
     i = i + 1;
  }
  sort(x,0,10);
  i = 0;
  while (i < 10)
  {
  output(x[i]);
  i = i + 1;
  }
}

int main (void a[], int a, float b)
{
    int a[18];
    float a[18];
    void a[0];
    void a[10];

    while (i != y)
    {
        if ((x - y * z / 5 - th) / (x * (w * 7 * (t - 5))) > (4 * (u - 5)))
        {
        }
        else
        {
            functioncall(132954820 - 153890629, 7346374569 / (u - u + p / 456275 + go));
        }
    }

    if (x >= 10)
    {
        if (x == 10)
        {
        }
    }
    else if (x <= 8)
    {
    }
    else
    {
    }

    if (a)
        a = a + 1;

    return (x + y) / 100;
}

void main (void)
{
    return 0;
}

float main (void)
{
    return x;
}"
    end

    let(:missing_semi) do
      "
      /* test4, missing ; */

      int gcd (int u , int v )
      {
        if ( v != 0)
          return u
        else
          return gcd( v , u - u / v* v );
        /*note u-(u/v*v) == u mod v */
      }
      "
    end

    let(:missing_paren) do
      "
int gcd (int u , int v
{
	if ( v != 0)
		return u;
	else
		return gcd( v , u - u / v* v );
	/*note u-(u/v*v) == u mod v */
}
  "
    end

    let(:missing_brace) do
      "
      /* test7, missing { */

int gcd (int u , int v )

	if ( v != 0)
		return u;
	else
		return gcd( v , u - u / v* v );
	/*note u-(u/v*v) == u mod v */
}
      "

    end

    let(:missing_other_brace) do
      "
/* test8, missing } */

int gcd (int u , int v )
{
	if ( v != 0)
		return u;
	else
		return gcd( v , u - u / v* v );
	/*note u-(u/v*v) == u mod v */
      "
    end

    let(:void_list)do
      "
            /* test13  testing void list accept*/

      float z;

      void noclue(void)
      {
        int s;
        if(z=7)
          return z;
        while(r>z)
        {if (x==2)
            return x;
        }


      }
      "
    end

    let(:missing_bracket) do
      "
      /* test16  testing array parameter missing [ */

int q[6];

int noclue(int z])
{
	int s;
	if(z[1]=7)
		return z;
	while(r>z)
	{if (x==2)
			return x;
	}


}
      "
    end

    let(:missing_other_bracket) do
      "
      /* test17  testing array parameter missing [ */

int q[6];

int noclue(int z[])
{
	int s;
	if(z1]=7)
		return z;
	while(r>z)
	{if (x==2)
			return x;
	}


}
      "
    end

    let(:pre_add) do
      "
      /* test20  testing float fail + precedes int*/

int q[6];

int noclue(int z[])
{
	int s;
	if(z[1]=7)
		return z;
	while(r>z)
	{if (x==2)
			return +3.4E6;
	}


}
      "
    end

    let(:float_accept) do
      "
      /* test21  testing float accept*/

int q[6];

int noclue(int z[])
{
	int s;
	if(z[1]=7)
		return z;
	while(r>z)
	{
		if (x==2)
			return 3.4E-6;
	}


}
      "
    end

    let(:number_in_id) do
      "/*  test23 number in ID token */

int gc1d ( int u , int v )
{	// note prob here
	if ( v == 0 )
		return u ;
	else
		return gcd ( v , u - u / v * v );
	/* note u-(u/v*v) = u mod v */
}"
    end

    let(:num_letter) do
      "/* test15  testing if extra letter after number failure*/

int z[6];

int noclue(int z[])
{
	int s;
	if(z[1] <= 7a)
		return z;
	while(r>z)
	{if (x==2)
			return x;
	}


}"
    end

    let(:extra_stuff) do
      "
      /* test51  testing if comparison extra letter failure*/


int z[6];

int noclue(int z[])
{
	int s;
	if(z[1] >b= 7)		// = is token 26
		return z;
	while(r>z)
	{if (x==2)
			return x;
	}


}
      "
    end

    let(:exta_compare) do
      "/* test52  testing if comparison extra < fail*/

int z[6];

int noclue(int z[])
{
	int s;
	if(z[1] <<= 7)		// <<= is tokens 24&25
		return z;
	while(r>z)
	{if (x==2)
			return x;
	}


}"
    end

    let(:extra_char) do
      "/* test53  testing excess letter in array reference fail*/

int z[6];

int noclue(int z[])
{
	int s;
	if(z[1a] >= 7)		// 1a is token 22
		return z;
	while(r>z)
	{if (x==2)
			return x;
	}
}"
    end

    let(:float_accept) do
      "/* test54  testing float accept*/

int q[6];

int noclue(int z[])
{
	int s;
	if(z[1]=7)
		return z;
	while(r>z)
	{
		if (x==2)
			return 3.4E-6;
	}

	if(a>b){
	k = k;
	}else{
	k = 1;
	}

	if(b>a)
	b = 1;
	else
	b = 2;

	if(b == a)
	a = b;
	else{
	c = d;
	}

}"
    end

    let(:nested_scope) do
      "
      int main(void) {
        {  // yay im nested!
          int x;
        }
      }
      "
    end

    let(:inputs) do
      [
        # [ TEST_NUMBER, TEST_CODE, EXPECTED_RESULT],
        [0  , "int a[1.2];"    , "ACCEPT" ],
        [1  , "int b"          , "REJECT" ],
        [2  , "b b"            , "REJECT" ],
        [3  , "b b(void)"      , "REJECT" ],
        [4  , "int b(void){}"  , "ACCEPT" ],
        [5  , "f(void)"        , "REJECT" ],
        [6  , function_decs    , "ACCEPT" ],
        [7  , invalid1         , "REJECT" ],
        [8  , if_statements    , "ACCEPT" ],
        [9  , func_and_var     , "ACCEPT" ],
        [10 , valid_compares   , "ACCEPT" ],
        [11 , addition         , "ACCEPT" ],
        [12 , arrays           , "ACCEPT" ],
        [13 , nested_ifs       , "ACCEPT" ],
        [14 , multiply         , "ACCEPT" ],
        [15 , add              , "ACCEPT" ],
        [16 , function_calls   , "ACCEPT" ],
        [17 , must_have_params , "REJECT" ],
        [18 , compute_god      , "ACCEPT" ],
        [19 , sort_integers    , "ACCEPT" ],
        [20 , jake_sample1     , "ACCEPT" ],
        [21 , jake_sample2     , "ACCEPT" ],
        [22 , almost_correct   , "REJECT" ],
        [23 , only_if          , "REJECT" ],
        [24 , comments         , "ACCEPT" ],
        [25 , no_curly         , "REJECT" ],
        [26 , bad_param1       , "REJECT" ],
        [27 , bad_param2       , "REJECT" ],
        [28 , function_call2   , "ACCEPT" ],
        [29 , blah             , "ACCEPT" ],
        [30 , sample_project   , "ACCEPT" ],
        [31 , missing_semi     , "REJECT" ],
        [32 , missing_paren    , "REJECT" ],
        [33 , missing_brace    , "REJECT" ],
        [34 , missing_other_brace, "REJECT" ],
        [35 , void_list        , "ACCEPT" ],
        [36 , missing_bracket  , "REJECT" ],
        [37 , missing_other_brace, "REJECT" ],
        [38 , pre_add          , "REJECT" ],
        [39 , float_accept     , "ACCEPT" ],
        [40 , number_in_id     , "ACCEPT" ],
        [41 , num_letter       , "REJECT" ],
        [42, extra_stuff       , "REJECT" ],
        [43, exta_compare      , "REJECT" ],
        [44, extra_char        , "REJECT" ],
        [45, function_decs2    , "REJECT" ],
        [46, nested_scope      , "ACCEPT" ],
      ]
    end

    it "accepts and rejects" do
      inputs.each do |number, code, result, debug_level|
        if number == number
          if (string = subject.new(code).to_s) != result
            puts number.to_s + " FAILED"
          end
          expect(string).to eq result
        end
      end
    end
  end
end
