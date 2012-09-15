require 'dl'
require 'fiddle'

class RubyVM
  class InstructionSequence
    handle = DL::Handle::DEFAULT
    address = handle['rb_iseq_load']
    func = Fiddle::Function.new(address, [DL::TYPE_VOIDP] * 3,
                                DL::TYPE_VOIDP)

    define_singleton_method(:load) do |data, parent = nil, opt = nil|
      func.call(DL.dlwrap(data), parent, opt).to_value
    end
  end
end

class Compiler
  def compile ast
    code = _compile(ast) + [[:leave]]
    iseq = [
      "YARVInstructionSequence/SimpleDataFormat", 2, 0, 1, {},
      "<compiled>", "<compiled>", nil, 1, :top, [], 0, [],
      code
    ]
    RubyVM::InstructionSequence.load iseq
  end

  def _compile ast, args={}
    node_type = ast[0]

    case node_type
    when :call
      fn  = ast[1]
      arg = ast[2]

      _compile(fn, args) + _compile(arg, args) +
        [
          [:send, :call, 1, nil, 0, 0]
        ]
    when :deref
      arg_name = ast[1]

      [
        [:getdynamic, 2, args[arg_name]]
      ]
    when :fn
      param_name = ast[1]
      body       = ast[2]

      args = Hash[args.merge(param_name => -1).map {|k,v| [k, v+1]}]

      [
        [:putnil],
        [:send, :lambda, 0, [
          "YARVInstructionSequence/SimpleDataFormat",
          1,
          2,
          1,
          {},
          "<compiled>",
          "<compiled>",
          nil,
          1,
          :block,
          [param_name],
          1,
          [],
          _compile(body, args) + [[:leave]]
        ], 8, 0]
      ]
    end
  end

  def eval ast
    compile(ast).eval
  end
end
