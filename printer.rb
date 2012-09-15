class Printer
  def print ast
    case ast[0]
    when :fn
      "\u03BB#{ast[1]}.#{print(ast[2])}"
    when :call
      if ast[2][0] == :call || ast[2][0] == :fn
        "#{print(ast[1])} (#{print(ast[2])})"
      else
        "#{print(ast[1])} #{print(ast[2])}"
      end
    when :deref
      ast[1].to_s
    end
  end
end
