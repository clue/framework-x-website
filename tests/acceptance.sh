#!/bin/bash

base=${1:-http://localhost:8080}

n=0
match() {
    n=$[$n+1]
    echo "$out" | grep "$@" >/dev/null && echo -n . || \
        (echo ""; echo "Error in test $n: Unable to \"grep $@\" this output:"; echo "$out"; exit 1) || exit 1
}

out=$(curl -v $base/ 2>&1);         match "HTTP/.* 200" && match -iP "Content-Type: text/html[\r\n]"
out=$(curl -v $base/invalid 2>&1);  match "HTTP/.* 404" && match -i "Content-Type: text/html"

out=$(curl -v $base/docs 2>&1);                     match "HTTP/.* 301" && match -iP "Location: .*/docs/[\r\n]"
out=$(curl -v $base/docs/ 2>&1);                    match "HTTP/.* 302" && match -iP "Location: .*/docs/getting-started/[\r\n]"
out=$(curl -v $base/docs/getting-started/ 2>&1);    match "HTTP/.* 302" && match -iP "Location: .*/docs/getting-started/quickstart/[\r\n]"
out=$(curl -v $base/docs/best-practices/ 2>&1);     match "HTTP/.* 302" && match -iP "Location: .*/docs/best-practices/controllers/[\r\n]"
out=$(curl -v $base/docs/api/ 2>&1);                match "HTTP/.* 302" && match -iP "Location: .*/docs/api/app/[\r\n]"
out=$(curl -v $base/docs/async/ 2>&1);              match "HTTP/.* 302" && match -iP "Location: .*/docs/async/promises/[\r\n]"
out=$(curl -v $base/docs/integrations/ 2>&1);       match "HTTP/.* 302" && match -iP "Location: .*/docs/integrations/database/[\r\n]"
out=$(curl -v $base/docs/more/ 2>&1);               match "HTTP/.* 302" && match -iP "Location: .*/docs/more/philosophy/[\r\n]"

echo "OK ($n)"
