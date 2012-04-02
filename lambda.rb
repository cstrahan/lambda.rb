#!/usr/bin/env ruby

# Basic combinators
K = -> x { -> y { x } }
I = -> x { x }
C = -> x { -> y { -> z { x[z][y] } } }
T = C[I]
U = -> f { f[f] }
Y = -> g { U[-> f { -> x { g[U[f]][x] } }] }

# Boolean
IF    = I
NOT   = -> b { -> x { -> y { b[y][x] } } }
AND   = -> a { -> b { a[b][a] } }
OR    = -> a { -> b { a[a][b] } }
TRUE  = K
FALSE = NOT[TRUE]

# Predicates
IS_ZERO = -> n { n[-> x { FALSE }][TRUE] }
IS_LEQ  = -> m { -> n { IS_ZERO[SUB[m][n]] } }
IS_LT   = -> m { -> n { IS_LEQ[SUCC[m]][n] } }
IS_GT   = NOT[IS_LT]
IS_GEQ  = NOT[IS_LEQ]
IS_EQ   = -> m { -> n { AND[IS_LEQ[m][n]][IS_LEQ[n][m]] } }
IS_NEQ  = -> m { -> n { NOT[IS_EQ[m][n]] } }

# Natural numbers
ZERO  = FALSE
ONE   = -> f { -> x {     f[x]   } }
TWO   = -> f { -> x {   f[f[x]]  } }
THREE = -> f { -> x { f[f[f[x]]] } }

# Maths
SUCC    = -> n { -> f { -> x { f[n[f][x]] } } }
SHFTINC = -> p { PAIR[SND[p]][SUCC[SND[p]]] }
PRED    = -> n { FST[n[SHFTINC][PAIR[ZERO][ZERO]]] }

ADD = -> m { -> n { n[SUCC][m] } }
SUB = -> m { -> n { n[PRED][m] } }
MUL = -> m { -> n { n[ADD[m]][ZERO] } }
FACTORIAL = Y[-> f {
              -> n {
                IF[IS_ZERO[n]][
                  ONE
                ][
                  -> _ { MUL[n][f[PRED[n]]][_] }
                ]
              }
            }]
DIV = Y[-> f {
        -> m { -> n {
          IF[IS_LEQ[n][m]][
            -> _ { SUCC[f[SUB[m][n]][n]][_] }
          ][
            ZERO
          ]
        } }
      }]
MOD = Y[-> f {
        -> m { -> n {
          IF[IS_LEQ[n][m]][
            -> _ { f[SUB[m][n]][n][_] }
          ][
            m
          ]
        } }
      }]

# Pairs
PAIR = -> x { -> y { -> f { f[x][y] } } }
FST  = -> p { p[TRUE] }
SND  = -> p { p[FALSE] }

# Lists
NIL    = -> f { -> x { x } }
CONS   = -> x { -> l { -> f { -> y { f[x][l[f][y]] } } } }
IS_NIL = -> k { k[-> x { -> l { FALSE } }][TRUE] }
HEAD   = -> k { k[-> x { -> l { x } }][NIL] }
TAIL   = -> l { FST[l[-> x { -> p { PAIR[SND[p]][CONS[x][SND[p]]] } }][PAIR[NIL][NIL]]] }

RANGE = Y[-> f {
          -> m { -> n {
            IF[IS_LEQ[m][n]][
              -> _ { CONS[m][f[SUCC[m]][n]][_] }
            ][
              NIL
            ]
          } }
        }]

MAP   = -> f { FOLDR[-> x { CONS[f[x]] }][NIL] }
FOLDR = -> f { -> x { -> l { l[f][x] } } }
FOLDL = Y[-> f {
          -> g { -> x { -> l {
            IF[IS_NIL[l]][
              x
            ][
              -> _ { f[g][g[HEAD[l]][x]][TAIL[l]][_] }
            ]
          } } }
        }]
REVERSE = FOLDL[CONS][NIL]

SUM     = FOLDL[ADD][ZERO]
PRODUCT = FOLDL[MUL][ONE]
APPEND  = -> k { -> l { FOLDR[CONS][l][k] } }
PUSH    = -> x { -> l { APPEND[l][CONS[x][NIL]] } }

# Strings
TEN       = SUCC[MUL[THREE][THREE]]
RADIX     = TEN
TO_DIGITS = Y[-> f {
              -> n {
                PUSH[MOD[n][RADIX]][
                  IF[IS_LEQ[n][PRED[RADIX]]][
                    NIL
                  ][
                    -> _ { f[DIV[n][RADIX]][_] }
                  ]
                ]
              }
            }]


# FFI
def to_array(l)
  array = []

  until to_boolean(IS_NIL[l])
    array.push(HEAD[l])
    l = TAIL[l]
  end

  array
end

def from_array(array)
  list = array.reverse.inject(NIL) { |l,x| CONS[x][l] }
end

def to_boolean(bool)
  bool[true][false]
end

def to_integer(int)
  int[-> n { n + 1 }][0]
end

def from_integer(n)
  int = ZERO
  n.times do
    int = SUCC[int]
  end

  int
end
