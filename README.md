# Notes

# Raspberry Pi 3B Setup

Install latest Raspbian Buster lite image.

sudo apt -y install ruby-dev
sudo gem install json yaml mqtt


RVC Control
-----------

Programs in the `rvc` directory are used to send commands to the RVC canbus.
Commands are named after the corresponding RVC command. For example,
`dc_dimmer_command_2.rb` sends a DC_DIMMER_COMMAND_2 message (1FEDB).

Programs:

`dc_dimmer_command_2.rb` - Although the RV-C specification indicates this is
intended for dimmable lights, Spyder Controls uses it to control many other DC
loads, including the water pump, ceiling fans, electric water heater, and more.

`dc_dimmer_command_2_pair.rb` - For moving DC devices such as vent lids, TV
lifts, and window shades, Spyder Controls often uses a pair of DC Dimmer IDs,
each controlling motion in one direction. An `OFF` message is sent to the
undesired direction, to stop any existing motion, and an `Toggle` message is
sent to the desired direction to initiate movement for a defined duration. If
the same command is sent again, the second `Toggle` will stop the current
motion without reversing the direction of the device, to stop a shade partway
for example.
