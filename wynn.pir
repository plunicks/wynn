
=head1 TITLE

wynn.pir - A Wynn compiler.

=head2 Description

This is the entry point for the Wynn compiler.

=head2 Functions

=over 4

=item main(args :slurpy)  :main

Start compilation by passing any command line C<args>
to the Wynn compiler.

=cut

.sub 'main' :main
    .param pmc args

    load_language 'wynn'

    $P0 = compreg 'Wynn'
    $P1 = $P0.'command_line'(args, 'encoding' => 'utf8')
.end

=back

=cut

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:

