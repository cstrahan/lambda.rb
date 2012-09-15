require 'strscan'

class Tokenizer
  def initialize source
    @s    = StringScanner.new source
    @peek = []
  end

  def peek(n=0)
    @peek << _next_token until @peek.size > n
    return @peek[n]
  end

  def next_token
    return @peek.shift if @peek.size > 0
    _next_token
  end

  def _next_token
    return nil if @s.eos?

    case
    when t = @s.scan(/#[^\n]*/)    then next_token
    when t = @s.scan(/\s+/)        then next_token
    when t = @s.scan(/\(/)         then [:LPAREN, t]
    when t = @s.scan(/\)/)         then [:RPAREN, t]
    when t = @s.scan(/\u03BB/)     then [:LAMBDA, t]
    when t = @s.scan(/[a-zA-Z_]+/) then [:IDENT, t]
    when t = @s.scan(/:=/)         then [:ASSIGN, t]
    when t = @s.scan(/\./)         then [:PERIOD, t]
    end
  end
end
