sub &postfix:<!> ($expr) {
    pir::call($expr);
}

sub &prefix:<+> ($expr) { +$expr }

sub &prefix:<-> ($expr) {
    pir::neg($expr);
}

sub &infix:<@> ($left, $right) {
    pir::call($left, $right);
}

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

sub &infix:<:>($left, $right) {
    $right.unshift($left);
}

sub &infix:<;>($left, $right) { $right }

sub &postcircumfix:sym<[ ]> ($left, $right) {
    $left[$right];
}
