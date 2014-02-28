sub &infix:<*> ($left, $right) {
    pir::mul($left, $right);
}

sub &infix:</> ($left, $right) {
    pir::div($left, $right);
}

sub &infix:<+> ($left, $right) {
    pir::add($left, $right);
}

sub &infix:<-> ($left, $right) {
    pir::sub($left, $right);
}

sub &infix:<,>(*@args) { @args }
