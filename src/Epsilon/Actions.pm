class Epsilon::Actions is HLL::Actions;

method TOP($/) {
    make PAST::Block.new( $<expression>.ast, :hll<epsilon>, :node($/) );
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

method circumfix:sym<( )>($/) { make $<EXPR>.ast; }

method term:sym<integer>($/) { make $<integer>.ast; }
method term:sym<quote>($/) { make $<quote>.ast; }

method quote:sym<'>($/) { make $<quote_EXPR>.ast; }
method quote:sym<">($/) { make $<quote_EXPR>.ast; }
