sub &postfix:<!> ($expr) {
  Q:PIR {
      $P0 = find_lex "$expr"
      $P1 = $P0()
      .return($P1)
  }
}

sub &prefix:<+> ($expr) { +$expr }

sub &prefix:<-> ($expr) {
    pir::neg(+$expr);
}

sub &infix:<@> ($left, $right) {
  Q:PIR {
      $P0 = find_lex "$left"
      $P1 = find_lex "$right"
      $P2 = $P0($P1)
      .return($P2)
  }
}

sub &infix:<*> ($left, $right) {
    pir::mul($left, $right);
}

sub &infix:</> ($left, $right) {
    pir::div($left, $right);
}

sub &infix:<+> ($left, $right) {
    pir::add(+$left, +$right);
}

sub &infix:<-> ($left, $right) {
    pir::sub(+$left, +$right);
}

sub &infix:<~> ($left, $right) {
    pir::concat($left, $right);
}

sub &infix:<,>(*@args) { @args }

sub &infix:<:>($left, $right) {
    $right.unshift($left);
}

sub &infix:<$> ($left, $right) {
  Q:PIR {
      $P0 = find_lex "$left"
      $P1 = find_lex "$right"
      $P2 = $P0($P1)
      .return($P2)
  }
}

sub &infix:<;>($left, $right) { $right }

sub &postcircumfix:<[ ]> ($left, $right) {
    $left[$right];
}

sub print ($arg) {
    pir::print($arg);
}

sub return ($arg) { $arg }
