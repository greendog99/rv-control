RV-C Monitor
============

The `rvc2mqtt.rb` script in the `rvc-to-mqtt/` directory listens on the canbus,
decodes all RV-C messages, and publishes the decoded result to an MQTT server.
The `rvc-spec.yaml` file provides the instructions for decoding the RV-C spec.

A great way to view the decoded messages is with the [MQTT
Explorer](http://mqtt-explorer.com/) application. Just connect to the MQTT
broker and monitor all the RV-C messages decoded from the CAN bus.

![MQTT Explorer Sample](../images/mqtt_explorer.png?raw=true)

The intent is to publish the raw RV-C data in an easily consumable format so
that other tools can then interpret and if needed republish the data in other
formats. For example, a program might subscribe to MQTT messages on topic
`DC_DIMMER_STATUS_3/1` and publish (under a different top-level MQTT topic) a
message such as `Main_Ceiling_Light`.

The fully decoded message is published as a JSON object under the `json`
parameter, and each individual component is published as strings or numbers.
Individual parameters makes it easier for programs to monitor a specific
paramenter, such as `operating_status_brightness` for a light. However, if multiple
parameters are needed, they must be extracted from the combined `json` parameter to ensure
they are all from the same RV-C message. For example, calculating a holding tank level
requires dividing the `relative_level` by the `resolution`.

