## Compass (v1.0)

__Compass__ is a sequencer-based asynchronous looper for Monome Norns. Plug in a mono or stereo source, and then use Compass' built-in command sequencer to manipulate recording and looping behaviors along with the sequence itself. 

__*Input Routing & Recording*__

__Compass__ assumes a stereo source by default. If using a mono source:

- head to the system-wide `params` menu once __Compass__ is loaded and change your input source accordingly
- be sure to plug your source into the _left_ input
- set proper monitoring in Norns' `system/audio` settings

By default, __Compass__ records your audio source into two 64s buffers: one for each voice. Though complexity arises from the relationship between the audio buffers and the command sequencer, as described below, __Compass__ can also be used as a simple looper with an adjustable recording window (1s-64s).  

__*Sequencing*__

__Compass'__ audio buffers and its sequencer each have their own sense of time in order to facilitate experimentation. Use the command row on the `EDIT` page to, for example:

- create wild timing fluctuations in your sequence
- dynamically change your loop length
- push the two records heads to different positions in your loop or sync them back up. 
- alter the rate and direction of each record head

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

__*Commands*__

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
- `1` : Send _both_ record heads to loop start point
- `P` : Send _each_ record head to a different position within loop

† The `+`, `-`, and `!` commands move within a range of pre-set rates: { -2x, -1x, -0.5x, 0.5x, 1x, 2x }

__*Params*__

Head to Norns' `params` menu for additional script parameters like rec and overdub levels, pan positions, rate slew, etc. All params (except for `INPUT`) can be midi-mapped. 