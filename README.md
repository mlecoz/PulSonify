# PulSonify
sounds to the tempo of your pulse

Final project for MUS 103 (Sounding the Body: Signals and Systems) at Dartmouth College, Winter 2018

PulSonify is an iOS system that sonifies your heartbeat. PulSonify includes an Apple Watch app (which collects your heartbeat data) and a corresponding iPhone app (which sonifies your heartbeat and gives you customization options for doing so).

To use the system, simply:
1) Open the Watch app and tap "Start" to begin streaming your heart signals.
2) Open the iPhone app and begin toggling the different sound options!
3) Induce changes in your heartbeat to speed up or slow down the sounds!

Note: It takes a little over 10 seconds for the heartbeat data to be made available to the phone app, so don't be alarmed if there's a slight lag.

## Video Demo

## Concept and Purpose

## Technological Details

The PulSonify Watch app reads data from the Watch's heartrate sensors, which it then sends to a cloud database. The Pulsonify iPhone reads from this cloud database periodically, adjusting the rate at
which sounds are emitted. Here's a detailed breakdown of this pipeline.

### Recording Heartrate Data
The Apple Watch is equipped with a PPG (photoplethysmography) sensor, located directly under the face of the watch. This sensor shines green light onto the wearer's skin and detects changes in bloodflow
based on how much of the green light is absorbed by the wearer's veins. While the raw PPG data are not directly available to iOS developers, the processed bpm data are available via Apple APIs. When the wearer has initiated a workout via the watch, the watch will poll the user's bpm every few seconds. PulSonify takes advantage of this frequent workout polling by initiating an "HKWorkoutSession" when the user taps "Start" in the PulSonify Watch app. Every time a new heartrate is available, the PulSonify Watch app stores this value in a CloudKit database. (CloudKit is Apple's built-in cloud database for iOS.)

### Reading Heartrate Data
Every 1 second, the PulSonify iPhone app polls the CloudKit database, asking if there is any new heartrate data. If there is indeed new information, the most recent bpm is the only one that is noted.

### Converting BPM to Tempo
The most recent BPM recording is converted to a "fire interval" that denotes the time (in milliseconds) between heartbeats.
```
func fireInterval(bpm: Int) -> Double {
    return SEC_IN_MIN / bpm * MS_IN_SEC // interval between beats, in ms
}
```
The fire interval is then rounded to the nearest 100 ms for reasons described in the next section.

### Generating Sounds
The PulSonify iPhone app has a timer set to execute a block of code every 100 ms. Timers are unable to effectively handle shorter frequencies than this. This is why the fire interval is rounded to the nearest 100 ms.

Suppose that the fire interval is 700 ms. Then every seventh time the timer is invoked, sounds would be played. The sonification code consists of a series of  `if` statements checking whether each of the
sound switches in the app are turned on. If the switch for a given sound is turned and the proper number of timer cycles have passed, then the sound will play. (That is actually a slight simplification--some sounds are set to play on every second, third, fourth, etc. fire interval. This check is also made before playing a sound.)

To generate sounds, Pulsonify uses AudioKit, an open source API for playing audio - https://github.com/AudioKit/AudioKit.

For simplicity of code organization, each sound option is represented by a class that implements a Swift protocol (interface) that I defined, called `Sound`.

```
protocol Sound {
    var rateRelativeToHeartBeat: Int { get set }
    var isPlaying: Bool { get set }
    func play()
    func stop()
}
```

The final two sound options are convolutions of the heartbeat with sounds I recorded. Because each heartbeat is like an impulse response with unit 1, playing the sound at every fire interval achieves the desired convolution.





