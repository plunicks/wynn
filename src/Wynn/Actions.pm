class Wynn::Actions is HLL::Actions;

method TOP($/) {
    our @?BLOCK;
    my $past := @?BLOCK.shift;
    $past.push($<expression>.ast);
    make $past;
}

method begin_TOP($/) {
    our $?BLOCK := PAST::Block.new(:hll<wynn>, :node($/),
                                   :blocktype<declaration>);
    our @?BLOCK := ();
    @?BLOCK.unshift($?BLOCK);
}

method expression($/) {
    make $<EXPR> ?? $<EXPR>.ast !! $<void>.ast;
}

method void($/) {
    make PAST::Val.new(:returns<Void>, :value(), :node($/));
}

method prefix:sym«->»($/) {
    our @?BLOCK;
    our $?BLOCK;
    my $past := $?BLOCK;

    @?BLOCK.shift;
    $?BLOCK := @?BLOCK[0];

    make $past;
}

method infix:sym«->»($/) {
    our @?BLOCK;
    our $?BLOCK;
    my $past := $?BLOCK;

    @?BLOCK.shift;
    $?BLOCK := @?BLOCK[0];

    make $past;
}

method begin_function($/) {
    our @?BLOCK;
    our $?BLOCK := PAST::Block.new(:blocktype<declaration>, :node($/));
    @?BLOCK.unshift($?BLOCK);
}

## Terms

method function_call($/) {
    my $past := $<invocant>.ast;

    for $<factor> {
        $past := PAST::Op.new($past, $_.ast, :pasttype<call>, :name('!call'),
                              :node($/));
    }

    make $past;
}

method term:sym<function_call>($/) {
    make $<function_call>.ast;
}

method term:sym<factor>($/) {
    make $<factor>.ast;
}

## Factors

method factor:sym<( )>($/) { make $<expression>.ast; }

method factor:sym<{ }>($/) {
    our @?BLOCK;

    my $past := @?BLOCK.shift;
    our $?BLOCK := @?BLOCK[0];

    $past.push($<expression>.ast);
    make $past;
}

method begin_block($/) {
    our @?BLOCK;
    our $?BLOCK := PAST::Block.new(:blocktype<immediate>, :node($/));
    @?BLOCK.unshift($?BLOCK);
}

method identifier($/) {
    if $<quoted_identifier> {
        make $<quoted_identifier>.ast;
    } else {
        make ~$<identifier>;
    }
}

method quoted_identifier($/) {
    make ~$<identifier>;
}

method variable($/) {
    make PAST::Var.new(:name($<identifier>.ast), :node($/));
}

method factor:sym<parameter>($/) {
    my $past := $<variable>.ast;
    my $name := $past.name;

    our $?BLOCK;
    $?BLOCK.symbol($name, :scope<parameter>);

    $past.scope('parameter');
    $past.viviself('Undef');

    make $past;
}

sub is_global ($name) {
    my $is_global := 0;

    # kludge - store_lex requires a PMC:
    my $true := 1;

  Q:PIR {
      $P0 = find_lex "$name"
      $S0 = $P0
      $P1 = get_hll_global $S0

      if_null $P1, end_global_test
      $P2 = find_lex "$true"
      store_lex "$is_global", $P2
    end_global_test:
  };

    return $is_global;
}

method factor:sym<variable>($/) {
    my $past := $<variable>.ast;
    my $name := $past.name;

    my $scope := 'lexical';
    my $isdecl := 1;
    our @?BLOCK;

    if is_global($name) {
        $scope := 'package';
        $isdecl := 0;
    } else {
        for @?BLOCK {
            if $_.symbol($name) {
                $isdecl := 0;
            }
        }

        if $isdecl {
            our $?BLOCK;
            $?BLOCK.symbol($name, :scope<lexical>);
        }
    }

    $past.scope($scope);
    $past.isdecl($isdecl);
    $past.viviself('Undef');

    make $past;
}

method factor:sym<symbol>($/) {
    make $<identifier>.ast;
}

method factor:sym<[ ]>($/) {
    make PAST::Op.new($<class_body>.ast, :pasttype<call>,
                      :name('&circumfix:<[ ]>'), :node($/));
}

method class_body($/) {
    our @?BLOCK;
    our $?BLOCK;

    my $past := $?BLOCK;

    for $<variable> {
        my $var := $_.ast;
        $past.symbol($var.name, :scope<lexical>);

        $var.scope('lexical');
        $var.isdecl(1);
        $var.viviself('Undef');
        $past.push($var);
    }

    @?BLOCK.shift;
    $?BLOCK := @?BLOCK[0];

    make $past;
}

method factor:sym<.>($/) {
    make $<object_variable>.ast;
}

method object_variable($/) {
    my $past := $<variable>.ast;
    for $<identifier> {
        $past := PAST::Op.new($past, $_.ast,
                              :pasttype<call>, :name('&infix:<.>'),
                              :node($/));
    }
    make $past;

}

method factor:sym<. =>($/) {
    make PAST::Op.new($<object_variable>.ast, $<identifier>.ast, $<value>.ast,
                      :pasttype<call>, :name('&ternary:<. =>'), :node($/));
}

method factor:sym<integer>($/) {
    make PAST::Val.new(:value(+$/), :returns<Integer>, :node($/));
}
method factor:sym<float>($/) {
    make PAST::Val.new(:value(+$/), :returns<Float>, :node($/));
}
method factor:sym<quote>($/) { make $<quote>.ast; }

method quote:sym<' '>($/) { make $<quote_EXPR>.ast; }
method quote:sym<" ">($/) { make $<quote_EXPR>.ast; }

method quote_escape:sym<interpolation>($/) {
    make $<expression> ?? $<expression>.ast !! '';
}

## Invocants

method invocant:sym<variable>($/) {
    my $past := $<variable>.ast;

    if is_global($past.name) {
        $past.scope('package');
    }

    make $past;
}

method invocant:sym<( )>($/) { make $<expression>.ast; }

method invocant:sym<{ }>($/) {
    our @?BLOCK;

    my $past := @?BLOCK.shift;
    our $?BLOCK := @?BLOCK[0];

    $past.push($<expression>.ast);
    make $past;
}

method invocant:sym<[ ]>($/) {
    make PAST::Op.new($<class_body>.ast, :pasttype<call>,
                      :name('&circumfix:<[ ]>'), :node($/));
}

method invocant:sym<.>($/) {
    make $<object_variable>.ast;
}

method invocant:sym<integer>($/) {
    make PAST::Val.new(:value(+$/), :returns<Integer>, :node($/));
}
method invocant:sym<float>($/) {
    make PAST::Val.new(:value(+$/), :returns<Float>, :node($/));
}
method invocant:sym<quote>($/) { make $<quote>.ast; }
