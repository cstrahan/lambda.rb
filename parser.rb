require 'set'
require './tokenizer'

class Parser
  def definitions
    @defs
  end

  def initialize
    @defs = {}
  end

  def parse_definitions code
    @tokenizer = Tokenizer.new code

    while @tokenizer.peek
      parse_definition
    end

    @defs.each do |name, ast|
      cell = [ast]
      resolve_refs(cell, 0, Set.new)
      @defs[name] = cell[0]
    end

    @defs
  end

  def parse_expression code
    @tokenizer = Tokenizer.new code

    ast = parse_expr
    cell = [ast]
    resolve_refs(cell, 0, Set.new)

    cell[0]
  end

  private

  def resolve_refs parent_node, index, bound
    child_node = parent_node[index]

    case child_node[0]
    when :fn
      bound += [child_node[1]]
      resolve_refs(child_node, 2, bound)
    when :call
      resolve_refs(child_node, 1, bound)
      resolve_refs(child_node, 2, bound)
    when :deref
      name = child_node[1]
      if !bound.include?(name) && @defs.keys.include?(name)
        parent_node[index] = @defs[name]
      end
    end
  end

  def parse_ref
    [:deref, consume(:IDENT).to_sym]
  end

  def parse_definition
    name = consume(:IDENT).to_sym
    consume(:ASSIGN)
    @defs[name] = parse_expr
  end

  def parse_abstraction
    consume(:LAMBDA)
    arg_name = consume(:IDENT)
    consume(:PERIOD)

    [:fn, arg_name.to_sym, parse_expr]
  end

  def parse_expr
    exprs = []

    while start_of_expression?
      type  = peek.first

      case type
      when :IDENT
        exprs << parse_ref
      when :LAMBDA
        exprs << parse_abstraction
      when :LPAREN
        consume(:LPAREN)
        exprs << parse_expr
        consume(:RPAREN)
      end
    end

    exprs.reduce do |acc, n|
      [:call, acc, n]
    end
  end

  def start_of_expression?
    return false unless peek

    type = peek.first

    (type == :LPAREN ||
     type == :IDENT  ||
     type == :LAMBDA  ) && !start_of_new_definition?
  end

  def start_of_new_definition?
    peek(0) && peek(1) &&
    peek(0)[0] == :IDENT &&
    peek(1)[0] == :ASSIGN
  end

  def peek n=0
    @tokenizer.peek(n)
  end

  def next_token
    @tokenizer.next_token
  end

  def consume expected
    type, value, line, col = next_token
    unless type == expected
      raise "parse error at [#{line}, #{col}]; expected #{expected.inspect} token; got #{type.inspect} token"
    end

    value
  end
end
