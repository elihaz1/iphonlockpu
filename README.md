iPhone Proximity Lock for macOS – Complete Setup & Usage Guide
==============================================================

This guide walks you through the installation, configuration, execution, and validation of the automatic Mac lock system based on iPhone Bluetooth proximity.

🧾 Files included:
------------------
1. **autolockscript.sh** – The shell script that checks your iPhone's RSSI and locks the screen.
2. **com.iphone.lock.plist** – LaunchAgent to make the script run automatically.
3. **uninstall.sh** – Script to cleanly remove everything.

⚙️ Installation Instructions:
-----------------------------
1. **Move the script to a permanent location:**
```bash
mkdir -p ~/bin
mv ~/Downloads/autolockscript.sh ~/bin/
chmod +x ~/bin/autolockscript.sh
```

2. **Edit the script and configure iPhone name:**
Open `autolockscript.sh` in a text editor and replace:
```bash
IPHONE_NAME="Your iPhone Name Here"
```
With your actual iPhone name as listed in: System Settings > Bluetooth

3. **Copy the LaunchAgent file:**
```bash
cp ~/Downloads/com.iphone.lock.plist ~/Library/LaunchAgents/
```
Make sure it points to your script path, e.g., `/Users/YOUR_USERNAME/bin/autolockscript.sh`

4. **Load the LaunchAgent:**
```bash
launchctl load ~/Library/LaunchAgents/com.iphone.lock.plist
```

5. **Check that it's running:**
```bash
launchctl list | grep com.iphone.lock
```
If you see a numeric PID (process ID), the service is active.

👁️‍🗨️ Real-Time Monitoring:
---------------------------
To monitor the script activity:
```bash
tail -f /tmp/iphone-lock-monitor.log
```

You will see RSSI readings every few seconds. If the iPhone moves out of range and the RSSI drops below -65, it will trigger:
```
RSSI too low. Locking screen...
```

🧪 Manual Test:
---------------
To manually test locking, run:
```bash
/usr/bin/pmset displaysleepnow
```

🧹 Uninstallation:
------------------
1. Run the uninstall script:
```bash
bash ~/Downloads/uninstall.sh
```

2. Alternatively, do it manually:
```bash
launchctl unload ~/Library/LaunchAgents/com.iphone.lock.plist
rm ~/Library/LaunchAgents/com.iphone.lock.plist
rm ~/bin/autolockscript.sh
rm /tmp/iphone-lock-monitor.log
rm /tmp/iphone-lock-launchd.out
rm /tmp/iphone-lock-launchd.err
```

✅ Notes:
--------
- Make sure Bluetooth is enabled and the iPhone is paired at least once.
- In System Settings > Lock Screen, set: "Require password after sleep or screen saver" → Immediately.
- The script adapts scanning frequency: normal every 10s, more frequent (1s) during RSSI drops.

This project is portable, secure, and customizable. Suitable for developers and privacy-conscious users who want their Mac to react to physical presence.
