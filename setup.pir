#!/usr/bin/env parrot

=head1 NAME

setup.pir - Python distutils style

=head1 DESCRIPTION

No Configure step, no Makefile generated.

=head1 USAGE

    $ parrot setup.pir build
    $ parrot setup.pir test
    $ sudo parrot setup.pir install

=cut

.sub 'main' :main
    .param pmc args
    $S0 = shift args
    load_bytecode 'distutils.pbc'

    .local int reqsvn
    $P0 = new 'FileHandle'
    $P0.'open'('PARROT_REVISION', 'r')
    $S0 = $P0.'readline'()
    reqsvn = $S0
    $P0.'close'()

    .local pmc config
    config = get_config()
    $I0 = config['revision']
    unless $I0 goto L1
    unless reqsvn > $I0 goto L1
    $S1 = "Parrot revision r"
    $S0 = reqsvn
    $S1 .= $S0
    $S1 .= " required (currently r"
    $S0 = $I0
    $S1 .= $S0
    $S1 .= ")\n"
    print $S1
    end
  L1:

    $P0 = new 'Hash'
    $P0['name'] = 'Wynn'
    $P0['abstract'] = 'the Wynn compiler'
    $P0['description'] = 'the Wynn for Parrot VM.'

    # build
    $P1 = new 'Hash'
    $P1['wynn_ops'] = 'src/ops/wynn.ops'
    $P0['dynops'] = $P1

    $P2 = new 'Hash'
    $P3 = split ' ', 'src/pmc/wynn.pmc src/pmc/void.pmc'
    $P2['wynn_group'] = $P3
    $P0['dynpmc'] = $P2

    $P4 = new 'Hash'
    $P4['src/gen_actions.pir'] = 'src/Wynn/Actions.pm'
    $P4['src/gen_compiler.pir'] = 'src/Wynn/Compiler.pm'
    $P4['src/gen_grammar.pir'] = 'src/Wynn/Grammar.pm'
    $P4['src/gen_runtime.pir'] = 'src/Wynn/Runtime.pm'
    $P4['src/WAST/Compiler.pir'] = 'src/WAST/Compiler.pm'
    $P0['pir_nqp-rx'] = $P4

    $P5 = new 'Hash'
    $P6 = split "\n", <<'SOURCES'
src/wynn.pir
src/gen_actions.pir
src/gen_compiler.pir
src/gen_grammar.pir
src/gen_runtime.pir
src/WAST/Compiler.pir
src/classes/Function.pir
src/classes/Hash.pir
src/classes/List.pir
src/classes/Object.pir
SOURCES
    $S0 = pop $P6
    $P5['wynn/wynn.pbc'] = $P6
    $P5['wynn.pbc'] = 'wynn.pir'
    $P0['pbc_pir'] = $P5

    $P7 = new 'Hash'
    $P7['parrot-wynn'] = 'wynn.pbc'
    $P0['installable_pbc'] = $P7

    # test
    $S0 = get_parrot()
    $S0 .= ' wynn.pbc'
    $P0['prove_exec'] = $S0

    # install
    $P0['inst_lang'] = 'wynn/wynn.pbc'

    # dist
    $P0['doc_files'] = 'README'

    .tailcall setup(args :flat, $P0 :flat :named)
.end


# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:

