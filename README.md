# marshallford.me

Personal portfolio/about-me site.

## Stack

* SSG via [Hugo](https://github.com/gohugoio/hugo)
* Designed with [normalize.css + H5BP](https://github.com/h5bp/html5-boilerplate)
* Styles written in SCSS and transformed with [PostCSS](https://postcss.org/)
* Google Fonts -- Open Sans and Montserrat
* JavaScript transpiled with [esbuild](https://github.com/evanw/esbuild)
* Icons from [Font Awesome](https://github.com/FortAwesome/Font-Awesome)
* Website analyzed with [Lighthouse](https://github.com/GoogleChrome/lighthouse-ci)
* Served with [Nginx](https://github.com/nginxinc/docker-nginx-unprivileged) using [H5BP configuration snippets](https://github.com/h5bp/server-configs-nginx)
* Container image built and pushed to GCR
* CI/CD built on [GitHub Actions](.github/workflows/)
* IaC for GCP Cloud Run and AWS Route53 via [Terraform](terraform/)
