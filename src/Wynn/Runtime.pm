## Utility Functions used in the implementation of other functions

sub __hash_merge ($left, $right) {
  Q:PIR {
      .local pmc left, right, it, key, value
      left = find_lex "$left"
      right = find_lex "$right"

      ## add right's keys to left
      ## (overwrite existing values if the keys exist in left already)
      it = iter right
    loop:
      unless it goto done
      $P0 = shift it
      $P1 = $P0.'key'()
      $P2 = $P0.'value'()
      left[$P1] = $P2
      goto loop
    done:
      .return(left)
  };
}

sub __get_namespace_array ($namespace, $hll_relative?) {
  Q:PIR {
      .local pmc namespace
      .local int hll_relative
      namespace = find_lex "$namespace"
      $P0 = find_lex "$hll_relative"
      hll_relative = $P0

      $I0 = does namespace, 'array'
      if $I0, have_array

      $I0 = isa namespace, 'NameSpace'
      if $I0, have_namespace

      $I0 = isa namespace, 'Void'
      if $I0, have_void

      # assume we have a string and parse it as a name
      .local pmc compiler
      $S0 = namespace
      compiler = compreg 'Wynn'
      namespace = compiler.'parse_name'($S0)
      goto have_array

    have_void:
      namespace = new 'ResizableStringArray'
      goto have_array

    have_namespace:
      $P0 = namespace.'get_name'()
      unless hll_relative, have_namespace_array
      $P0.'shift'() # remove the HLL component of the name
    have_namespace_array:
      namespace = $P0

    have_array:
      .return(namespace)
  }
}

sub __hash (*%args) { %args; }

## Function Calls

