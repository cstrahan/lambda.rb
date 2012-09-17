λ.rb
====

About
-----

These are some of my experiments with the lambda calculus. This
repository consists of the following goodies:

* λ-calculus parser
* YARV bytecode compiler (applicative order evaluation)
* AST pretty-printer

Syntax
------

Here are some simple examples accepted by the parser:

```
# Note: The following examples are η-expanded for proper execution
# under an applicative order evaluation strategy.

# Church encoded booleans
NOT   := λb.λx.λy.b y x
TRUE  := λx.λy.x
FALSE := NOT TRUE

# Fixed-point combinator
Y := λg.U λf.λx g (U f) x

# Whitespace is insignificant, and definitions need not be terminated, so...
# ... definitions can be broken into multiple lines:
FACTORIAL := Y λf.λn.IF (IS_ZERO n) (
                       ONE
                     )(
                       λ_.MUL n (f (PRED n)) _
                     )

# ... multiple definitions can be placed on one line:
# (but you probably shouldn't)
I := λx.x   U := λx.x x
```

AST
---

The parser generates ASTs consisting of Ruby arrays. The AST is composed
of three kinds of nodes:
* `[:fn, ARG_NAME, BODY]` - anonymous function
* `[:call, FN, ARG]` - function application
* `[:deref, VAR_NAME]` - variable access

As a concrete example, here's the AST for a church-encoded pair: 

```
λx.λy.λf.f x y
```

```ruby
[:fn, :x,
  [:fn, :y,
    [:fn, :f,
      [:call,
        [:call,
          [:deref, :f],
          [:deref, :x]],
        [:deref, :y]]]]]
```

YARV Compiler
-------------

The bytecode compiler translates a given AST into a
`RubyVM::InstructionSequence`. Here's the instruction sequence given the
AST for the U combinator (`λx.x x`):

```ruby
# AST
[:fn, :x,
  [:call,
    [:deref, :x],
    [:deref, :x]]]
```

```ruby
# ISeq
["YARVInstructionSequence/SimpleDataFormat",
 1,
 2,
 1,
 {:arg_size=>0, :local_size=>1, :stack_max=>1},
 "<compiled>",
 "<compiled>",
 nil,
 1,
 :top,
 [],
 0,
 [],
 [[:putnil],
  [:send,
   :lambda,
   0,
   ["YARVInstructionSequence/SimpleDataFormat",
    1,
    2,
    1,
    {:arg_size=>1, :local_size=>2, :stack_max=>2},
    "<compiled>",
    "<compiled>",
    nil,
    1,
    :block,
    [:x],
    1,
    [],
    [[:getdynamic, 2, 0],
     [:getdynamic, 2, 0],
     [:send, :call, 1, nil, 0, 0],
     [:leave]]],
   8,
   0],
  [:leave]]]
```
