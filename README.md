# RFID Timekeeping tools

This is a set of ruby scripts enhancing the [SWITCH-Edv](http://www.zeit-messung.de/) timekeeping software.

### System requirements
1. Ruby >= 1.8
2. RFID system and reader software by SWITCH-Edv (closed source)
3. *gnuplot* with X11 output (only required for plotting scripts)

### Installation
0. Install Ruby, gnuplot and the RFID software
1. Clone (`git clone git@github.com:tillsc/rfid-timekeeping.git`) or [download](https://github.com/tillsc/rfid-timekeeping/zipball/master) this repository
2. Install dependencies

        bundle install

## Features

### Reader enhancements

The following scripts will start a fully working instance of the SWITCH-Edv *reader* software and analyze the output. 

#### Plotting signal strength
(gnuplot x11 required)

Run the reader through the *reader_plotter* script:

    bundle execute ruby bin/reader_plotter.rb <path_to_reader>/reader <reader_params>

Quit the reader with Strg+C

##### TODO
* The gnuplot process doesn't quit automatically. You'll have to stop the ruby process (Strg+Z), kill the gnuplot process and bring the ruby process back to the foreground (`fg`).

#### Measuring all tags in a fixed time window

This script will start the reader, wait for 5 seconds and analyze the output for 20 seconds. This script can be used to do laboratory tests with RFID chips.

    bundle execute ruby bin/reader_timed.rb <path_to_reader>/reader <reader_params>
