class Epsilon::Actions is HLL::Actions;

method TOP($/) {
    make PAST::Block.new( $<expression>.ast, :hll<epsilon>, :node($/) );
}

method expression($/) {
    make $<EXPR>.ast;
}

method circumfix:sym<( )>($/) { make $<EXPR>.ast; }

method term:sym<integer>($/) { make $<integer>.ast; }
method term:sym<quote>($/) { make $<quote>.ast; }

method quote:sym<'>($/) { make $<quote_EXPR>.ast; }
method quote:sym<">($/) { make $<quote_EXPR>.ast; }
