
=head1 TITLE

wynn.pir - A Wynn compiler.

=head2 Description

This is the base file for the Wynn compiler.

This file includes the parsing and grammar rules from
the src/ directory, loads the relevant PGE libraries,
and registers the compiler under the name 'Wynn'.

=head2 Functions

=over 4

=item onload()

Creates the Wynn compiler using a C<PCT::HLLCompiler>
object.

=cut

.HLL 'wynn'
.loadlib 'io_ops'
.loadlib 'sys_ops'
.loadlib 'wynn_group'

.namespace []

.sub '' :anon :load
    load_bytecode 'HLL.pbc'

    .local pmc hllns, parrotns, imports
    hllns = get_hll_namespace
    parrotns = get_root_namespace ['parrot']
    imports = split ' ', 'PAST PCT HLL Regex'
    parrotns.'export_to'(hllns, imports)
.end

.include 'src/WAST/Compiler.pir'
.include 'src/classes/Object.pir'
.include 'src/classes/Function.pir'
.include 'src/classes/Hash.pir'
.include 'src/classes/List.pir'
.include 'src/gen_grammar.pir'
.include 'src/gen_actions.pir'
.include 'src/gen_compiler.pir'
.include 'src/gen_runtime.pir'

=back

=cut

.namespace [ 'WAST';'Op' ]

.sub 'onload' :anon :load :init
    .local pmc p6meta
    p6meta = new 'P6metaclass'
    p6meta.'new_class'('WAST::Op', 'parent'=>'PAST::Op')

    .return ()
.end


# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:

