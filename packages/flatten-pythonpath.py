"""Rewrite a Python app's wrappers to use one merged site directory.

nixpkgs wrappers put every dependency on sys.path separately (PYTHONPATH in the
shell wrapper, site.addsitedir() in the Python script). Each import then stats
every entry, which is cheap natively but ~90 µs per syscall under proot, so a
large app like azure-cli spends seconds just searching sys.path. Merging the
entries into a single symlink tree keeps the lookup order but makes it one stat.

Usage: flatten-pythonpath.py <package> <out>
"""

import hashlib
import os
import re
import sys

STORE = "/nix/store/"
PATH_VAR_RE = re.compile(r"""(export (?:NIX_)?PYTHONPATH=)'([^']*)'""")
SITEDIR_RE = re.compile(
    r"(site\.addsitedir\(p, k\), )\[([^\]]*)\](, site\._init_pathinfo\(\))"
)
# Wrapper chains exec hidden .foo-wrapped files; visible ones (e.g. the
# sys.argv[0] label) are left alone.
STORE_FILE_RE = re.compile(r"/nix/store/[a-z0-9]{32}-[^/'\"\s]+/bin/\.[^/'\"\s]+")
QUOTED_RE = re.compile(r"'([^']*)'")

pkg, out = sys.argv[1], sys.argv[2]
merged_root = os.path.join(out, "lib", "flat-pythonpath")
rewritten = {}  # original store file -> rewritten path in $out


def read_script(path):
    """Return the text of a script, or None for binaries and large files."""
    try:
        if os.path.getsize(path) > 1 << 20:
            return None
        with open(path, "rb") as f:
            data = f.read()
    except OSError:
        return None
    if not data.startswith(b"#!"):
        return None
    try:
        return data.decode()
    except UnicodeDecodeError:
        return None


def merge(srcs, dst):
    """buildEnv-style merge: link unique entries, recurse into shared dirs.

    On a name clash the first source wins, matching sys.path order.
    """
    entries = {}
    for src in srcs:
        if not os.path.isdir(src):
            continue
        for name in sorted(os.listdir(src)):
            entries.setdefault(name, []).append(os.path.join(src, name))
    for name, paths in entries.items():
        target = os.path.join(dst, name)
        dirs = [p for p in paths if os.path.isdir(p)]
        if os.path.isdir(paths[0]) and len(dirs) > 1:
            os.mkdir(target)
            merge(dirs, target)
        else:
            os.symlink(paths[0], target)


def merged_dir(paths):
    """Return a merged tree for the given sys.path entries, creating it once."""
    key = hashlib.sha256("\0".join(paths).encode()).hexdigest()[:12]
    dst = os.path.join(merged_root, key)
    if not os.path.exists(dst):
        os.makedirs(dst)
        merge(paths, dst)
    return dst


def python_paths(text):
    """Store paths the script puts on sys.path, in sys.path order."""
    paths = []
    for m in PATH_VAR_RE.finditer(text):
        paths += m.group(2).split(":")
    for m in SITEDIR_RE.finditer(text):
        paths += QUOTED_RE.findall(m.group(2))
    return [p for p in paths if p.startswith(STORE)]


def chain_paths(path, seen):
    """sys.path entries of a wrapper plus every store script it execs."""
    if path in seen:
        return []
    seen.add(path)
    text = read_script(path)
    if text is None:
        return []
    paths = python_paths(text)
    for ref in STORE_FILE_RE.findall(text):
        paths += chain_paths(ref, seen)
    return paths


def rewrite(path, flat):
    """Write a copy of a wrapper chain pointing at the merged tree."""
    if path in rewritten:
        return rewritten[path]
    text = read_script(path)
    if text is None or not chain_paths(path, set()):
        return None
    dst = os.path.join(out, "bin", os.path.basename(path))
    if dst in rewritten.values():
        # Same name from another store path in the chain; keep both.
        dst += "-" + path[len(STORE):][:8]
    rewritten[path] = dst
    text = PATH_VAR_RE.sub(lambda m: f"{m.group(1)}'{flat}'", text)
    text = SITEDIR_RE.sub(lambda m: f"{m.group(1)}['{flat}']{m.group(3)}", text)
    for ref in set(STORE_FILE_RE.findall(text)):
        new = rewrite(ref, flat)
        if new:
            text = text.replace(ref, new)
    if os.path.lexists(dst):
        os.unlink(dst)
    with open(dst, "w") as f:
        f.write(text)
    os.chmod(dst, 0o555)
    return dst


os.makedirs(out)
for name in os.listdir(pkg):
    if name == "lib":
        # Real directory, so the merged trees can live next to the package's lib.
        os.mkdir(os.path.join(out, "lib"))
        for entry in os.listdir(os.path.join(pkg, "lib")):
            os.symlink(os.path.join(pkg, "lib", entry), os.path.join(out, "lib", entry))
    elif name != "bin":
        os.symlink(os.path.join(pkg, name), os.path.join(out, name))

bin_dir = os.path.join(pkg, "bin")
if os.path.isdir(bin_dir):
    os.mkdir(os.path.join(out, "bin"))
    names = sorted(os.listdir(bin_dir))
    for name in names:
        os.symlink(os.path.join(bin_dir, name), os.path.join(out, "bin", name))
    # Hidden .foo-wrapped scripts are handled through the chain of the visible
    # wrapper that execs them, so they share its full sys.path.
    for name in (n for n in names if not n.startswith(".")):
        real = os.path.realpath(os.path.join(bin_dir, name))
        paths = list(dict.fromkeys(chain_paths(real, set())))
        if not paths:
            continue
        new = rewrite(real, merged_dir(paths))
        link = os.path.join(out, "bin", name)
        if new and new != link:
            os.unlink(link)
            os.symlink(new, link)
        print(f"{name}: {len(paths)} sys.path entries -> 1")
