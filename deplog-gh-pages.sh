# Checkout to gh-pages branch
git checkout gh-pages
git checkout master -- .

# Build project
bun run generate

# Remove all files except dist
ls | grep -v dist | xargs rm -rf

# Move dist files to root
mv dist/* .

# Remove dist folder
rm -rf dist

# Commit and push to gh-pages
git add .
git commit -m "Deploy to gh-pages"
git push origin gh-pages

# Checkout to master
git checkout master