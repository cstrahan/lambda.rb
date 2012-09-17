require_relative '../compiler'
require_relative '../parser'

# Parse our code
charset_source  = File.readlines(File.expand_path("../charset.lambda", __FILE__)).join
fizzbuzz_source = File.readlines(File.expand_path("../fizzbuzz.lambda", __FILE__)).join
parser = Parser.new
parser.parse_definitions(charset_source)
parser.parse_definitions(fizzbuzz_source)
defs = parser.definitions

# Compile some definitions
compiler = Compiler.new
FIZZBUZZ = compiler.eval(defs[:FIZZBUZZ])
HUNDRED  = compiler.eval(defs[:HUNDRED])
HEAD     = compiler.eval(defs[:HEAD])
IS_NIL   = compiler.eval(defs[:IS_NIL])
TAIL     = compiler.eval(defs[:TAIL])

# FFI
CHARS   = "abcdefghijklmnopqrstuvwxyz"
CHARSET = "0123456789" + CHARS + CHARS.upcase

def print_charset
  CHARSET.chars.entries.each_with_index do |c, i|
    from_integer_to_str = -> n {
      n.zero? ? "x" : "f (#{from_integer_to_str[n-1]})"
    }

    puts "CHAR_#{c} := \u03BBf.\u03BBx.#{from_integer_to_str[i]}"
  end
end

def to_char n
  CHARSET[to_integer(n)]
end

def to_string l
  to_array(l).map(&method(:to_char)).join
end

def to_array l
  array = []

  until to_boolean(IS_NIL[l])
    array.push(HEAD[l])
    l = TAIL[l]
  end

  array
end

def to_boolean bool
  bool[true][false]
end

# RUN FIZZBUZZ!
puts to_array(FIZZBUZZ.(HUNDRED)).map(&method(:to_string))