sub __call ($invocant, $arg) {
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
    } elsif pir::does($invocant, 'hash') {
        if pir::typeof($arg) eq 'Void' {
            $invocant; # return the hash when indexed with Void
        } elsif pir::does($arg, 'array') {
            # index a hash with a list: return a list of the
            # selected elements
            my $result := [];
            for $arg {
                $result.push($invocant{$_});
            }
            $result;
        } else {
            $invocant{$arg};
        }
    } elsif pir::isa($invocant, 'Class') &&
        !pir::isa($invocant, 'Object') {
        my $object := pir::new($invocant);

        # initialize instance variables from the class definition
        my $namespace := $invocant.get_namespace();
        for $namespace {
            pir::setattribute($object, ~$_, $namespace{$_});
        }

        $object;
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

class CurriedSub {
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

    method () is pirflags<:vtable('get_string')> {
        my @params;

        my $i := 0;
        while $i < $sub.arity {
            @params.push('_');
            $i := $i + 1;
        }

        my $str := '(' ~ pir::join(' -> ', @params) ~ ' -> ...)';
        for @args {
            $str := $str ~ ' ' ~ $_;
        }

        return $str;
    }
}

## Operators as Functions

INIT {
  Q:PIR {
      # Short names for all infix operators.
      # Note that Parrot wraps all these operator symbols in <> when
      # generating sub names even though some of them contain '<' or '>':
      $P0 = get_hll_global '&infix:<:>'
      set_hll_global ':', $P0
      $P0 = get_hll_global '&infix:<::>'
      set_hll_global '::', $P0
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
      $P0 = get_hll_global '&infix:<=>>'
      set_hll_global '=>', $P0
      $P0 = get_hll_global '&infix:<=|>'
      set_hll_global '=|', $P0
      $P0 = get_hll_global '&infix:<;>'
      set_hll_global ';', $P0
      $P0 = get_hll_global '&infix:<.>'
      set_hll_global '.', $P0
  }
}

## Operators
# Lookup a name in a namespace.
# The namespace argument can be an array, a NameSpace, Void, or a string.
sub &infix:<:> ($namespace, $name) {
    $namespace := __get_namespace_array($namespace, 1);

  Q:PIR {
      .local pmc namespace, result
      .local string name
      namespace = find_lex "$namespace"
      $P0 = find_lex "$name"
      name = $P0

      result = get_hll_global namespace, name

      .return(result)
  }
}

# Lookup a name in a true root namespace.
# This can access the root parrot namespace and other languages's namespaces.
# The namespace argument can be an array, a NameSpace, Void, or a string.
sub &infix:<::> ($namespace, $name) {
    $namespace := __get_namespace_array($namespace, 0);

  Q:PIR {
      .local pmc namespace, result
      .local string name
      namespace = find_lex "$namespace"
      $P0 = find_lex "$name"
      name = $P0

      result = get_root_global namespace, name

      .return(result)
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

# The compiler handles «|» in cases where it's applicable.
# In other contexts, it does nothing.
sub &prefix:<|> ($expr) { $expr }

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

sub &infix:<|> ($left, $right) {
    __hash_merge($left, $right);
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
    my $result := pir::new('List');
    for @args {
        if pir::typeof($_) ne 'Void' {
            $result.push($_)
        }
    }
    return $result;
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

sub &infix:<∘> ($left, $right) {
    sub ($arg) {
        # use __call here so that this operator will work on lists and other
        # maps, not just functions
        __call($left, __call($right, $arg));
    };
}

sub &infix:<$> ($left, $right) {
  Q:PIR {
      $P0 = find_lex "$left"
      $P1 = find_lex "$right"
      $P2 = $P0($P1)
      .return($P2)
  }
}

sub &infix:«=>»($key, $value) {
    my %hash;
    %hash{$key} := $value;
    %hash;
}

sub &infix:«=|»($left, $right) {
    if ! pir::does($left, 'hash') && ! pir::defined($left) {
        $left := pir::new('Hash');
    }

    __hash_merge($left, $right);
}

sub &infix:<;>($left, $right) {
    if pir::typeof($right) eq 'Void' {
        $left;
    } else {
        $right;
    }
}

sub &circumfix:<[ ]> ($body) {
    our $?CURRENT_CLASS_ID;

    # auto-named "anonymous" classes somewhat like Parrot does for blocks:
    if !$?CURRENT_CLASS_ID {
        $?CURRENT_CLASS_ID := 1000;
    } else {
        $?CURRENT_CLASS_ID := $?CURRENT_CLASS_ID + 1;
    }
    my $name := "_class$?CURRENT_CLASS_ID";
    my $namespace := __get_namespace_array($name);

  Q:PIR {
      .local pmc name, body, class, it, namespace
      name = find_lex "$name"
      body = find_lex "$body"
      namespace = find_lex "$namespace"

      # if the class exists, then we'll add to it; else create it:
      class = get_class name
      unless_null class, got_class
      class = newclass name
    got_class:

      it = iter body
    loop:
      .local pmc value
      unless it goto done
      $P0 = shift it
      $S0 = $P0.'key'()
      value = $P0.'value'()

      $I0 = isa value, 'Sub'
      unless $I0, not_a_sub
      class.'add_method'($S0, value)

      goto end_attribute

    not_a_sub:
      addattribute class, $S0
      # Set a package variable by the given name in the class's package. The
      # class package variable will be used to initialize new objects of the
      # class.
      set_hll_global namespace, $S0, value

    end_attribute:
      goto loop

    done:
      .return(class)
  }
}

sub callmethod ($object, $method, $arg) {
  Q:PIR {
      .local pmc object, arg, result
      .local string method
      object = find_lex "$object"
      $P0 = find_lex "$method"
      method = $P0
      arg = find_lex "$arg"

      $I0 = isa arg, 'Void'
      if $I0, no_arg
      result = object.method(arg)
      goto end

    no_arg:
      result = object.method()

    end:
      .return(result)
  };
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
  };
    pir::new('Void');
}

sub typeof ($arg) { pir::typeof($arg) }

sub load ($module) {
  Q:PIR {
      .local pmc module, compiler, result
      module = find_lex "$module"
      compiler = compreg 'Wynn'
      result = compiler.'load_library'(module)
      .return(result)
  }
}

sub import ($module, $imports) {
  Q:PIR {
      .local pmc module, imports
      .local pmc compiler, namelist, hllns, ns

      module = find_lex "$module"
      imports = find_lex "$imports"

      $P0 = find_lex "$arg"

      compiler = compreg 'Wynn'
      namelist = compiler.'parse_name'(module)

      .local string filename
      filename = join '/', namelist
      filename = concat filename, '.pbc'
      load_bytecode filename
      namelist.'unshift'('parrot')
      ns = get_root_namespace namelist

      # lookup the names and return the appropriate entries
      .local pmc results, it, import_entry
      .local string import_name
      results = new 'ResizablePMCArray'
      it = iter imports
    loop:
      unless it goto done
      import_name = shift it
      import_entry = get_root_global namelist, import_name
      results.'push'(import_entry)
      goto loop
    done:
      .return(results)
  };
}

sub new ($class) {
    pir::new($class);
}

sub caller ($level?) {
    # default to 1 (the immediate caller of the caller of caller())
    $level := 1 if ! pir::defined($level);

    # add 2 to $level because there are two lexical scopes from here to the
    # caller - the __call function and this function. negative values of
    # $level can be passed to obtain those scopes' LexPads
    $level := $level + 2;

  Q:PIR {
      .local pmc level, lexpad
      level = find_lex "$level"
      $P0 = getinterp
      # if there is no such caller depth, this throws an exception:
      lexpad = $P0["lexpad"; level]

      # if lexpad is null, the given scope has no LexPad - return Undef
      #unless_null lexpad, done
      unless_null lexpad, done
      lexpad = new 'Undef'

    done:
      .return(lexpad)
  }
}

sub get_namespace ($namespace) {
    $namespace := __get_namespace_array($namespace, 1);

  Q:PIR {
      .local pmc namespace_array, namespace_obj
      namespace_array = find_lex "$namespace"
      namespace_obj = get_namespace namespace_array
      .return(namespace_obj)
  }
}

sub get_namespace_root ($namespace) {
    $namespace := __get_namespace_array($namespace, 0);

  Q:PIR {
      .local pmc namespace_array, namespace_obj
      namespace_array = find_lex "$namespace"
      namespace_obj = get_root_namespace namespace_array
      .return(namespace_obj)
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
