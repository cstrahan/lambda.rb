require 'set'
require './tokenizer'

class Parser
  def parse code
    @tokenizer = Tokenizer.new code
    @defs      = {}

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

  def resolve_refs(parent_node, index, bound)
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

  def parse_definition
    name = consume(:IDENT).to_sym
    consume(:ASSIGN)
    @defs[name] = parse_expression
  end

  def parse_abstraction
    consume(:LAMBDA)
    arg_name = consume(:IDENT)
    consume(:PERIOD)

    [:fn, arg_name.to_sym, parse_expression]
  end

  def parse_expression
    exprs = []

    while start_of_expression?
      type  = peek()[0]

      case type
      when :IDENT
        exprs << parse_ref
      when :LAMBDA
        exprs << parse_abstraction
      when :LPAREN
        consume(:LPAREN)
        exprs << parse_expression
        consume(:RPAREN)
      end
    end

    exprs.reduce do |acc, n|
      [:call, acc, n]
    end
  end

  def start_of_expression?
    return false unless peek(0)

    type = peek(0)[0]

    (type == :LPAREN ||
     type == :IDENT  ||
     type == :LAMBDA  ) && !start_of_new_definition?
  end

  def start_of_new_definition?
    peek(0) && peek(1) &&
    peek(0)[0] == :IDENT &&
    peek(1)[0] == :ASSIGN
  end

  def parse_ref
    name = consume(:IDENT)
    [:deref, name.to_sym]
  end

  private

  def peek(n=0)
    @tokenizer.peek(n)
  end

  def next_token
    @tokenizer.next_token
  end

  def consume(expected)
    type, value = next_token
    raise "expected #{expected} token; got #{type} token" unless type == expected

    value
  end
end
