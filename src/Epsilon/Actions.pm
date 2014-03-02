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
    our $?BLOCK := PAST::Block.new(:blocktype<declaration>, :node($/));
    @?BLOCK.unshift($?BLOCK);
}

method identifier($/) {
    make ~$<identifier>;
}

method term:sym<parameter>($/) {
    my $name := ~$<identifier>;

    our $?BLOCK;
    $?BLOCK.symbol($name, :scope<parameter>);

    make PAST::Var.new(:name($name), :scope<parameter>,
                       :viviself<Undef>, :node($/));
}

method term:sym<variable>($/) {
    my $name := ~$<identifier>;

    my $scope := 'lexical';
    my $isdecl := 1;
    our @?BLOCK;

    # Search for a global and use it, if it exists.
    my $global := 0;

    # kludge - store_lex requires a PMC:
    my $true := 1;

  Q:PIR {
      $P0 = find_lex "$name"
      $S0 = $P0
      $P1 = get_hll_global $S0

      if_null $P1, end_global_test
      $P2 = find_lex "$true"
      store_lex "$global", $P2
    end_global_test:
  };

    if $global {
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

    make PAST::Var.new(:name($name), :scope($scope), :isdecl($isdecl),
                       :viviself<Undef>, :node($/));
}

method term:sym<nil>($/) {
    make PAST::Val.new(:returns<ResizablePMCArray>, :value(), :node($/));
}

method term:sym<integer>($/) { make $<integer>.ast; }
method term:sym<quote>($/) { make $<quote>.ast; }

method quote:sym<'>($/) { make $<quote_EXPR>.ast; }
method quote:sym<">($/) { make $<quote_EXPR>.ast; }
