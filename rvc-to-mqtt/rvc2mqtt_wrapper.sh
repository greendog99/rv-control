#!/bin/sh

cd /home/mfischer/rv-control/rvc-to-mqtt

while true
do
  echo "Starting rvc2mqtt.rb"
  ./rvc2mqtt.rb
  sleep 5
done
