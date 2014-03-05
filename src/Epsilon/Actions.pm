class Epsilon::Actions is HLL::Actions;

method TOP($/) {
    our @?BLOCK;
    my $past := @?BLOCK.shift;
    $past.push($<expression>.ast);
    make $past;
}

method begin_TOP($/) {
    our $?BLOCK := PAST::Block.new(:hll<epsilon>, :node($/),
                                   :blocktype<declaration>);
    our @?BLOCK := ();
    @?BLOCK.unshift($?BLOCK);
}

method expression($/) {
    make $<EXPR>.ast;
}

method postcircumfix:sym<[ ]>($/) {
    make PAST::Op.new($<expression>.ast, :pasttype<call>,
                      :name('&postcircumfix:<[ ]>'), :node($/));
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

method circumfix:sym<( )>($/) { make $<expression>.ast; }

method circumfix:sym<{ }>($/) {
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
        make PAST::Var.new(:name(~$<identifier>), :node($/));
    }
}

method quoted_identifier($/) {
    make PAST::Var.new(:name(~$<identifier>), :node($/));
}

method term:sym<parameter>($/) {
    my $past := $<identifier>.ast;
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

method term:sym<variable>($/) {
    my $past := $<identifier>.ast;
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

method function_identifier($/) {
    my $past := $<identifier>.ast;

    if is_global($past.name) {
        $past.scope('package');
    }

    make $past;
}

method function_call($/) {
    my $past := $<identifier>.ast;

    for $<EXPR> {
        $past := PAST::Op.new($past, $_.ast, :pasttype<call>, :node($/));
    }

    make $past;
}

method term:sym<function_call>($/) {
    make $<function_call>.ast;
}

method term:sym<void>($/) {
    make PAST::Val.new(:returns<Void>, :value(), :node($/));
}

method term:sym<integer>($/) { make $<integer>.ast; }
method term:sym<quote>($/) { make $<quote>.ast; }

method quote:sym<'>($/) { make $<quote_EXPR>.ast; }
method quote:sym<">($/) { make $<quote_EXPR>.ast; }
