# ROM Hacking

This repository was created to host various support scripts, tools and documentation associated with the **ROM Hacking for Fun, Profit & Infinite Lives** presentation.

## Scripts
Currently there are only two scripts, `difftool.rb` and `nesinfo.rb`. They are described below.

### Setup
Dependencies for all the scripts are handled by a `Gemfile`. You can install all the dependencies automatically using [Bundler](http://gembundler.com/).

    [rom-hacking/scripts]$ bundle install
    Using coderay (1.0.7) 
    Using method_source (0.8) 
    Using slop (3.3.3) 
    Using pry (0.9.10) 
    Using bundler (1.2.0) 
    Your bundle is complete! Use `bundle show [gemname]` to see where a bundled gem is installed.

### difftool.rb
This tool allows for comparison between multiple binary files with user-controllable comparison criteria. It was created to provide a more programmer-friendly (and emulator-independent) version of the [FCEUXD SP](http://www.the-interweb.com/serendipity/index.php?/categories/9-FCEUXD-SP) RAM Filter:

![RAM Filter](http://www.the-interweb.com/bdump/fceuxdsp/filter2.png)

The script offers an object which stores file information and contents for multiple memory dumps, and allows you to compare the values in those dumps using arbitrary comparison criteria. It drops you into a nice [Pry](http://pryrepl.org/) prompt where you peek and poke freely around the memory contents.

#### Usage
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

It is also possible to specify different criteria between the memory dumps. For example, if you wanted to discover memory positions which changed between the first two dumps, but remained unchanged between the second and the third one, you could use the following query:

    [rom-hacking/scripts]$ ruby difftool.rb 1_live.dump 2_lives.dump 3_lives.dump
    Loading $diff.files[0] => 1_live.dump
    Loading $diff.files[1] => 2_lives.dump
    Loading $diff.files[2] => 3_lives.dump
    [1] pry(main)> $diff.compare('!=', '==')
    => [93, 94, 144]
    [2] pry(main)> $diff.display(93, 94, 144)
    0: filename: 1_live.dump, [ 0x005d: 0x04, 0x005e: 0x04, 0x0090: 0x03 ]
    1: filename: 2_lives.dump, [ 0x005d: 0x02, 0x005e: 0x02, 0x0090: 0x01 ]
    2: filename: 3_lives.dump, [ 0x005d: 0x02, 0x005e: 0x02, 0x0090: 0x01 ]
    => nil

As seen above, the `$diff.display` method supports multiple offsets, which allows you to see how a set of values changed between the dumps at a glance.

### nesinfo.rb
This script displays information extracted from Nintendo Entertainment System ROM images contained in NES files. It is based on the [NES file format documentation](http://fms.komkon.org/EMUL8/NES.html#LABM) by Marat Fayzullin.

#### Usage
There are no arguments aside from the NES filename.
    ruby nesinfo.rb file.nes

The output consists of various metadata elements extracted from the NES file headers:

    [rom-hacking/scripts]$ ruby scripts/nesinfo.rb strider.nes 
    -----------------
            Filename: strider.nes
    # 16kB ROM Banks: 16 (256kB)
    # 8kB VROM Banks: 0 (0kB)
    #  8kB RAM Banks: 0 (0kB)
           Mirroring: Vertical
      Battery Backup: No
             Trainer: No
     4 Screen Layout: No
         Mapper Type: 1
        Color System: NTSC
    -----------------

## Work in Progress
As can be easily seen, this project is very much a work in progress. Additional tools will certainly be developed, and will be added here as they reach "ready for general user consumption" status.