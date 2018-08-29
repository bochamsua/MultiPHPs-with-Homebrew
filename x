#!/usr/bin/env bash

app="$(basename "$0")"
phpversion="$1"
action="$2"

xdebug_conf_path="$(brew --prefix)/etc/php/$phpversion/conf.d"
xdebug_conf_file="ext-xdebug.ini"
xdebug_conf=$xdebug_conf_path/$xdebug_conf_file

if [ "$phpversion" == "" ]; then
    echo ""
    echo "You need specify php version, e.g: 7.0"
    echo "Usage: ${app} <php_version> <on | off>"
    echo ""

    exit 1

else     
    if [ ! -f "$xdebug_conf" ] && [ ! -f "$xdebug_conf.disabled" ]; then
        echo ""
        echo "The ini file for Xdebug was not found at '$xdebug_conf_path'"
        echo "Did you install Xdebug via Homebrew?"
        echo ""

        exit 1
    else
        STATUS="enabled"

        if [ -f "$xdebug_conf" ] && [ -f "$xdebug_conf.disabled" ]; then
            echo ""
            echo "Detected both enabled and disabled Xdebug ini files. Deleting the disabled one."
            echo ""

            rm -rf "$xdebug_conf.disabled"
            STATUS="enabled"
        elif [ -f "$xdebug_conf.disabled" ]; then
            STATUS="disabled"
        fi

        if [ $# -ge 1 ] && [ "$action" == "on" ] || [ "$action" == "s" ] || [ "$action" == "off" ] || [ "$action" == "o" ]; then
            if [ "$action" == "on" ] || [ "$action" == "s" ]; then
                mv "$xdebug_conf.disabled" "$xdebug_conf" 2> /dev/null
                STATUS="enabled"
            elif [ "$action" == "off" ] || [ "$action" == "o" ]; then
                mv "$xdebug_conf" "$xdebug_conf.disabled" 2> /dev/null
                STATUS="disabled"
            fi
            echo ""
            echo "Xdebug has been $STATUS, restarting PHP"

            launchctl unload ~/Library/LaunchAgents/homebrew.mxcl.php@"${phpversion}".plist
            launchctl load ~/Library/LaunchAgents/homebrew.mxcl.php@"${phpversion}".plist
        else
            echo ""
            echo "Usage: ${app} <php_version> <on | off>"
        fi

        echo ""
        echo "You are running PHP v$phpversion with Xdebug $STATUS"
        echo ""
    fi
fi

