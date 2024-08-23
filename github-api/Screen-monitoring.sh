#!/bin/bash

# Set thresholds
CPU_THRESHOLD=80
MEM_THRESHOLD=80
DISK_THRESHOLD=90

# Check CPU usage
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
if [ "$(echo "$CPU_USAGE > $CPU_THRESHOLD" | bc)" -eq 1 ]; then
  echo "CPU usage is high: ${CPU_USAGE}%"
else
  echo "CPU usage is normal: ${CPU_USAGE}%"
fi

# Check memory usage
MEM_USAGE=$(free -m | awk '/^Mem:/ {print int($3*100/$2)}')
if [ "$(echo "$MEM_USAGE > $MEM_THRESHOLD" | bc)" -eq 1 ]; then
  echo "Memory usage is high: ${MEM_USAGE}%"
else
  echo "Memory usage is normal: ${MEM_USAGE}%"
fi

# Check disk usage
DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
if [ "$DISK_USAGE" -gt "$DISK_THRESHOLD" ]; then
  echo "Disk usage is high: ${DISK_USAGE}%"
else
  echo "Disk usage is normal: ${DISK_USAGE}%"
fi

# Check network connectivity
if ! ping -c 1 google.com &> /dev/null; then
  echo "Network connectivity"
fi