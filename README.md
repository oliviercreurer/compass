### Compass (v2.2)

__Compass__ is an asynchronous looper for Monome Norns built around the concept of a command sequencer. Commands (assigned per step in the bottom row of the `EDIT` page) modulate sequence, recording, playback and looping behaviors.

- [Input Routing & Recording](#input-routing-and-recording)&nbsp;
- [Sequencing](#sequencing)
- [Clock](#clock)
- [Commands](#commands)
- [Keys & Encoders](#keys-and-encoders)
- [Additional Parameters](#additional-parameters)
- [Crow](#crow)

-----

#### Input Routing and Recording

Compass assumes a stereo source by default. If using a mono source:

- head to the system-wide `params` menu once Compass is loaded and change your input source accordingly
- be sure to plug your source into the _left_ input
- set proper monitoring in Norns' `system/audio` settings

By default, Compass records your audio source into two 64s buffers, though a smaller recording window can be set if desired. With a stereo source, each input is paired with a buffer; with a mono source, the input is recorded to both buffers. Stereo effects are then possible with either source type as the record/playback heads for each buffer can be split apart by various commands.

Though complexity arises from the relationship between the audio buffers and the command sequencer, as described below, Compass can also be used as a simple looper with an adjustable recording window (1s-64s).

-----

#### Sequencing

Compass' sequencer moves through commands of your choosing that trigger different functions. Use commands to, for example:

* manipulate the sequence's clock or jump to a random step
* randomly change the location of your loop within the buffers
* alter the rate, direction and position of each record/playback head

Compass' audio buffers and its sequencer each have their own sense of time in order to facilitate experimentation. Interesting effects and textures can be created by recording into loops long and short, randomizing commands on the fly, modifying the sequence length, etc.

The two buffers are purposefully long, allowing sounds to travel freely to different regions during recording and playback. Unexpected (and hopefully interesting!) things can happen as the two record/playback heads are independently modulated.

-----

#### Clock

Head to the `params` menu to switch between two clocking options:

- `Internal` -- a handful of commands are available to modify this clock's speed and direction
- `Crow (input 1)` -- note that the commands intended for the internal clock are disabled when this mode is selected

> __Note!__ Switching to either clock option will clear your existing commands! It is recommended you select your desired clock option _before_ you start modifying the command sequence.

Compass' base clock speed is __1s__, but it can be increased in `params` up to __4s__ to _really slow things down_.  

-----

#### Commands

Commands come in three flavors: those that manipulate the sequence, those that manipulate recording/looping/playback behaviors (i.e. softcut), and those that control crow. Don't worry about memorizing everything, though -- descriptions for all commands are available in the script itself on the `REFERENCE` pages.

Sequence commands:

- `C` : Set clock interval to 1s. <sup>1</sup>
- `<` : Decrement clock speed (down to 4s.) <sup>1</sup>
- `>` : Increment clock speed (up to 0.0625s.) <sup>1</sup>
- `[` : Set clock to slowest speed (4s.) <sup>1</sup>
- `]` : Set clock to highest speed (0.0625s.) <sup>1</sup>
- `?` : Jump to random step in sequence

Softcut commands:

- `F` : Set forward (1x) rate
- `R` : Set reverse (1x) rate
- `+` : Random forward rate (0.5x - 2x) <sup>2</sup>
- `-` : Random reverse rate (-2x - -0.5x) <sup>2</sup>
- `!` : Set a random rate for each record head <sup>2</sup>
- `1` : Send _both_ record/playback heads to loop _start_ point
- `P` : Send _each_ record/playback head to a random position within loop
- `(` : Randomly change pan position (L)
- `)` : Randomly change pan position (R)
- `::` : Toggle recording on/off

Crow commands:

- `T` : Sends pulse to crow output 1
- `V` : Sends random voltage (0-10v) to crow output 2

> <sup>1</sup> These commands are disabled if the clock param is set to `crow in 1` <br>
> <sup>2</sup> The `+`, `-`, and `!` commands move within a range of pre-set rates: { -2x, -1x, -0.5x, 0.5x, 1x, 2x }

-----

#### Keys and Encoders

- `E1` : Scroll between the `EDIT` and `REFERENCE` pages
- `E2` : Navigate to step in command row
- `E3` : Select command at step (hold `K2` to prevent unwanted commands from being fired while selecting)
- `K1`+`K2` : reset command row to default state (does *not* affect softcut buffers)
- `K1 + K3` : randomize all commands
- `K3` (short) : toggle recording on/off
- `K3` (long) : clear both softcut buffers (does *not* affect command row)
- `K1` (hold) + `E1` : set # of steps in sequence (2 - 16)
- `K1` (hold) + `E2` : set start point
- `K1` (hold) + `E3` : set end point

-----

#### Additional Parameters

Head to Norns' `params` menu for these additional parameters:

- __RECORDING__
  - `INPUT` (Stereo or Mono)
  - `RECORD LEVEL` (0 - 1)
  - `OVERDUB` (0 - 1)
  - `BIT DEPTH`
- __BUFFERS__
  - `RATE (COARSE)` (-2 - 2, in 0.25 increments)
  - `RATE (SLEW)` (0s - 2s)
  - `FADE` (0s - 1s ; adjust crossfade when changing position)
  - `PAN(R)` (0 - 1)
  - `PAN(L)` (0 - 1)
  - `PAN (SLEW)` (0s - 2s)
  - `START POINT`
  - `END POINT`
- __CLOCKING__
  - `CLOCK` (Internal or Crow in 1)
  - `INT. CLOCK SPEED` (1s - 4s)
- __CROW__
  - `MODE (INPUT 2)` (see [crow](#crow) section below for details)
- __ARC__
  - `ARCIFY PARAMS`

-----

#### Crow

As of v2.0, Compass can communicate with crow! Crow's first input can be used to clock Compass' command sequence (see the [clock](#clock) section above), while the second input can be configured in the `params` menu as follows:

- `OFF` (default): If you don't have a crow, or you aren't using input 2 for anything, leave this as is.
- `SC LEVEL`: Send a voltage source to modulate softcut's level. Range: __0v to +5v__
- `SC RATE` : Send a voltage source to modulate softcut's rate (both voices). Range: __-4v to +4v__
