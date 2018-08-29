#!/usr/bin/env bash

app="$(basename "$0")"
phpversion="$1"
action="$2"

ioncube_conf_path="$(brew --prefix)/etc/php/$phpversion/conf.d"
ioncube_conf_file="ext-ioncube.ini"
ioncube_conf=$ioncube_conf_path/$ioncube_conf_file

if [ "$phpversion" == "" ]; then
    echo ""
    echo "You need specify php version, e.g: 7.0"
    echo "Usage: ${app} <php_version> <on | off>"
    echo ""

    exit 1

else     
    if [ ! -f "$ioncube_conf" ] && [ ! -f "$ioncube_conf.disabled" ]; then
        echo ""
        echo "The ini file for ioncube was not found at '$ioncube_conf_path'"
        echo "Did you install ioncube via Homebrew?"
        echo ""

        exit 1
    else
        STATUS="enabled"

        if [ -f "$ioncube_conf" ] && [ -f "$ioncube_conf.disabled" ]; then
            echo ""
            echo "Detected both enabled and disabled ioncube ini files. Deleting the disabled one."
            echo ""

            rm -rf "$ioncube_conf.disabled"
            STATUS="enabled"
        elif [ -f "$ioncube_conf.disabled" ]; then
            STATUS="disabled"
        fi

        if [ $# -ge 1 ] && [ "$action" == "on" ] || [ "$action" == "off" ]; then
            if [ "$action" == "on" ]; then
                mv "$ioncube_conf.disabled" "$ioncube_conf" 2> /dev/null
                STATUS="enabled"
            elif [ "$action" == "off" ]; then
                mv "$ioncube_conf" "$ioncube_conf.disabled" 2> /dev/null
                STATUS="disabled"
            fi
            echo ""
            echo "ioncube has been $STATUS, restarting PHP"

            launchctl unload ~/Library/LaunchAgents/homebrew.mxcl.php@"${phpversion}".plist
            launchctl load ~/Library/LaunchAgents/homebrew.mxcl.php@"${phpversion}".plist
        else
            echo ""
            echo "Usage: ${app} <php_version> <on | off>"
        fi

        echo ""
        echo "You are running PHP v$phpversion with ioncube $STATUS"
        echo ""
    fi
fi

