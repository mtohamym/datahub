# How to Publish DataHub to GitHub

## 1. Create a GitHub repository

1. Go to [github.com](https://github.com) and sign in.
2. Click **"+"** (top right) → **"New repository"**.
3. Set:
   - **Repository name:** `datahub` (or any name you like).
   - **Description:** e.g. "Flutter web app to extract PDF pages that contain tables".
   - **Public**.
   - Do **not** check "Add a README", "Add .gitignore", or "Choose a license" (you already have a project).
4. Click **"Create repository"**.

## 2. Push your local project to GitHub

In the project folder (`datahub`), run:

```bash
# If you haven't initialized git yet:
git init

# Stage all files
git add .

# First commit
git commit -m "Initial commit: DataHub PDF page selector"

# Add GitHub as remote (replace YOUR_USERNAME and REPO_NAME with your GitHub username and repo name)
git remote add origin https://github.com/YOUR_USERNAME/REPO_NAME.git

# Rename branch to main if needed, then push
git branch -M main
git push -u origin main
```

**Using SSH instead of HTTPS:**

```bash
git remote add origin git@github.com:YOUR_USERNAME/REPO_NAME.git
git push -u origin main
```

## 3. After publishing

- **Clone elsewhere:** `git clone https://github.com/YOUR_USERNAME/REPO_NAME.git`
- **Run the app:** `cd datahub && flutter pub get && flutter run -d chrome`
- **Build for web:** `flutter build web`

Your `.gitignore` already excludes `build/`, `.dart_tool/`, and other generated files, so only source code is pushed.
