# If has not commited changes - stopr script
if [ -n "$(git status --porcelain)" ]; then
  echo "Please commit your changes before deploying"
  exit 1
fi

# If has no node_modules - install it
if [ ! -d "node_modules" ]; then
  bun install
fi

# Checkout to gh-pages branch
if [ -n "$(git branch --list gh-pages)" ]; then
  git checkout gh-pages --force
else # If has not gh-pages branch - create it
  git checkout --orphan gh-pages
  find . -maxdepth 1 \
    ! -name 'node_modules' \
    ! -name '.git' \
    ! -name '.' \
    -exec rm -rf {} \;
  echo "node_modules" > .gitignore
  git add .gitignore
  git commit -m "Initial commit"
fi

git checkout master -- .

# Recover .gitignore
git checkout gh-pages -- .gitignore

# Prepare project with adding baseUrl to nuxt.config.ts using repository name as baseUrl
REPOSITORY_NAME=$(git remote get-url origin | sed 's/.*\/\([^/]*\)\.git/\1/')
REPOSITORY_OWNER=$(git remote get-url origin | sed 's/.*github.com\/\([^/]*\)\/.*/\1/')

# Insert baseurl after export "default defineNuxtConfig({" line
sed "s/\(export default defineNuxtConfig({\)/\1\n  app: {cdnURL: 'https:\/\/$REPOSITORY_OWNER.github.io\/$REPOSITORY_NAME', buildAssetsDir: 'app'},\n  router: { options: {hashMode: true} },/" nuxt.config.ts > nuxt.config.ts.tmp
mv nuxt.config.ts.tmp nuxt.config.ts

# Build project
bun run generate

# Remove all files except dist and node_modules
find . -maxdepth 1 \
  ! -name 'dist' \
  ! -name '.output' \
  ! -name '.gitignore' \
  ! -name 'node_modules' \
  ! -name '.git' \
  ! -name '.' \
  -exec rm -rf {} \;

# Move dist files to root
mv dist/* .
rm -rf dist .output

# Commit and push to gh-pages
git add .
git commit -m "Deploy to gh-pages"
git push origin gh-pages

# Checkout to master
git checkout master