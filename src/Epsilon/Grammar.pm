=begin overview

This is the grammar for Epsilon in Perl 6 rules.

=end overview

grammar Epsilon::Grammar is HLL::Grammar;

token TOP {
    <.begin_TOP>
    <expression>
    [ $ || <.panic: "Syntax error"> ]
}

token begin_TOP {
    <?>
}

## Lexer items

# This <ws> rule treats # as "comment to eol".
token ws {
    <!ww>
    [ '#' \N* \n? | \s+ ]*
}

## Expressions

rule expression {
    | <function>
    | <EXPR>
}

rule function {
    [ <identifier> ** ',' ]? '->' <.begin_function> <expression>
}

token begin_function {
    <?>
}

token identifier {
    $<identifier>=[ <ident> [ <ident> | <[\'\-]> ]* ]
}

## Operators

INIT {
    Epsilon::Grammar.O(':prec<z>, :assoc<unary>', '%postcircumfix');
    Epsilon::Grammar.O(':prec<z>, :assoc<unary>', '%unary-applicative');
    Epsilon::Grammar.O(':prec<y>, :assoc<unary>', '%unary-negative');
    Epsilon::Grammar.O(':prec<w>, :assoc<left>',  '%applicative');
    Epsilon::Grammar.O(':prec<u>, :assoc<left>',  '%multiplicative');
    Epsilon::Grammar.O(':prec<t>, :assoc<left>',  '%additive');
    Epsilon::Grammar.O(':prec<f>, :assoc<list>',  '%list');
    Epsilon::Grammar.O(':prec<e>, :assoc<right>', '%cons');
    Epsilon::Grammar.O(':prec<b>, :assoc<right>', '%assign');
    Epsilon::Grammar.O(':prec<a>, :assoc<right>', '%applicative-low');
    Epsilon::Grammar.O(':prec<1>, :assoc<right>', '%sequencing');
}

token postcircumfix:sym<[ ]> {
    '[' <expression> ']'
    <O('%postcircumfix')>
}

token postfix:sym<!> { <sym> <O('%unary-applicative')> }

# these are only optimizations - nil makes them redundant
token prefix:sym<+> { <sym> <O('%unary-negative')> }
token prefix:sym<-> { <sym> <O('%unary-negative')> }

token infix:sym<@>  { <sym> <O('%applicative')> }

token infix:sym<*>  { <sym> <O('%multiplicative')> }
token infix:sym</>  { <sym> <O('%multiplicative')> }

token infix:sym<+>  { <sym> <O('%additive')> }
token infix:sym<->  { <sym> <O('%additive')> }
token infix:sym<~>  { <sym> <O('%additive')> }

token infix:sym<,>  { <sym> <O('%list')> }

token infix:sym<:>  { <sym> <O('%cons')> }

token infix:sym<=>  { <sym> <O('%assign, :pasttype<bind>')> }

token infix:sym<$>  { <sym> <O('%applicative-low')> }

token infix:sym<;>  { <sym> <O('%sequencing')> }

token circumfix:sym<( )> { '(' <.ws> <expression> ')' }

token circumfix:sym<{ }> {
    '{'
        <.begin_block>
        <.ws> <expression>
    '}'
}

token begin_block {
    <?>
}

## Terms

token term:sym<identifier> {
    <identifier>
}

token term:sym<nil> { }

token term:sym<integer> { <integer> }
token term:sym<quote> { <quote> }

proto token quote { <...> }
token quote:sym<'> { <?[']> <quote_EXPR: ':q'> }
token quote:sym<"> { <?["]> <quote_EXPR: ':qq'> }
