# Smolder
A visual interpreter for the cellular automaton. The CA is described at https://esolangs.org/wiki/Smolder.

## Using the program
Download a .love file from Releases, then drag and drop onto LÖVE or double-click it to run.

* Use the left mouse button to replace any tile with your current one.
* Use the right mouse button to pan around the board.
* Scroll to zoom.
* Press the number keys 0-3 and backspace to change your current selection.
* Press space to toggle running the simulation.
* Press tab to advance one step.
* Press R to reset to the initial state before the simulation began running.
* Press I to completely reset the board.

## Modification
The `main.lua` file contains two variables: `bdata` and `size`. `bdata` is the preset data of the board, written as each cell's blue, green, and red channels. `size` automatically repeats the board across the plane.
