## Function Calls

{
    my sub __call ($invocant, $arg) {
        if pir::typeof($invocant) eq 'Void' {
            $invocant; # return Void when Void is called/indexed
        } elsif pir::does($invocant, 'array') ||
            pir::does($invocant, 'string') {
            if pir::typeof($arg) eq 'Void' {
                $invocant; # return the list when indexed with Void
            } elsif pir::does($arg, 'array') {
                if pir::does($invocant, 'array') {
                    # index a list with a list: return a list of the
                    # selected elements
                    my $result := [];
                    for $arg {
                        $result.push($invocant[$_]);
                    }
                    $result;
                } else {
                    # index a string with a list: return a string of the
                    # selected characters
                    my $result := '';
                    for $arg {
                        $result := $result ~ $invocant[$_];
                    }
                    $result;
                }
            } else {
                $invocant[$arg];
            }
        } elsif pir::isa($invocant, 'Class') &&
            !pir::isa($invocant, 'Object') {
            pir::new($invocant);
        } else {
            if pir::typeof($invocant) ne 'CurriedSub' &&
                pir::can($invocant, 'arity') && $invocant.arity > 1 {
                # auto-curry functions of more than one argument
                my $csub := pir::new('CurriedSub');
                $csub.set_sub($invocant);
                $invocant := $csub;
            }

          Q:PIR {
              $P0 = find_lex "$invocant"
              $P1 = find_lex "$arg"
              $P2 = $P0($P1)
              .return($P2)
          }
        }
    }

  Q:PIR {
      $P0 = find_lex '__call'
      set_global '!call', $P0

      # Short names for all infix operators.
      # Note that Parrot wraps all these operator symbols in <> when
      # generating sub names even though some of them contain '<' or '>':
      $P0 = get_hll_global '&infix:<@>'
      set_hll_global '@', $P0
      $P0 = get_hll_global '&infix:<*>'
      set_hll_global '*', $P0
      $P0 = get_hll_global '&infix:</>'
      set_hll_global '/', $P0
      $P0 = get_hll_global '&infix:<+>'
      set_hll_global '+', $P0
      $P0 = get_hll_global '&infix:<->'
      set_hll_global '-', $P0
      $P0 = get_hll_global '&infix:<~>'
      set_hll_global '~', $P0
      $P0 = get_hll_global '&infix:<<>'
      set_hll_global '<', $P0
      $P0 = get_hll_global '&infix:<>>'
      set_hll_global '>', $P0
      $P0 = get_hll_global '&infix:<<>>'
      set_hll_global '<>', $P0
      $P0 = get_hll_global '&infix:<<=>'
      set_hll_global '<=', $P0
      $P0 = get_hll_global '&infix:<>=>'
      set_hll_global '>=', $P0
      $P0 = get_hll_global '&infix:<==>'
      set_hll_global '==', $P0
      $P0 = get_hll_global '&infix:<!=>'
      set_hll_global '!=', $P0
      # Note: «,» has different semantics since it's :slurpy.
      $P0 = get_hll_global '&infix:<,>'
      set_hll_global ',', $P0
      $P0 = get_hll_global '&infix:<>>>'
      set_hll_global '>>', $P0
      $P0 = get_hll_global '&infix:<<<>'
      set_hll_global '<<', $P0
      $P0 = get_hll_global '&infix:<$>'
      set_hll_global '$', $P0
      $P0 = get_hll_global '&infix:<;>'
      set_hll_global ';', $P0
      $P0 = get_hll_global '&infix:<.>'
      set_hll_global '.', $P0
  }
}

class CurriedSub is Sub {
    has $sub;
    has @args;
    method arity () { $sub.arity - +@args }

    method set_sub ($s) {
        $sub := $s;
        @args := ();
    }

    method ($arg) is pirflags<:vtable('invoke')> {
        @args.push($arg);
        if (self.arity == 0) {
            return $sub(|@args);
        } else {
            return self;
        }
    }
}

