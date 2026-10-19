# Example commands for Chainguard Libraries access

These `chainctl` commands set up and manage access to Chainguard Libraries for
Python. They are the same across package managers. The verify command also
checks local artifacts and saves their SBOMs and attestations.

List entitlements:

```sh
chainctl libraries entitlements list
```

Create entitlement for Python with fallback to upstream PyPI activated:

```shell
chainctl libraries entitlements create --ecosystems=PYTHON --policy=CHAINGUARD_AND_UPSTREAM
```

Create pull token for access to Python libraries and output environment
variable commands. Token valid for 30 days. The `--output env` form sets
`CHAINGUARD_PYTHON_IDENTITY_ID` and `CHAINGUARD_PYTHON_TOKEN`, the variables the
per-tool index configuration reads.

```shell
chainctl auth pull-token --output env --repository=python
```

Evaluate the output directly to export both variables into the current shell:

```shell
eval "$(chainctl auth pull-token --output env --repository=python)"
```

Write the export commands to a script to source later:

```shell
chainctl auth pull-token --output env --repository=python > python-access.sh
source python-access.sh
```

If you are a member of multiple organizations the preceding example commands
must use the `--parent` parameter with the name of your organization:

```shell
eval "$(chainctl auth pull-token --output env --parent=chainguard.edu --repository=python)"
```

```shell
chainctl auth pull-token --output env --repository=python --parent=chainguard.edu > python-access.sh
```

Create a policy for no cooldown and use it for Python:

```shell
chainctl libraries policy create --name=no-cooldown --cooldown-days=0
chainctl libraries policy describe no-cooldown
chainctl libraries policy enable --policy=no-cooldown --ecosystem=PYTHON --mode=ENFORCE
```

List policies

```shell
chainctl libraries policy list
```

List policy bindings to ecosystems:

```shell
chainctl libraries policy bindings list
```

## Verify artifacts and download attestations

`chainctl libraries verify` reports which packages were built from source by
Chainguard. It uses your `chainctl auth login` session rather than the pull-token
environment variables used by the package managers.

Verify a downloaded wheel and save its available companions:

```shell
chainctl libraries verify flask-3.0.1-py3-none-any.whl --output-attestations
```

For this wheel, files are saved under `attestations/flask/3.0.1/`:

- `flask-3.0.1-py3-none-any.whl.signature-bundle.json` — the exact Sigstore
  bundle used to verify the wheel.
- `flask-3.0.1-py3-none-any.whl.pep740-attestation.json` — PEP 740 provenance,
  independently verified for its signature, Chainguard Python signer identity
  and issuer, and wheel digest before saving it as trusted.
- `flask-3.0.1-py3-none-any.whl.sbom.spdx.json` — the SPDX SBOM extracted from
  the verified wheel.

Only verified Chainguard builds produce companion files, and files are saved
when available. The directory uses the normalized package name and version;
the full wheel file name distinguishes different platform and Python builds.
Remediated wheels with a `+cgr` version suffix also support downloads.

Downloads require wheel files. Installed virtual environments and source
distributions do not produce companions. Legacy signature bundles served from
the provenance endpoint do not produce a PEP 740 file.

See the [Chainguard Academy verification guide](https://edu.chainguard.dev/chainguard/libraries/policies-and-security/verification/#download-python-sboms-and-attestations)
for more details.
