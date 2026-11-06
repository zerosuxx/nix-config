# Wraps a Python application so its wrappers put a single merged site
# directory on sys.path instead of one entry per dependency; see
# flatten-pythonpath.py. Meant for proot (Termux), where every stat is slow.
pkgs: pkg:

pkgs.runCommand "${pkg.name}-flat-pythonpath"
  {
    nativeBuildInputs = [ pkgs.python3 ];
    meta = pkg.meta or { };
    passthru.unflattened = pkg;
  }
  ''
    python3 ${./flatten-pythonpath.py} ${pkg} $out
  ''
