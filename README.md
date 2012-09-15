λ.rb
====

About
-----

These are some of my expirements with the lambda calculus. This
repository consists of the following goodies:

* A λ-calculus parser
* A YARV bytecode compiler

Syntax
-------

Here are some simple examples accepted by the parser:

```
NOT   := λb.λx.λy.b y x
TRUE  := λx.λy.x
FALSE := NOT TRUE
```
