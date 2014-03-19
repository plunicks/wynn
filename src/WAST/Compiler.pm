class WAST::Compiler is PAST::Compiler;

INIT {
    WAST::Compiler.language('WAST');
}

method list_op (PAST::Op $node, :$pasttype!, *%options) {
    my @lvalues;
    my @rvalues;

    # assign each variable on the left side its corresponding value
    my $i := 0;
    while $i < @($node[0]) {
        @lvalues.push($node[0][$i]);
        @rvalues.push($node[1][$i]);
        $i := $i + 1;
    }

    my $past := PAST::Op.new(:pasttype<call>, :name('&infix:<,>'),
                             :node($node));

    $i := 0;
    while $i < @lvalues {
        $past.push(PAST::Op.new(@lvalues[$i], @rvalues[$i],
                                :pasttype($pasttype), :node($node)));
        $i := $i + 1;
    }

    return self.as_post($past, :rtype<P>);
}

multi method bind_list (PAST::Op $node, *%options) {
    if $node[0].isa('PAST::Op') && $node[0]<name> eq '&infix:<,>' {
        self.list_op($node, :pasttype<bind>, |%options);
    } else {
        # left side is not a list, so just call the individual method
        return self.bind($node, |%options);
    }
}

multi method copy_list (PAST::Op $node, *%options) {
    if $node[0].isa('PAST::Op') && $node[0]<name> eq '&infix:<,>' {
        self.list_op($node, :pasttype<copy>, |%options);
    } else {
        # left side is not a list, so just call the individual method
        return self.copy($node, |%options);
    }
}
