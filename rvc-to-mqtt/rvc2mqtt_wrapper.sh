#!/bin/sh

# A placeholder shell script to start rvc2mqtt and automatically restart it if
# it should die. This should be replaced with a systemd unit file or other
# more robust solution.

cd /home/mfischer/rv-control/rvc-to-mqtt

while true
do
  echo "Starting rvc2mqtt.rb"
  ./rvc2mqtt.rb
  sleep 5
done
