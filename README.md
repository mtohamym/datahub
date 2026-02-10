# DataHub

Flutter web app to extract PDF pages that contain tables. Upload a PDF, review pages one by one, select pages with tables, and export them as numbered JPEG images in a ZIP file — all client-side, no server.

## Run locally

```bash
flutter pub get
flutter run -d chrome
```

## Build for web

```bash
flutter build web --base-href /datahub/
```

## GitHub Pages (live site)

The repo is set up to deploy the web build to **GitHub Pages** via GitHub Actions.

1. **Enable Pages:** In the repo go to **Settings → Pages**. Under **Build and deployment**, set **Source** to **GitHub Actions**.
2. **Push to `main`:** Each push to `main` runs the workflow, builds the Flutter web app, and deploys it.
3. **Site URL:** https://mtohamym.github.io/datahub/

The workflow file is [.github/workflows/deploy-pages.yml](.github/workflows/deploy-pages.yml).
