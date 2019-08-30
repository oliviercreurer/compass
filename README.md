### Compass (v1.0)

__Compass__ is an experimental, asynchronous looper for Monome Norns built around the concept of a command sequencer. Commands (assigned per step in the bottom row of the `EDIT` page) modulate sequence, recording, playback and looping behaviors. 

-----

__*Input Routing & Recording*__

Compass assumes a stereo source by default. If using a mono source:

- head to the system-wide `params` menu once Compass is loaded and change your input source accordingly
- be sure to plug your source into the _left_ input
- set proper monitoring in Norns' `system/audio` settings

By default, Compass records your audio source into two 64s buffers, though a smaller recording window can be set if desired. With a stereo source, each input is paired with a buffer; with a mono source, the input is recorded to both buffers. Stereo effects are then possible with either source type as the record/playback heads for each buffer can be split apart by various commands.

Though complexity arises from the relationship between the audio buffers and the command sequencer, as described below, Compass can also be used as a simple looper with an adjustable recording window (1s-64s).

-----

__*Sequencing*__

Compass' sequencer moves through commands of your choosing that trigger different functions. Use commands to, for example:

- manipulate the sequence's clock or jump to a random step
- dynamically change your loop length
- push the two record/playback heads to different positions in your loop or sync them back up
- alter the rate and direction of each record/playback head independently

Compass' audio buffers and its sequencer each have their own sense of time in order to facilitate experimentation. Interesting effects and textures can be created by recording into loops long and short, randomizing commands on the fly, modifying the sequence length, etc.

-----

__*Keys & Encoders*__

- `E1` : Scroll between the `EDIT` and `REFERENCE` pages
- `E2` : Navigate to step in command row
- `E3` : Select command at step
- `K2` (short) : reset command row to default state (does *not* affect softcut buffers)
- `K2` (long) : randomize all commands
- `K3` (short) : toggle recording on/off
- `K3` (long) : clear both softcut buffers (does *not* affect command row)
- `K1` (hold) + `E1` : set # of steps in sequence (2 - 16)
- `K1` (hold) + `E2` : set loop start point (can be midi-mapped in `params` menu)
- `K1` (hold) + `E3` : set loop end point (can be midi-mapped in `params` menu)

-----

__*Commands*__

Commands come in two flavors: those that manipulate the sequence, and those that manipulate recording/looping/playback behaviors (i.e. softcut). Don't worry about memorizing everything, though -- descriptions for all commands are available in the script itself on the `REFERENCE` pages. 

Sequence commands:

- `C` : Set clock interval to 1s. 
- `<` : Decrement clock speed (down to 4s.)
- `>` : Increment clock speed (up to 0.0625s.)
- `[` : Set clock to slowest speed (4s.)
- `]` : Set clock to highest speed (0.0625s.)
- `?` : Jump to random step in sequence

Softcut commands: 

- `F` : Set forward (1x) rate 
- `R` : Set reverse (1x) rate 
- `+` : Increase rate † 
- `-` : Decrease rate † 
- `!` : Set a random rate for each record head † 
- `1` : Send _both_ record/playback heads to loop _start_ point
- `P` : Send _each_ record/playback head to a random position within loop

† The `+`, `-`, and `!` commands move within a range of pre-set rates: { -2x, -1x, -0.5x, 0.5x, 1x, 2x }

-----

__*Additional Parameters*__

Head to Norns' `params` menu for additional script parameters like record and overdub levels, pan positions, rate slew, etc. All params (except for `input`) can be midi-mapped. 
