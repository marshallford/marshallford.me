# marshallford.me

Personal portfolio/about-me site.

## Highlights

* **Reproducible, signed images:** reproducible container builds, keyless
    [cosign](https://docs.sigstore.dev/cosign/signing/overview/) signatures, and SLSA provenance
    plus SPDX SBOM attestations stored beside each image; `make verify` checks all three
* **Brotli precompression:** every file is compressed at max quality during the build and served
    as-is by [Caddy](Caddyfile), with year-long `immutable` caching on fingerprinted assets
* **Lean frontend:** rendered with Hugo and styled with Tailwind v4 scoped to exactly the classes
    Hugo emits, a self-hosted subsetted variable font, and responsive images with an inlined blur
    placeholder
* **Generated icons:** favicon, Apple touch icon and maskable manifest icons are all derived from a
    single photo at build time
* **Terraform across two clouds:** Cloud Run and Artifact Registry on GCP, DNS on AWS Route 53;
    deploys look up the latest published image, so the workflow passes nothing to Terraform
* **Keyless AWS access:** GitHub OIDC into named profiles, so the same config plans and applies
    from a laptop or a runner with no toggles
* **One definition of every check:** [GitHub Actions CI](.github/workflows/ci.yaml) runs the same
    `make` targets as local development: EditorConfig, yamllint and `terraform fmt` lints, Checkov
    and Trivy security scans, Lighthouse audits

## Stack

* SSG via [Hugo](https://github.com/gohugoio/hugo)
* Styled with [Tailwind CSS](https://tailwindcss.com) v4
* Montserrat self-hosted for display type; system font stack for body text
* Icons from [Font Awesome](https://fontawesome.com), vendored
* No JavaScript
* Website analyzed with [Lighthouse](https://github.com/GoogleChrome/lighthouse-ci)
* Served with [Caddy](https://caddyserver.com) from a container image in Artifact Registry
* CI/CD built on [GitHub Actions](.github/workflows/)
* IaC for GCP Cloud Run and AWS Route 53 via [Terraform](terraform/)

## Credits

* Icons: [Font Awesome Free](https://fontawesome.com) 5.15.4,
    [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/)
* Font: [Montserrat](https://fonts.google.com/specimen/Montserrat) by Julieta Ulanovsky et al.,
    [SIL Open Font License 1.1](https://openfontlicense.org/)
