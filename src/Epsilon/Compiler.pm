class Epsilon::Compiler is HLL::Compiler;

INIT {
    Epsilon::Compiler.language('Epsilon');
    Epsilon::Compiler.parsegrammar(Epsilon::Grammar);
    Epsilon::Compiler.parseactions(Epsilon::Actions);
}
