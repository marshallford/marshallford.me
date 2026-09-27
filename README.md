# marshallford.me

Personal portfolio/about-me site.

## Stack

* **Site:** [Hugo](https://github.com/gohugoio/hugo) and [Tailwind CSS](https://tailwindcss.com)
* **Serving:** [Caddy](https://caddyserver.com) container on GCP Cloud Run
* **Infrastructure:** [Terraform](terraform/) for GCP and AWS
* **CI/CD:** [GitHub Actions](.github/workflows/)
* **Supply chain:** [Sigstore cosign](https://docs.sigstore.dev/cosign/signing/overview/) and GitHub artifact attestations
* **Checks:** [Lighthouse CI](https://github.com/GoogleChrome/lighthouse-ci), [Checkov](https://www.checkov.io), [Trivy](https://trivy.dev), yamllint, EditorConfig

## Highlights

* **Reproducible, signed images:** builds pinned to the commit timestamp, keyless cosign signatures, and SLSA provenance plus SPDX SBOM attestations; `make verify` checks all three
* **Precompressed delivery:** Brotli at max quality, served as-is by [Caddy](Caddyfile), with year-long `immutable` caching on fingerprinted assets
* **Lean frontend:** no third-party requests (enforced by CSP), Tailwind CSS generated from only the classes Hugo emits, a preloaded self-hosted font, and a hero image that loads over an inlined blur placeholder
* **Generated standard files:** `security.txt`, `llms.txt` and `humans.txt`, with the `security.txt` expiry derived from the last commit
* **Terraform across two clouds:** deploys look up the latest published image, so the workflow passes nothing to Terraform
* **Keyless AWS access:** GitHub OIDC, so the same config plans and applies from a laptop or a runner
* **One definition of every check:** [CI](.github/workflows/ci.yaml) runs the same `make` targets as local development

## Credits

* Icons: [Font Awesome Free](https://fontawesome.com) 5.15.4, [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/)
* Font: [Montserrat](https://fonts.google.com/specimen/Montserrat) by Julieta Ulanovsky et al., [SIL Open Font License 1.1](https://openfontlicense.org/)
