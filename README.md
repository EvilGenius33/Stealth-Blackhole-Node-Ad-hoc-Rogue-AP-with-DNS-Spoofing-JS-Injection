# Stealth-Blackhole-Node-Ad-hoc-Rogue-AP-with-DNS-Spoofing-JS-Injection
Stealth Blackhole Node simulates a rogue ad-hoc Wi-Fi AP with OLSR mesh routing, DNS spoofing, JavaScript injection, and traffic capture. Ideal for red teaming, wireless security research, and demonstrating MITM attacks in controlled environments. Use with caution—authorized testing only
# Stealth Blackhole Node  
Ad-hoc Rogue AP with DNS Spoofing & JS Injection

## Overview

**Stealth Blackhole Node** is a rogue access point and mesh node simulator designed for red team operations, wireless attack labs, and educational demos.  
It creates an ad-hoc Wi-Fi network (`ibss` mode), integrates with OLSR-based mesh routing, captures HTTP/DNS traffic, spoofs DNS responses, and injects custom JavaScript payloads into intercepted web pages.

Use this tool to simulate real-world wireless MITM attacks and test the resilience of client devices and mesh networks in controlled environments.

---

## Features

- Ad-hoc Wi-Fi rogue node with fake SSID
- Mesh routing with `olsrd`
- DNS spoofing with `Ettercap`
- HTML/JavaScript injection
- Live packet capture with `tcpdump`
- Automatic cleanup on exit

---

## Requirements

- Linux with `bash`
- Wireless interface capable of monitor & IBSS mode (`iw` compatible)
- Root privileges
- Packages:
  - `olsrd`
  - `tcpdump`
  - `apache2`
  - `ettercap-text-only`

---

## Installation

```bash
sudo apt update
sudo apt install -y olsrd tcpdump apache2 ettercap-text-only

