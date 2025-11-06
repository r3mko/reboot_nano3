# reboot_nano3

A small Linux daemon for embedded RISC-V boards that checks `/proc/uptime` every **-i** minutes and reboots the system if uptime exceeds **-d** days.

> [!IMPORTANT]
> This project is based on firmware 24071801_42c628d

---

## Table of Contents

- [Features](#features)  
- [Prerequisites](#prerequisites)  
- [Installation](#installation)  
- [Usage](#usage)  
- [Init Script](#init-script)  

---

## Features

- Configurable polling interval and uptime threshold  
- Optional debug logging  
- Minimal dependencies—suited for statically-linked embedded builds  

---

## Prerequisites

- RISC-V cross-compiler (`gcc-riscv64-linux-gnu`)  
- Linux with `/proc` filesystem  

---

## Installation

```bash
# Clone and build
git clone https://github.com/r3mko/reboot_nano3.git
cd reboot_nano3

# Build statically for RISC-V thead-c906
riscv64-linux-gnu-gcc -O2 -static \
  -mcpu=thead-c906 -mabi=lp64d \
  -o reboot_nano3 src/reboot_nano3.c

# Copy it to your system (requires sshd)
scp reboot_nano3 admin@canaan:~

# Install to /usr/sbin (requires sshd and root)
ssh admin@canaan 
sudo install -m 755 reboot_nano3 /usr/sbin/
```

---

## Usage

```
Usage: ./reboot_nano3 [-i interval_minutes] [-d max_days] [-D] [-h]
  -i <minutes>   Polling interval in minutes (default: 60)
  -d <days>      Uptime threshold in days (default: 21)
  -D             Enable debug logging
  -h             Show this help and exit
```

---

## Init Script

I use this really simple init script: (TODO: make this better)

```
[admin@canaan ~ ]#cat /etc/init.d/S90reboot_nano3.sh
#!/bin/sh

/usr/sbin/reboot_nano3 -i 60 -d 24
```

---

## Resources

- [nanojb project](https://orca.pet/nanojb/)
