sub &postfix:<!> ($expr) {
  Q:PIR {
      $P0 = find_lex "$expr"
      $P1 = $P0()
      .return($P1)
  }
}

sub &prefix:('#') ($expr) {
    if pir::typeof($expr) eq 'ResizablePMCArray' {
        +$expr;
    } elsif pir::typeof($expr) eq 'String' {
        pir::length($expr);
    } else {
        Undef;
    }
}

sub &prefix:<+> ($expr) { +$expr }

sub &prefix:<-> ($expr) {
    pir::neg(+$expr);
}

sub &prefix:<¬> ($expr) {
    pir::isfalse($expr);
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
    1;
}

sub return ($arg) { $arg }

sub load ($module) {
  Q:PIR {
      .local pmc module, compiler, result
      module = find_lex "$module"
      compiler = compreg 'Epsilon'
      result = compiler.'load_library'(module)
      .return(result)
  }
}

sub dump ($arg) {
  Q:PIR {
      $P0 = find_lex "$arg"
      load_bytecode 'dumper.pbc'
      $P1 = get_root_global ['parrot'], '_dumper'
      $P1($P0)
  }
}

# function -> list -> list
sub map ($func) {
    return sub ($list) {
        my @result := ();
        for $list {
            @result.push($func($_));
        }
        return @result;
    }
}

# function -> list -> list
sub grep ($func) {
    return sub ($list) {
        my @result := ();
        for $list {
            if $func($_) {
                @result.push($_);
            }
        }
        return @result;
    }
}
