# RV Control

This project's goal is to enable two-way communication between an RV's CAN bus
network and an MQTT message broker. It is not meant to be an end-to-end RV
control or automation solution, but rather a foundation which other tools and
projects can be built upon.

This is a from-scratch rewrite of some of the components of
[CoachProxyOS](https://github.com/rvc-proxy/coachproxy-os/).

Download the complete [RV-C
specification](http://www.rv-c.com/?q=node/75) for details on the
protocol and its messages. This PDF file is critical for
understanding how to communicate with RV-C devices.

What it does
------------

[Monitoring](rvc-monitor/):
* Receives raw RV-C messages from the CAN bus.
* Decodes those messages into human-readable JSON objects according to the RV-C specification.
* Decodes additional, vendor-proprietary RV-C messages (currently just a few custom messages used by Spyder Controls).
* Publishes decoded messages to an MQTT message broker.

[Controlling](rvc-control/):
* Receives commands from the MQTT Broker.
* Encodes those commands into RV-C messages.
* Sends the messages onto the CAN bus.

What it does NOT do
-------------------

* Interpretation of messages (e.g. this message means "Hallway Light").
* Any kind of logic (e.g. do something when a certain message is recevied).
* Any kind of user interface.

This and other functionality will be developed as a separate project.

System overview
---------------

The yellow area outlines the scope of this project. Other example
components may be developed at a future date.

![System Overview Diagram](images/rv_control_diagram.png?raw=true)

Requirements
------------

* A computer with a CAN bus network card. This will almost always be a
Raspberry Pi 3B computer with a PiCAN2 board. Install the canbus utilities:
  ~~~
  sudo apt -y install can-utils
  ~~~
  Add the following to the end of /boot/config.txt to enable the canbus card:
  ~~~
  dtparam=spi=on
  dtoverlay=mcp2515-can0,oscillator=16000000,interrupt=25
  dtoverlay=spi-bcm2835-overlay
  ~~~
* The latest Raspberry Pi OS operating system image (Buster Lite is used for
development).
* The Ruby development environment and supporting Gems:
  ~~~
  sudo apt -y install ruby-dev
  sudo gem install json yaml mqtt
  ~~~
* An MQTT message broker to communicate with. Often this will run on the same
Raspberry Pi, and can be installed easily:
  ~~~
  sudo apt -y install mosquitto
  ~~~

# Component Documentation

* [RV-C Monitor](rvc-monitor/)
* [RV-C Control](rvc-control/)

