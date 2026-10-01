# uv — requirements.txt project

[`demo.sh`](demo.sh) shows how to point uv at
[Chainguard Libraries for Python](https://edu.chainguard.dev/chainguard/libraries/python/)
for a project that uses a plain `requirements.txt` rather than a
`pyproject.toml`.

The [parent `uv` example](../README.md) configures the indexes in
`pyproject.toml` with `[[tool.uv.index]]` entries and installs with `uv sync`.
Many real projects instead keep their dependencies in a `requirements.txt` and
install with `uv pip install -r requirements.txt`. This example covers that
shape, supplying the indexes through environment variables so you do not have to
edit the requirements file or introduce a `pyproject.toml`.

## What the script does

Running `demo.sh` writes a project-local `.netrc` from the pull token, exports
the index configuration as environment variables, creates a fresh virtual
environment, and installs the pinned packages from `requirements.txt` so you can
watch them resolve through Chainguard Libraries — including the remediated
`*+cgr.N` builds.

The project is a **hollow shell** — it has no application code and does nothing
on its own. Its only job is to prove that the configuration is correct and that
dependency resolution works. That said, the environment-variable index
configuration is exactly what you would apply to a real uv project, so treat it
as a working template rather than a throwaway.

## Configuration

| What | Value |
|---|---|
| Config file | `requirements.txt` (dependencies only — no index lines) |
| Indexes | `UV_DEFAULT_INDEX` (`.../python/simple`) and `UV_INDEX` (`.../python-remediated/simple`) |
| Index strategy | `UV_INDEX_STRATEGY=unsafe-best-match` |
| Auth mechanism | project-local `.netrc` referenced by the `NETRC` environment variable |

The environment variables map directly to uv's `--default-index`, `--index`, and
`--index-strategy` flags, so the same configuration works for `uv pip install`,
`uv pip compile`, and `uv sync` without touching the requirements file. uv reads
credentials from the `.netrc` pointed to by `NETRC`. `unsafe-best-match` lets uv
pick the best match across both indexes, so the remediated `*+cgr.N` builds are
chosen.

No PyPI fallback is configured. Chainguard Libraries customer organizations
default to having upstream fallback enabled (entitlement policy
`CHAINGUARD_AND_UPSTREAM`), so any package that is not yet mirrored is served
through the Chainguard index itself and no separate project-level PyPI index is
needed. This default is configurable per organization, not guaranteed behavior —
if an org turns it off, add an explicit PyPI fallback index.

## Run it

Export a pull token first (see [`../../tools/README.md`](../../tools/README.md)):

```bash
eval "$(chainctl auth pull-token --output env --repository=python)"
./demo.sh
```

## Iterate

To test a different package, edit `requirements.txt` and run the script again.
Each run recreates the `.venv` from scratch, so you always start clean — a fast
loop for confirming that any given dependency resolves through Chainguard
Libraries.
