#!/usr/bin/env bash

app="$(basename "$0")"
phpversion="$1"

brew_array=("5.6" "7.0" "7.1" "7.2")


if [ "$phpversion" == "" ]; then

    for i in ${brew_array[@]}
        do
            /usr/local/opt/php@"$i"/bin/php -v
            echo "----------------------------------------------------------------"
        done
    echo ""
    echo "Usage: ${app} <php_version>. E.g: ${app} 7.1"
    echo ""

    exit 1

else     
    /usr/local/opt/php@"${phpversion}"/bin/php -v


fi

