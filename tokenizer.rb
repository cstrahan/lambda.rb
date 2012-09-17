require 'strscan'

class Tokenizer
  def initialize source
    @s    = StringScanner.new source
    @peek = []

    @current_line   = 1
    @current_column = 1
  end

  def peek n=0
    @peek << _next_token until @peek.size > n
    return @peek[n]
  end

  def next_token
    return @peek.shift if @peek.size > 0
    _next_token
  end

  private

  def _next_token
    return nil if @s.eos?

    case
    when t = scan(/#[^\n]*\s+/, :COMMENT)  then next_token
    when t = scan(/\s+/, :WHITESPACE)      then next_token
    when t = scan(/\(/, :LPAREN)           then t
    when t = scan(/\)/, :RPAREN)           then t
    when t = scan(/\u03BB/, :LAMBDA)       then t
    when t = scan(/[0-9a-zA-Z_]+/, :IDENT) then t
    when t = scan(/:=/, :ASSIGN)           then t
    when t = scan(/\./, :PERIOD)           then t
    else
      raise "unexpected token at [#{@current_line}, #{@current_column}]"
    end
  end

  def scan regexp, token_name
    match = @s.scan(regexp)
    return nil unless match

    token = [token_name, match, @current_line, @current_column]

    if match
      lines, chars = char_offsets(match)

      if lines > 0
        @current_line += lines
        @current_column = chars + 1
      else
        @current_column += chars
      end
    end

    token
  end

  def char_offsets str
    return [0, 0] unless str
    len         = str.length
    col_offset  = len
    line_offset = 0

    idx = -1
    while idx = str.index("\n", idx+1)
      line_offset += 1
      col_offset  = len - idx -1
    end

    [line_offset, col_offset]
  end
end
