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
    my $past := $<EXPR>.ast;

    for $<postfix_expression> {
        $past := PAST::Op.new($past, $_.ast, :pasttype<call>, :node($/),
                              :name('&postcircumfix:sym<' ~
                                    $_<start> ~ ' ' ~ $_<end> ~ '>'));
    }

    make $past;
}

method postfix_expression:sym<[ ]>($/) {
    make $<expression>.ast;
}

method circumfix:sym<( )>($/) { make $<expression>.ast; }

method term:sym<identifier>($/) {
    my $name := ~$<identifier>;

    my $isdecl := 1;
    our @?BLOCK;

    for @?BLOCK {
        if $_.symbol($name) {
            $isdecl := 0;
        }
    }

    if $isdecl {
        our $?BLOCK;
        $?BLOCK.symbol($name, :scope<lexical>);
    }

    make PAST::Var.new(:name($name), :scope<lexical>, :isdecl($isdecl),
                       :viviself<Undef>, :node($/));
}

method term:sym<integer>($/) { make $<integer>.ast; }
method term:sym<quote>($/) { make $<quote>.ast; }

method quote:sym<'>($/) { make $<quote_EXPR>.ast; }
method quote:sym<">($/) { make $<quote_EXPR>.ast; }
