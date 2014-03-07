class Epsilon::Compiler is HLL::Compiler;

INIT {
    Epsilon::Compiler.language('Epsilon');
    Epsilon::Compiler.parsegrammar(Epsilon::Grammar);
    Epsilon::Compiler.parseactions(Epsilon::Actions);
    Epsilon::Compiler.commandline_prompt('<ε> ');
}

method load_library ($name, *$extra) {
    $name := pir::split('::', $name);

    my $filename := pir::join('/', $name) ~ '.ep';

    self.evalfiles($filename);
}
