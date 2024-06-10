#!/bin/bash

base=${1:-http://localhost:8080}

n=0
skipping=false
curl() {
    skipping=false
    out=$($(which curl) "$@" 2>&1);
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

# check index endpoint

curl -v $base/
match "HTTP/.* 200"
match -iP "Content-Type: text/html[\r\n]"

curl -v $base/invalid
match "HTTP/.* 404"
match -i "Content-Type: text/html"

# check HTTP redirects for `docs` endpoint

curl -v $base/docs
match "HTTP/.* 301"
match -iP "Location: .*/docs/[\r\n]"

curl -v $base/docs/
match "HTTP/.* 302"
match -iP "Location: .*/docs/getting-started/[\r\n]"

# check HTTP redirects behind CDN

curl -v $base/docs -H 'X-Forwarded-Host: example.com' -H 'X-Forwarded-Proto: https'
match "HTTP/.* 301"
skipif -iP "Location: $base/docs/[\r\n]"
match -iP "Location: https://example\.com/docs/[\r\n]"

curl -v $base/docs/ -H 'X-Forwarded-Host: example.com' -H 'X-Forwarded-Proto: http'
match "HTTP/.* 302"
skipif -iP "Location: $base/docs/getting-started/[\r\n]"
match -iP "Location: http://example\.com/docs/getting-started/[\r\n]"

# check HTTP redirects for chapter endpoints

curl -v $base/docs/getting-started/
match "HTTP/.* 302"
match -iP "Location: .*/docs/getting-started/quickstart/[\r\n]"

curl -v $base/docs/best-practices/
match "HTTP/.* 302"
match -iP "Location: .*/docs/best-practices/controllers/[\r\n]"

curl -v $base/docs/api/
match "HTTP/.* 302"
match -iP "Location: .*/docs/api/app/[\r\n]"

curl -v $base/docs/async/
match "HTTP/.* 302"
match -iP "Location: .*/docs/async/fibers/[\r\n]"

curl -v $base/docs/integrations/
match "HTTP/.* 302"
match -iP "Location: .*/docs/integrations/database/[\r\n]"

# check HTTP redirects for `index.html` at end of path

curl -v $base/index.html
match "HTTP/.* 301"
match -iP "Location: .*/[\r\n]"

curl -v $base/docs/index.html
match "HTTP/.* 301"
match -iP "Location: .*/docs/[\r\n]"

curl -v $base/docs/getting-started/quickstart/index.html
match "HTTP/.* 301"
match -iP "Location: .*/docs/getting-started/quickstart/[\r\n]"

# check HTTP redirects for old documentation structure

curl -v $base/docs/more/
match "HTTP/.* 302"
match -iP "Location: .*/\.\./getting-started/philosophy/[\r\n]"

curl -v $base/docs/more/philosophy/
match "HTTP/.* 302"
match -iP "Location: .*/\.\./\.\./getting-started/philosophy/[\r\n]"

curl -v $base/docs/more/architecture/
match "HTTP/.* 302"
match -iP "Location: .*/\.\./\.\./getting-started/philosophy/[\r\n]"

curl -v $base/docs/more/community/
match "HTTP/.* 302"
match -iP "Location: .*/\.\./\.\./getting-started/community/[\r\n]"

curl -v $base/docs/async/child-processes/
match "HTTP/.* 302"
match -iP "Location: .*/\.\./\.\./integrations/child-processes/[\r\n]"

curl -v $base/docs/async/streaming/
match "HTTP/.* 302"
match -iP "Location: .*/\.\./\.\./integrations/streaming/[\r\n]"

# end

echo "OK ($n)"
