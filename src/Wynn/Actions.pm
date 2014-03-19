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

method infix:sym<:=>($/) {
    make WAST::Op.new(:pasttype<bind_list>, :node($/));
}

method infix:sym<=>($/) {
    make WAST::Op.new(:pasttype<copy_list>, :node($/));
}

## Terms

method function_call($/) {
    my $past := $<invocant>.ast;

    for $<argument> {
        $past := PAST::Op.new($past, $_.ast, :pasttype<call>, :name<__call>,
                              :node($/));
    }

    make $past;
}

method term:sym<function_call>($/) {
    make $<function_call>.ast;
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

method parameter($/) {
    make $<variable>.ast;
}

method factor:sym<parameters>($/) {
    my $past := PAST::Node.new(:node($/));

    our $?BLOCK;

    for $<parameter> {
        my $param := $_.ast;
        $past.push($param);

        $?BLOCK.symbol($param.name, :scope<parameter>);

        $param.scope('parameter');
        $param.viviself('Undef') if $_<optional>;
    }

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
    my $past := PAST::Op.new(:pasttype<call>, :name<__hash>, :node($/));

    for $<member_def> {
        $past.push($_.ast);
    }

    make $past;
}

method member_def($/) {
    my $past;
    if $<expression> {
        $past := $<expression>[0].ast;
    } else {
        $past := PAST::Val.new(:value(0), :returns<Undef>, :node($/));
    }
    $past.named($<identifier>.ast);
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
