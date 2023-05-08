mkdir -p dist/assets/js
mkdir -p dist/assets/css
mkdir -p dist/img

cp -R static/ dist/

sass scss/theme.scss dist/assets/css/theme.css

cp docs-page.html dist/example.html


