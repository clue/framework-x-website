#!/bin/bash

base=${1:-http://localhost:8080/}
base=${base%/}

n=0
skipping=false
curl() {
    skipping=false
    out=$($(which curl) "$@" 2>&1 | sed 's/\r$//');
}
match() {
    [[ $skipping == true ]] && return 0
    n=$[$n+1]
    echo "$out" | grep "$@" >/dev/null && echo -n . || \
        (echo ""; echo "Error in test $n: Unable to \"grep $@\" this output:"; echo "$out"; exit 1) || exit 1
}
skipif() {
    echo "$out" | grep "$@" >/dev/null && echo -n S && skipping=true || return 0
}
skipifnot() {
    echo "$out" | grep "$@" >/dev/null && return 0 || echo -n S && skipping=true
}

# check index endpoint

curl -v $base/ --compressed
match "HTTP/.* 200"
match -iE "Content-Type: text/html$"
match -iE "Vary: Accept-Encoding$"
skipifnot -iE "Accept-Encoding: (.*, ?)?br(,.*)?$"
match -iE "Content-Encoding: br$"

curl -v $base/ --compressed -H 'Accept-Encoding: gzip'
match "HTTP/.* 200"
match -iE "Content-Type: text/html$"
match -iE "Content-Encoding: gzip$"
match -iE "Vary: Accept-Encoding$"

curl -v $base/robots.txt
match "HTTP/.* 200"
match -iE "Content-Type: text/plain(;.*)?$"

curl -v $base/invalid
match "HTTP/.* 404"
match -i "Content-Type: text/html"

# check HTTP redirects for `docs` endpoint

curl -v $base/docs
match "HTTP/.* 301"
match -iE "Location: .*/docs/$"

curl -v $base/docs/
match "HTTP/.* 302"
match -iE "Location: .*/docs/getting-started/$"

# check HTTP redirects behind CDN

curl -v $base/docs -H 'X-Forwarded-Host: example.com' -H 'X-Forwarded-Proto: https'
match "HTTP/.* 301"
skipif -iE "Location: $base/docs/$"
match -iE "Location: https://example\.com/docs/$"

curl -v $base/docs/ -H 'X-Forwarded-Host: example.com' -H 'X-Forwarded-Proto: http'
match "HTTP/.* 302"
skipif -iE "Location: $base/docs/getting-started/$"
match -iE "Location: http://example\.com/docs/getting-started/$"

# check HTTP redirects for chapter endpoints

curl -v $base/docs/getting-started/
match "HTTP/.* 302"
match -iE "Location: .*/docs/getting-started/quickstart/$"

curl -v $base/docs/best-practices/
match "HTTP/.* 302"
match -iE "Location: .*/docs/best-practices/controllers/$"

curl -v $base/docs/api/
match "HTTP/.* 302"
match -iE "Location: .*/docs/api/app/$"

curl -v $base/docs/async/
match "HTTP/.* 302"
match -iE "Location: .*/docs/async/fibers/$"

curl -v $base/docs/integrations/
match "HTTP/.* 302"
match -iE "Location: .*/docs/integrations/database/$"

# check HTTP redirects for `index.html` at end of path

curl -v $base/index.html
match "HTTP/.* 301"
match -iE "Location: .*/$"

curl -v $base/docs/index.html
match "HTTP/.* 301"
match -iE "Location: .*/docs/$"

curl -v $base/docs/getting-started/quickstart/index.html
match "HTTP/.* 301"
match -iE "Location: .*/docs/getting-started/quickstart/$"

# check HTTP redirects for old documentation structure

curl -v $base/docs/more/
match "HTTP/.* 302"
match -iE "Location: .*/\.\./getting-started/philosophy/$"

curl -v $base/docs/more/philosophy/
match "HTTP/.* 302"
match -iE "Location: .*/\.\./\.\./getting-started/philosophy/$"

curl -v $base/docs/more/architecture/
match "HTTP/.* 302"
match -iE "Location: .*/\.\./\.\./getting-started/philosophy/$"

curl -v $base/docs/more/community/
match "HTTP/.* 302"
match -iE "Location: .*/\.\./\.\./getting-started/community/$"

curl -v $base/docs/async/child-processes/
match "HTTP/.* 302"
match -iE "Location: .*/\.\./\.\./integrations/child-processes/$"

curl -v $base/docs/async/streaming/
match "HTTP/.* 302"
match -iE "Location: .*/\.\./\.\./integrations/streaming/$"

# end

echo "OK ($n)"
