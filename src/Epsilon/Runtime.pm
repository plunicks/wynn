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
    if pir::typeof($right) eq 'Void' {
        $left;
    } else {
        pir::mul($left, +$right);
    }
}

sub &infix:</> ($left, $right) {
    if pir::typeof($left) eq 'Void' {
        pir::div(0, +$right);
    } elsif pir::typeof($right) eq 'Void' {
        $left;
    } else {
        pir::div($left, +$right);
    }
}

sub &infix:<+> ($left, $right) {
    if pir::typeof($right) eq 'Void' {
        $left;
    } else {
        pir::add($left, $right);
    }
}

sub &infix:<-> ($left, $right) {
    if pir::typeof($left) eq 'Void' {
        pir::sub(0, $right);
    } elsif pir::typeof($right) eq 'Void' {
        $left;
    } else {
        pir::sub($left, $right);
    }
}

sub &infix:<~> ($left, $right) {
    pir::concat($left, $right);
}


sub &infix:«<»  ($left, $right) { $left < $right }
sub &infix:«>»  ($left, $right) { $left > $right }
sub &infix:«<=» ($left, $right) { $left <= $right }
sub &infix:«>=» ($left, $right) { $left >= $right }
sub &infix:«==» ($left, $right) { $left == $right }
sub &infix:«!=» ($left, $right) { $left != $right }

sub &infix:<,>(*@args) {
    my @result := ();
    for @args {
        if pir::typeof($_) ne 'Void' {
            @result.push($_)
        }
    }
    return @result;
}

sub &infix:«>>»($left, $right) {
    if pir::typeof($right) eq 'Void' {
        return ($left,);
    } else {
        $right.unshift($left);
    }
}

sub &infix:«<<»($left, $right) {
    if pir::typeof($left) eq 'Void' {
        return ($right,);
    } else {
        $left.push($right);
    }
}

sub &infix:<$> ($left, $right) {
  Q:PIR {
      $P0 = find_lex "$left"
      $P1 = find_lex "$right"
      $P2 = $P0($P1)
      .return($P2)
  }
}

sub &infix:<;>($left, $right) {
    if pir::typeof($right) eq 'Void' {
        $left;
    } else {
        $right;
    }
}

sub &postcircumfix:<[ ]> ($left, $right) {
    if pir::typeof($left) eq 'Void' {
        $left; # return Void when Void is indexed
    } elsif pir::typeof($right) eq 'Void' {
        $left; # return the list when indexed with Void
    } else {
        $left[$right];
    }
}

sub print ($arg) {
    pir::print($arg);
}

sub return ($arg) { $arg }
