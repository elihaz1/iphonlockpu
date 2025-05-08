#!/bin/bash
echo "Unloading iPhone lock launch agent..."
launchctl unload ~/Library/LaunchAgents/com.iphone.lock.plist 2>/dev/null

echo "Removing LaunchAgent plist..."
rm -f ~/Library/LaunchAgents/com.iphone.lock.plist

echo "Removing autolock script..."
rm -f ~/bin/autolockscript.sh

echo "Removing log files..."
rm -f /tmp/iphone-lock-monitor.log
rm -f /tmp/iphone-lock-launchd.out
rm -f /tmp/iphone-lock-launchd.err

echo "iPhone proximity lock system removed successfully."
