class Wynn::Compiler is HLL::Compiler;

has @LIBRARY_PATH;

INIT {
    Wynn::Compiler.language('Wynn');
    Wynn::Compiler.parsegrammar(Wynn::Grammar);
    Wynn::Compiler.parseactions(Wynn::Actions);
    Wynn::Compiler.commandline_prompt('<ƿ> ');
    Wynn::Compiler.init_library_path;
}

method post ($source, *%adverbs) {
  Q:PIR {
    .param pmc source
    .param pmc adverbs         :slurpy :named
    $P0 = compreg 'WAST'
    .tailcall $P0.'to_post'(source, adverbs :flat :named)
  };
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

      .local pmc paths, path_it
      paths = self.'get_library_path'()
      path_it = iter paths

    path_loop:
      unless path_it goto failed
      .local string pathname
      pathname = shift path_it
      pathname = concat pathname, '/'
      pathname = concat pathname, basename

      filename = concat pathname, '.pbc'
      $I0 = stat filename, 0
      if $I0 goto eval_parrot

      filename = concat pathname, '.pir'
      $I0 = stat filename, 0
      if $I0 goto eval_parrot

      filename = concat pathname, '.wy'
      $I0 = stat filename, 0
      if $I0 goto eval_wynn

      goto path_loop

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

method init_library_path () {
  Q:PIR {
      .local pmc env, paths
      env = new 'Env'
      paths = new 'ResizableStringArray'
      $S0 = env['WYNN_LIBRARY_PATH']
      if $S0 goto have_lib_paths
      $S0 = '.:lib'
    have_lib_paths:
      paths = split ':', $S0
      setattribute self, '@LIBRARY_PATH', paths
  }
}

method get_library_path () {
    return @LIBRARY_PATH;
}
