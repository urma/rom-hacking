# ROM Hacking

This repository was created to host various support scripts, tools and documentation associated with the **ROM Hacking for Fun, Profit & Infinite Lives** presentation.

## Scripts
Currently there is a single script, `difftool.rb`. This scripts allows for comparison between multiple binary files with user-controllable comparison criteria. It was created to provide a more programmer-friendly (and emulator-independent) version of the [FCEUXD SP](http://www.the-interweb.com/serendipity/index.php?/categories/9-FCEUXD-SP) RAM Filter:

![RAM Filter](http://www.the-interweb.com/bdump/fceuxdsp/filter2.png)

The `difftool.rb` implementation does not support different criteria between each state snapshot, so you cannot do searches for values that increased between two snapshots, and decresed between the following ones. It does drop you into a nice [Pry](http://pryrepl.org/) prompt where you peek and poke freely around the memory contents.

### Setup
Dependencies for all the scripts are handled by a `Gemfile`. You can install all the dependencies automatically using [Bundler](http://gembundler.com/).

    [rom-hacking/scripts]$ bundle install
    Using coderay (1.0.7) 
    Using method_source (0.8) 
    Using slop (3.3.3) 
    Using pry (0.9.10) 
    Using bundler (1.2.0) 
    Your bundle is complete! Use `bundle show [gemname]` to see where a bundled gem is installed.

### Usage
    ruby difftool.rb file1 file2 [...] [file_n]

Since the tool is geared towards memory dumps from emulators, it assumes the dumps are from the same memory regions, and thus have the same size. This will be validated before loading the files, and the script will abort if any of them have a different size.

The files will be loaded in the order provided on the command, so be careful when using shell expansion wildcards, such as `*.bin` or `filedata??.bin` -- shell expansion will usually return the list of matching files in alphabetical order, which might not be what you want.

After loading all the provided files, the script will drop the user into a Pry prompt, where he can access the `$diff` object to query the data differences between the files.

    [rom-hacking/scripts]$ ruby difftool.rb 1_live.dump 2_lives.dump 3_lives.dump
    Loading $diff.files[0] => 1_live.dump
    Loading $diff.files[1] => 2_lives.dump
    Loading $diff.files[2] => 3_lives.dump
    [1] pry(main)> $diff.compare('>')
    => [37]
    [2] pry(main)> $diff.display(37)
    0: filename: 1_live.dump, [ 0x0025: 0x01 ]
    1: filename: 2_lives.dump, [ 0x0025: 0x02 ]
    2: filename: 3_lives.dump, [ 0x0025: 0x03 ]
    => nil

In this sample session, we load 3 different files (this is displayed in nice colors when running on an actual terminal). These files correspond to memory dumps from a game where the user had 1, 2 and 3 remaining lives, respectively. We assume the data area where the remaining number of lives resides will increase between those snapshots, although we do not know how exactly the values are being encoded. So we do a simple search for memory positions which increased value (represented by the `$diff.compare('>')` call), and the tool returns a list of memory positions which contain values that increased between the 3 dumps.

Next, we display the values stored offset returned in each dump using `$diff.display(37)`. We can see that the offset 37 (or 0x25, as displayed by the tool) contains the values 0x01, 0x02 and 0x03, which have indeed increased between the dumps. They also correspond nicely to the number of lives our character has on the game.

## Work in Progress
As can be easily seen, this project is very much a work in progress. Additional tools will certainly be developed, and will be added here as they reach "ready for general user consumption" status.