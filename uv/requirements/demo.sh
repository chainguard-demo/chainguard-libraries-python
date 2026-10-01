#!/usr/bin/env bash
# Install a requirements.txt project with uv, resolving through Chainguard
# Libraries. Unlike ../demo.sh (which uses a pyproject.toml with
# [[tool.uv.index]] entries and `uv sync`), this shows the other common shape:
# a plain requirements.txt installed with `uv pip install`, with the indexes
# supplied through environment variables. See ./README.md.
# Requires the pull-token env vars — see ../../tools/README.md.
set -euo pipefail

: "${CHAINGUARD_PYTHON_IDENTITY_ID:?Run: eval \"\$(chainctl auth pull-token --output env --repository=python)\" — see ../../tools/README.md}"
: "${CHAINGUARD_PYTHON_TOKEN:?Run: eval \"\$(chainctl auth pull-token --output env --repository=python)\" — see ../../tools/README.md}"

cd "$(dirname "$0")"

# Write a project-local .netrc from the pull token. uv honors the NETRC
# environment variable for index authentication.
cat > .netrc <<EOF
machine libraries.cgr.dev
  login ${CHAINGUARD_PYTHON_IDENTITY_ID}
  password ${CHAINGUARD_PYTHON_TOKEN}
EOF
chmod 600 .netrc
export NETRC="$PWD/.netrc"

# Configure the indexes through environment variables instead of a config file.
# These map to uv's --default-index, --index, and --index-strategy flags and are
# the drop-in way to point an existing requirements.txt build at Chainguard
# Libraries without editing the requirements file or adding a pyproject.toml.
#   - UV_DEFAULT_INDEX replaces PyPI as the default (rebuilds index).
#   - UV_INDEX adds the remediated index that serves the *+cgr.N builds.
#   - unsafe-best-match lets uv pick the best match across both indexes so the
#     remediated builds are chosen.
# No PyPI fallback is configured here. Chainguard Libraries customer orgs
# default to having upstream fallback enabled, so unmirrored packages are served
# through the Chainguard index itself and no separate PyPI index is needed. That
# default is configurable per org, not guaranteed behavior — if an org turns it
# off, add an explicit PyPI fallback index.
export UV_DEFAULT_INDEX="https://libraries.cgr.dev/python/simple"
export UV_INDEX="https://libraries.cgr.dev/python-remediated/simple"
export UV_INDEX_STRATEGY="unsafe-best-match"

rm -rf .venv
uv venv .venv
source .venv/bin/activate

# Swap in any dependency you want to test by editing requirements.txt, then
# re-run this script.
uv pip install -r requirements.txt
uv pip list
