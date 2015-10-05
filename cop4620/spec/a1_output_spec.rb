require 'spec_helper'

RSpec.describe A1 do

  subject { described_class.new input }

  let(:result) { subject.to_s.split("\n") }
  context "multiline comments" do
    let(:input) do
      "/**/          /*/* */   */ /* */
      /*/*/****This**********/*/    */
      /**************/
      /*************************
      i = 333;        ******************/       */e;

      /*
      *  /* /* */
      *  */
      *
      */
      */d;
      */c;
      /*b;
      /*a;
      "
    end

    it "finds all the index ranges of all valid comments!" do
      expect(subject.find_comments).to eq [[0, 3], [14, 25], [27, 31], [39, 70], [78, 93], [101, 168], [188, 236]]
    end

    it "removes the comments" do
      expect(subject.lines).to eq ["* / e",
        "* / d",
        "* / c",
        "/ * b",
        "/ * a"]
    end
  end

  context "mixed multi-single line comments" do
    let(:input) do
      "/* // */ */"
    end

    it "returns the valid token" do
      expect(subject.to_s.split("\n")).to eq [
        "INPUT: / *;",
        "/",
        "*",
        ";",
      ]
    end
  end

  context "single line comments" do
    let(:input) do
      "/**/      non_comment    /*comment/* */ comment  */ /* */"
    end

    it "removes comments" do
      expect(subject.lines).to eq ['non_comment']
    end
  end

  context "one line comment" do
    let(:input) do
      "//aaa
      b
      //cccc
      "
    end

    it "removes the line comment" do
      expect(subject.lines).to eq ["b"]
    end
  end

  context "returns the tokens" do
    context "can recognize keyword" do
      let(:input) do
        "int void return; if else float;true false; while"
      end

      it "can recognize the keywords" do
        expect(subject.to_s.split("\n")).to eq [
          "INPUT: int void return;",
          "KEYWORD: INT",
          "KEYWORD: VOID",
          "KEYWORD: RETURN",
          ";",
          "INPUT: if else float;",
          "KEYWORD: IF",
          "KEYWORD: ELSE",
          "KEYWORD: FLOAT",
          ";",
          "INPUT: true false;",
          "KEYWORD: TRUE",
          "KEYWORD: FALSE",
          ";",
          "INPUT: while;",
          "KEYWORD: WHILE",
          ";"
        ]
      end
    end

    context "can recognize identifiers, assignments" do
      context "identifiers" do
        let(:input) do
          "int a=b;
          float c=0.4;
          a != b;
          a > b;
          b<=c;"
        end

        it "can lex all the things" do
          expect(subject.to_s.split("\n")).to eq [
            "INPUT: int a = b;",
            "KEYWORD: INT",
            "IDENTIFIER: a",
            "=",
            "IDENTIFIER: b",
            ";",
            "INPUT: float c = 0.4;",
            "KEYWORD: FLOAT",
            "IDENTIFIER: c",
            "=",
            "CONSTANT: 0.4",
            ";",
            "INPUT: a != b;",
            "IDENTIFIER: a",
            "!=",
            "IDENTIFIER: b",
            ";",
            "INPUT: a > b;",
            "IDENTIFIER: a",
            ">",
            "IDENTIFIER: b",
            ";",
            "INPUT: b <= c;",
            "IDENTIFIER: b",
            "<=",
            "IDENTIFIER: c",
            ";"
          ]
        end
      end

      context "case sensitve keywords" do
        let(:input) do
          "while;
          wHiLE;
          iF;
          else;
          ELSE;
          "
        end

        it "only allows lowercase keywords" do
          expect(subject.to_s.split("\n")).to eq [
            "INPUT: while;",
            "KEYWORD: WHILE",
            ";",
            "INPUT: wHiLE;",
            "IDENTIFIER: wHiLE",
            ";",
            "INPUT: iF;",
            "IDENTIFIER: iF",
            ";",
            "INPUT: else;",
            "KEYWORD: ELSE",
            ";",
            "INPUT: ELSE;",
            "IDENTIFIER: ELSE", ";",
          ]
        end
      end
    end

    context "can recognize parens" do
      let(:input) do
        "();
        (\n);
        (());
        (((\n))\n);"
      end

      it "find the left and right parens" do
        expect(subject.to_s.split("\n")).to eq [
          "INPUT: ( );",
          "(",
          ")",
          ";",
          "INPUT: ( );",
          "(",
          ")",
          ";",
          "INPUT: ( ( ) );",
          "(",
          "(",
          ")",
          ")",
          ";",
          "INPUT: ( ( ( ) ) );",
          "(",
          "(",
          "(",
          ")",
          ")",
          ")",
          ";",
        ]
      end

      context "errors" do
        let(:input) do
          "((; ( (; ) ); (); ) ; ( ; ) (;"
        end

        it "can report paren errors" do
          expect(subject.to_s.split("\n")).to eq [
            "INPUT: ( (;",
            "(",
            "(",
            "ERROR: Mismatched parenthesis on line 1",
            ";",
            "INPUT: ( (;",
            "(",
            "(",
            "ERROR: Mismatched parenthesis on line 2",
            ";",
            "INPUT: ) );",
            ")",
            ")",
            "ERROR: Mismatched parenthesis on line 3",
            ";",
            "INPUT: ( );",
            "(",
            ")",
            ";",
            "INPUT: );",
            ")",
            "ERROR: Mismatched parenthesis on line 5",
            ";",
            "INPUT: (;",
            "(",
            "ERROR: Mismatched parenthesis on line 6",
            ";",
            "INPUT: ) (;",
            ")",
            "(",
            "ERROR: Mismatched parenthesis on line 7",
            ";",
          ]
        end
      end
    end

    context "detects errors with assignments" do
      let(:input) do
        "int a = 3@333"
      end

      it "errors on this line" do
        expect(subject.to_s.split("\n")).to eq [
          "INPUT: int a = 3@333;",
          "KEYWORD: INT",
          "IDENTIFIER: a",
          "=",
          "ERROR processing '3@333' on line 1!",
          ";",
        ]
      end
    end

    context "can do arithmatic" do
      let(:input) do
        "a*b;
        b/c;
        d+f;
        g-o;"
      end

      it "does the 4 basic operations" do
        expect(subject.to_s.split("\n")).to eq [
          "INPUT: a * b;",
          "IDENTIFIER: a",
          "*",
          "IDENTIFIER: b",
          ";",
          "INPUT: b / c;",
          "IDENTIFIER: b",
          "/",
          "IDENTIFIER: c",
          ";",
          "INPUT: d + f;",
          "IDENTIFIER: d",
          "+",
          "IDENTIFIER: f",
          ";",
          "INPUT: g - o;",
          "IDENTIFIER: g",
          "-",
          "IDENTIFIER: o",
          ";",
        ]
      end
    end

    context "nested blocks" do
      context "nested block 1" do
        let(:input) do
          "if(a == b  ) {
          while(true) {
          }
        }
        a== b;"
        end

        it "lexes correctly" do
          expect(subject.to_s.split("\n")).to eq [
            "INPUT: if ( a == b ) {",
            "KEYWORD: IF",
            "(",
            "IDENTIFIER: a",
            "==",
            "IDENTIFIER: b",
            ")",
            "{",
            "INPUT: while ( true ) {",
            "KEYWORD: WHILE",
            "(",
            "KEYWORD: TRUE",
            ")",
            "{",
            "INPUT: }",
            "}",
            "INPUT: }",
            "}",
            "INPUT: a == b;",
            "IDENTIFIER: a",
            "==",
            "IDENTIFIER: b",
            ";",
          ]
        end
      end

      context "nested block" do
        let(:input) do
          "if(a == b  )

            {
          while(true)
          {
          }
          }
        a== b;"
        end

        it "lexes correctly" do
          expect(subject.to_s.split("\n")).to eq [
            "INPUT: if ( a == b ) {",
            "KEYWORD: IF",
            "(",
            "IDENTIFIER: a",
            "==",
            "IDENTIFIER: b",
            ")",
            "{",
            "INPUT: while ( true ) {",
            "KEYWORD: WHILE",
            "(",
            "KEYWORD: TRUE",
            ")",
            "{",
            "INPUT: }",
            "}",
            "INPUT: }",
            "}",
            "INPUT: a == b;",
            "IDENTIFIER: a",
            "==",
            "IDENTIFIER: b",
            ";",
          ]
        end
      end
    end

    context "if else" do
      let(:input) do
        "if(a==b){
        } else {
        }
        }
       "
      end

      it "lexes" do
        expect(subject.to_s.split("\n")).to eq [
          "INPUT: if ( a == b ) {",
          "KEYWORD: IF",
          "(",
          "IDENTIFIER: a",
          "==",
          "IDENTIFIER: b",
          ")",
          "{",
          "INPUT: }",
          "}",
          "INPUT: else {",
          "KEYWORD: ELSE",
          "{",
          "INPUT: }",
          "}",
          "INPUT: }",
          "}",
          "ERROR: Mismatched braces",
        ]
      end
    end

    context "array notation" do
      let(:input) do
        "a[2];
        int[] d;
        a[x+2]"
      end

      it "parses array notation" do
        expect(subject.to_s.split("\n")).to eq [
          "INPUT: a [ 2 ];",
          "IDENTIFIER: a",
          "[",
          "CONSTANT: 2",
          "]",
          ";",
          "INPUT: int [ ] d;",
          "KEYWORD: INT",
          "[",
          "]",
          "IDENTIFIER: d",
          ";",
          "INPUT: a [ x + 2 ];",
          "IDENTIFIER: a",
          "[",
          "IDENTIFIER: x",
          "+",
          "CONSTANT: 2",
          "]",
          ";",
        ]
      end

      context "handle edge cases errors" do
        let(:input) do
          "[]];
          [[]];
          ][;
          [[]"
        end

        it "works!" do
          expect(subject.to_s.split("\n")).to eq [
            "INPUT: [ ] ];",
            "[",
            "]",
            "]",
            "ERROR: Mismatched brackets on line 1",
            ";",
            "INPUT: [ [ ] ];",
            "[",
            "[",
            "]",
            "]",
            ";",
            "INPUT: ] [;",
            "]",
            "[",
            "ERROR: Mismatched brackets on line 3",
            ";",
            "INPUT: [ [ ];",
            "[",
            "[",
            "]",
            "ERROR: Mismatched brackets on line 4",
            ";",
          ]
        end
      end
    end
  end

  context "assignment1 failures" do

    context "err1" do
      let(:input) do
        "
       void main(void)
 {
  b = bbbb / 24567;
         b = b + 3.44E05;
         b = b + 3.44E-05;
         b =  3.44;
 }
        "
      end

      it "no longer fails" do
        expect(result).to eq [
          "INPUT: void main ( void ) {",
          "KEYWORD: VOID",
          "IDENTIFIER: main",
          "(",
          "KEYWORD: VOID",
          ")",
          "{",
          "INPUT: b = bbbb / 24567;",
          "IDENTIFIER: b",
          "=",
          "IDENTIFIER: bbbb",
          "/",
          "CONSTANT: 24567",
          ";",
          "INPUT: b = b + 3.44E05;",
          "IDENTIFIER: b",
          "=",
          "IDENTIFIER: b",
          "+",
          "CONSTANT: 3.44E05",
          ";",
          "INPUT: b = b + 3.44E-05;",
          "IDENTIFIER: b",
          "=",
          "IDENTIFIER: b",
          "+",
          "CONSTANT: 3.44E-05",
          ";",
          "INPUT: b = 3.44;",
          "IDENTIFIER: b",
          "=",
          "CONSTANT: 3.44",
          ";",
          "INPUT: }",
          "}"
        ]
      end
    end

    context "err2" do
      let(:input) do
        "
        while (b!=3)
   { int x; x=q+2; }"
      end

      it "no longer errors" do
        expect(result).to eq [
          "INPUT: while ( b != 3 ) {",
          "KEYWORD: WHILE",
          "(",
          "IDENTIFIER: b",
          "!=",
          "CONSTANT: 3",
          ")",
          "{",
          "INPUT: int x;",
          "KEYWORD: INT",
          "IDENTIFIER: x",
          ";",
          "INPUT: x = q + 2;",
          "IDENTIFIER: x",
          "=",
          "IDENTIFIER: q",
          "+",
          "CONSTANT: 2",
          ";",
          "INPUT: }",
          "}",
        ]
      end
    end
  end
end