# declare the class Sub so CurriedSub can subclass it.
# defined internally in Parrot.
class Sub {}

## Operators
sub &postcircumfix:<[ ]> ($left, $right) {
    if pir::typeof($left) eq 'Void' {
        $left; # return Void when Void is indexed
    } elsif pir::typeof($right) eq 'Void' {
        $left; # return the list when indexed with Void
    } else {
        $left[$right];
    }
}

sub &postfix:<!> ($expr) {
  Q:PIR {
      $P0 = find_lex "$expr"
      $P1 = $P0()
      .return($P1)
  }
}

sub &prefix:('#') ($expr) {
    if pir::does($expr, 'array') || pir::does($expr, 'hash') {
        +$expr;
    } elsif pir::does($expr, 'string') {
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
    pir::not($expr);
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

sub &infix:«<»  ($left, $right) {
    pir::does($left, 'string') || pir::does($right, 'string')
        ?? $left lt $right !! $left < $right
}

sub &infix:«>»  ($left, $right) {
    pir::does($left, 'string') || pir::does($right, 'string')
        ?? $left gt $right !! $left > $right
}

sub &infix:«<>»  ($left, $right) {
    pir::does($left, 'string') || pir::does($right, 'string')
        ?? ($left lt $right || $left gt $right)
        !! ($left < $right || $left > $right)
}

sub &infix:«<=» ($left, $right) {
    pir::does($left, 'string') || pir::does($right, 'string')
        ?? $left le $right !! $left <= $right
}

sub &infix:«>=» ($left, $right) {
    pir::does($left, 'string') || pir::does($right, 'string')
        ?? $left ge $right !! $left >= $right
}

sub &infix:«==» ($left, $right) {
    pir::does($left, 'string') || pir::does($right, 'string')
        ?? $left eq $right !! $left == $right
}

sub &infix:«!=» ($left, $right) {
    pir::does($left, 'string') || pir::does($right, 'string')
        ?? $left ne $right !! $left != $right
}

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

sub &circumfix:<{{ }}> ($body) {
    our $?CURRENT_CLASS_ID;

    # auto-named "anonymous" classes somewhat like Parrot does for blocks:
    if !$?CURRENT_CLASS_ID {
        $?CURRENT_CLASS_ID := 1000;
    } else {
        $?CURRENT_CLASS_ID := $?CURRENT_CLASS_ID + 1;
    }
    my $name := "_class$?CURRENT_CLASS_ID";

  Q:PIR {
      .local pmc name, body, class, lexinfo, it
      name = find_lex "$name"
      body = find_lex "$body"

      # if the class exists, then we'll add to it; else create it:
      class = get_class name
      unless_null class, got_class
      class = newclass name
    got_class:

      lexinfo = body.'get_lexinfo'()
      it = iter lexinfo
    loop:
      unless it goto done
      $P0 = shift it
      $S0 = $P0.'key'()
      addattribute class, $S0

      goto loop
    done:
      .return(class)
  }
}

sub &infix:<.> ($object, $member) {
  Q:PIR {
      .local pmc object, member, value
      object = find_lex "$object"
      member = find_lex "$member"

      $S0 = member
      value = getattribute object, $S0

      .return(value)
  }
}

sub &ternary:<. => ($object, $member, $value) {
    pir::setattribute($object, ~$member, $value);
    $value;
}

## Utility Functions

sub return ($arg) { $arg }

sub print ($arg) {
    pir::print($arg);
    1;
}

sub dump ($arg) {
  Q:PIR {
      $P0 = find_lex "$arg"
      load_bytecode 'dumper.pbc'
      $P1 = get_root_global ['parrot'], '_dumper'
      $P1($P0)
  }
}

sub load ($module) {
  Q:PIR {
      .local pmc module, compiler, result
      module = find_lex "$module"
      compiler = compreg 'Epsilon'
      result = compiler.'load_library'(module)
      .return(result)
  }
}

## Library Functions

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
