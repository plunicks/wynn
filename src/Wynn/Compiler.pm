class Wynn::Compiler is HLL::Compiler;

INIT {
    Wynn::Compiler.language('Wynn');
    Wynn::Compiler.parsegrammar(Wynn::Grammar);
    Wynn::Compiler.parseactions(Wynn::Actions);
    Wynn::Compiler.commandline_prompt('<ƿ> ');
}

method load_library ($name, *$extra) {
    my $namelist := self.parse_name($name);

    my $basename := pir::join('/', $namelist);

  Q:PIR {
      .local pmc basename_pmc
      .local string basename, filename
      .local pmc result
      basename_pmc = find_lex "$basename"
      basename = basename_pmc

      filename = concat basename, '.pbc'
      $I0 = stat filename, 0
      if $I0 goto eval_parrot

      filename = concat basename, '.pir'
      $I0 = stat filename, 0
      if $I0 goto eval_parrot

      filename = concat basename, '.wy'
      $I0 = stat filename, 0
      if $I0 goto eval_wynn

    failed:
      .local pmc name_pmc
      .local string name, error
      name_pmc = find_lex "$name"
      name = name_pmc
      error = concat "Could not find module ", name

      $P0 = new 'Exception'
      $P0 = error
      throw $P0
      .return(0)

    eval_parrot:
      load_bytecode filename
      .return(1)

    eval_wynn:
      result = self.'evalfiles'(filename)
      .return(result)
  };
}
