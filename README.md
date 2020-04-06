### Compass (v2.2)

__Compass__ is an asynchronous looper for [monome norns](https://monome.org/docs/norns/) built around the concept of a command sequencer. Commands (assigned per step in the bottom row of the `EDIT` page) modulate sequence, recording, playback and looping behaviors.

----

- [Input Routing & Recording](#input-routing-and-recording)&nbsp;
- [Sequencing](#sequencing)
- [Clock](#clock)
- [Commands](#commands)
- [Grid Control](#grid-control)
- [Keys & Encoders](#keys-and-encoders)
- [Additional Parameters](#additional-parameters)
- [Crow](#crow)

-----

#### Input Routing and Recording

Compass assumes a stereo source by default. If using a mono source:

- head to the system-wide `params` menu once Compass is loaded and change your input source accordingly
- be sure to plug your source into the _left_ input
- set proper monitoring in Norns' `system/audio` settings

By default, Compass records your audio source into two 64s buffers, though a smaller recording window can be set if desired. With a stereo source, each input is paired with a buffer; with a mono source, the input is recorded to both buffers. Stereo effects are then possible with either source type as the read/write heads for each buffer can be split apart by various commands.

Though complexity arises from the relationship between the audio buffers and the command sequencer, as described below, Compass can also be used as a simple looper with an adjustable recording window (1s-64s).

-----

#### Sequencing

Compass' sequencer moves through commands of your choosing that trigger different functions. Use commands to, for example:

* manipulate the sequence's clock or jump to a random step
* randomly change the location of your loop within the buffers
* alter the rate, direction and position of each read/write head

Compass' audio buffers and its sequencer each have their own sense of time in order to facilitate experimentation. Interesting effects and textures can be created by recording into loops long and short, randomizing commands on the fly, modifying the sequence length, etc.

The two buffers are purposefully long, allowing sounds to travel freely to different regions during recording and playback. Unexpected (and hopefully interesting!) things can happen as the two record/playback heads are independently modulated.

-----

#### Clock

Head to the `PARAMS` menu to switch between two clocking options:

- `INTERNAL` -- a handful of commands are available to modify this clock's speed and direction
- `CROW (INPUT 1)` -- note that the commands intended for the internal clock are disabled when this mode is selected

> __Note!__ Switching to either clock option will clear your existing commands! It is recommended you select your desired clock option _before_ you start modifying the command sequence.

Compass' base clock speed is __1s__, but it can be increased in `PARAMS` up to __4s__ to _really slow things down_.  

-----

#### Commands

Commands come in three flavors: those that manipulate the sequence, those that manipulate recording/looping/playback behaviors (i.e. softcut), and those that control crow. Don't worry about memorizing everything, though -- descriptions for all commands are available in the script itself on the `REFERENCE` pages.

__Sequence commands__

- `C` : Set clock interval to 1s. <sup>1</sup>
- `<` : Decrement clock speed (down to 4s.) <sup>1</sup>
- `>` : Increment clock speed (up to 0.0625s.) <sup>1</sup>
- `[` : Set clock to slowest speed (4s.) <sup>1</sup>
- `]` : Set clock to highest speed (0.0625s.) <sup>1</sup>
- `?` : Jump to random step in sequence

__Softcut commands__

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

__Crow commands__

- `T` : Sends pulse to crow output 1
- `V` : Sends random voltage (0-10v) to crow output 2

> <sup>1</sup> These commands are disabled if the clock param is set to `crow in 1` <br>
> <sup>2</sup> The `+`, `-`, and `!` commands move within a range of pre-set rates: { -2x, -1x, -0.5x, 0.5x, 1x, 2x }

-----

#### Grid Control

Connecting a grid opens Compass up to new performance possibilities. Commands and buffers can be controlled by hand, and all of your gestures can be captured by pattern recorders to build evolving sequences of layered sound.

[insert svg]

Compass' screen layout is mimicked on the grid. The buffers are mapped to rows `D` and `E`, and the command sequence is mapped to row `G`. Bright lights indicate - you guessed it - the position of the read/write heads in rows `D` and `E`, and the active command in row `G`. An `ALT` key (`H1`) is available for various functions, which we'll explore shortly.

__Buffers__

The position of each buffer's read/write head can be changed by simply...mashing on some keys in rows `D` and `E`.

__Commands & Clock__

Any command can be fired manually by pressing its corresponding grid key. To facilitate this kind of manual playing, Compass' internal clock can be stopped (and started again) by pressing the `CLOCK` key (`H16`). Note that the `CLOCK` key is dimmed if the clock is stopped.

To quickly adjust the length of the command sequence, hold the `ALT` key (`H1`) while selecting a key in row `G`.

__Pattern Recorders__

In row `A`, you'll find two banks of pattern recorders:

- The first (`A1-4`) records key presses in the buffer rows (`D` and `E`)
- The second (`A13-16`) records key presses in the command row (`G`)

To record a pattern, press any key in the pattern bank. When you've finished playing your pattern, press the same key again to commit it to memory and to start playback. To _stop_ pattern playback, simply press the active pattern key again. To _clear_ a pattern, press its key while holding the `ALT` key.

All of these various states have corresponding brightness levels:

- High: recording/playback in progress
- Medium: pattern stored but playback stopped
- Low: pattern slot empty

Lastly, the pattern banks actually have 2 different modes, which you can switch between using the `PATTERN MODE` key at `B1.`

- In `PATTERN MODE 1` (`B1` key is dim), both of the pattern banks are decoupled, meaning you can have a buffer pattern and a command pattern playing simultaneously and asynchronously.
- In `PATTERN MODE 2` (`B1` key is bright), all 8 patterns slots record presses in both the buffer and command rows. Use this mode is you want your commands and your buffer positions synced.

-----

#### Keys and Encoders

- `E1` : Scroll between the `EDIT` and `REFERENCE` pages
- `E2` : Navigate to step in command row
- `E3` : Select command at step (hold `K2` to prevent unwanted commands from being fired while selecting)
- `K1 + K2` : reset command row to default state (does *not* affect softcut buffers)
- `K1 + K3` : randomize all commands
- `K3` (short) : toggle recording on/off
- `K3` (long) : clear both softcut buffers (does *not* affect command row)
- `K1` (hold) + `E1` : set # of steps in sequence (2 - 16)
- `K1` (hold) + `E2` : set start point
- `K1` (hold) + `E3` : set end point

-----

#### Additional Parameters

Head to Norns' `PARAMS` menu for your `typical` stuff (rate, pan, overdub, start/end points, etc.) and `spicy` stuff (bit reduction, crow input mode, etc.)

-----

#### Crow

[Crow](https://monome.org/docs/crow/) can be connected for further control. Its first input can be used to clock Compass' command sequence (see the [CLOCK](#clock) section above), while the second input can be configured in the `params` menu as follows:

- `OFF` (default): If you don't have a crow, or you aren't using input 2 for anything, leave this as is.
- `SC LEVEL`: Send a voltage source to modulate softcut's level. Range: __0v to +5v__
- `SC RATE` : Send a voltage source to modulate softcut's rate (both voices). Range: __-4v to +4v__
