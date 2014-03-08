class Epsilon::Compiler is HLL::Compiler;

INIT {
    Epsilon::Compiler.language('Epsilon');
    Epsilon::Compiler.parsegrammar(Epsilon::Grammar);
    Epsilon::Compiler.parseactions(Epsilon::Actions);
    Epsilon::Compiler.commandline_prompt('<ε> ');
}

method load_library ($name, *$extra) {
    my $namelist := pir::split('::', $name);

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

      filename = concat basename, '.ep'
      $I0 = stat filename, 0
      if $I0 goto eval_epsilon

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

    eval_epsilon:
      result = self.'evalfiles'(filename)
      .return(result)
  };
}
