NAME
====

Game::Amazing - Create, edit and check mazes for traversability

SYNOPSIS
========

```
use Game::Amazing;
```

DESCRIPTION
===========

Game::Amazing can generate mazes, and check them for traversability (with the 
Shortest Path and the Wall Follower Algorithms).

The module comes with some sample programs, including two games and a maze editor,
described in the EXAMPLES section.

See https://raku-musings.com/amazing.html for more information.

METHODS
=======

new
---

Generate a new maze. There are two versions:

```
my $m = Game::Amazing::new($file);
```

This call loads an existing maze from a file. The filename must end with 
«.maze».

```
my $m = Game::Amazing::new(rows => 25, cols => 25, scale => 7, ensure-traversable => False);
```

This one generates a randon maze, with the given size.


It is also possible to generate a new maze with an existing object with this one:

```
$m.new(rows => 25, cols => 25, scale => 7, ensure-traversable => False);
```

This is done by the «amazing-termbox» program when a new game is initiated, as letting 
the original maze object go out of scope terminates the program (without explanation).

new-embed
---------

This method takes a string and uses that to build the maze. Illegal characters are ok,
as it is (mostly) meant for testing of maze transformations. An empty string will give
an empty maze.

```
my $m = Game::Amazing::new-embed("ABC\nDEF\nGHI\n");
```
save
----

Save the maze. There are three (or four) versions of this method.

Tou can pass it a filehandle (to a file open for writing):

```
my IO::Handle $fh = open :w, 'my-maze.maze';
$m.save ($fh);
$fh.close;
```

Or you can specify a filename:

```
$m.save ('my-maze.maze');
```
The filename must end with «.maze».


This version has no positional argument, and will save the maze with a 
randomly generated filename. The filename is returned.

```
my $filname = $m.save;
say $filename;  # -> /tmp/8spgH2MQBT.maze
```

You can add the «with-size» option to get the size of the maze added to the filename

```
my $filname = $m.save(with-size);
say $filename;  # -> /tmp/AZPNWawtTz-25x25.maze
```

as-string
---------

Return the maze as a single string with embedded newlines. It is used internally by the
save method, but can be used by user code as well.


```
my $string = $m.as-string;
```

set-cell
--------

Change the symbol for the cell with the specified row and column. This works directly
on the maze, changing the affect of future calls to the methods `get-directions`,
`has-direction`, `is-traversable` and `is-traversable-wall`.

```
$m.set-cell($row, $col, $symbol);
```

This method is used by «amazing-gtk» to change cell values in edit mode.

Note that there is not check on the legality of the new symbol, nor the length of the
value. This is on purpose, making it possible to add markup to the maze itself before
printing it. This is done by «maze-solver-spa». This is subject to change.


get-cell
--------

Get the symbol at the given postition.

```
my $symbol = $m.get-cell($row, $col);
```

get-size
--------

Get the size (number of rows and columns) of the maze.

```
my ($rows, $cols) = $m.get-size;
```

fix-corners
-----------

This method will ensure that the maze has exactly one entrance and one exit. The randomly 
generated mazes have two exit symbols, and «amazing-gtk» will change the top left one to
an entrance symbol. («amazing-termbox» checks for the coordinates and not the cell value, 
and does not use this functionality.)

Saving a maze in «amazing-gtk»

```
$m.fix-corners;
```

Note that the method does not check for entrance end exits symbols in other positions in 
the maze (than the four corners), but should herhaps do so.

It is possible to swap the entreance and exit. by using the _upside-down_ argument.


```
$m.fix-corners(upside-down => True);
```

**More explanation**

get-directions
--------------

This method return a string of directions from the specified cell. The letters are «N»
(north), «E» (east), «S» (south) and «W» (west).

Note that this method consider the neighbouring cells, so an exit in the current cell towards a
neighbouring cell that does not have a corresponding entrance (exit) will be ignored.

```
my $directions = $m.get-directions ($row, $col);
```

has-direction
-------------

Check if the specified cell has an exit in the given direction, where the direction is one
of «N» (north), «E» (east), «S» (south) and «W» (west). 

Note that this method looks at the current cell only, without considering the neighbouring 
cellsm, so it is mainly for internal use. Use `get-directions` to get directions that 
actually exist.

```
my $boolean = $.has-direction($row, $col, $direction);
```

remove-direction
----------------

Remove the specified direction (on the form «N», «E», «S» or «W») from the specified cell. 
It returns False if it was unable to change the character, and True on success.

If the cell had two exits, the result of removing one of them is an empty cell (a space
symbol).

```
my $boolean = $.remove-direction($row, $col, $direction);
```
This method does not work on the entrance or exit.

add-direction
----------------

Add the specified direction (on the form «N», «E», «S» or «W») to the specified cell. It 
returns False if it was unable to change the character, and True on success.

Nothing is done if the cell is empty (a space symbol).

```
my $boolean = $.remove-direction($row, $col, $direction);
```

This method does not work on the entrance or exit.


toggle-direction
----------------

Remove the specified direction (on the form «N», «E», «S» or «W») to the specified cell, if it
is there, and add it otherwise.

Removing a direction from a cell with two exits removes both, and adding a direction to an
empty cell will fail.

The method returns True if it was able to change the cell.

```
my $boolean = $.toggle-direction($row, $col, $direction);
```

is-traversable
--------------

Check if the maze is traversable, using the Shortest Path Algorithm.

```
my $boolean = $m.is-traversable;
```

The module will not calculate the value _before_ you call the method. Then the
value (as well as the path or coverage map) is cached.

Use the «:force» argument to force the program to check the path again:

```
my $boolean = $m.is-traversable(:force);
```

This is used by the maze editor, whenever the user changes a symbol.

*Note that this method assumes that the entrance and exit are located in the upper left
and lower right corners (or vice versa).*


get-path
--------

This gives the path, if the maze is traversable, and an empty string if not. The path is 
a string of directional letters. Start at the entrance and apply them one by one to get 
the actual path. The length of the string gives the number of steps.

get-coverage
------------

This gives the coverage, i.e. a list of cells that are reachable from the entrance. 
This is given as a two-dimentional array, e.g.

```
my @coverage = $m.get-coverage;
my $row = 10; 
my $col = 8;
say "Been there" if @coverage[$row][$col];
```
*Note that this method assumes that the entrance is located in the upper left corner.*

is-traversable-wall
-------------------

Check if the maze is traversable, using the Wall Follower Algorithm.

Note that this method does not cache the values (as opposed to «is-traversable»).

```
my $boolean = $m.is-traversable-wall (:$get-path, :$left, :$verbose)
```

You can get the path with the «:get-path» option. The path will usually be rather convoluted, 
so the result here is a coverage array regardless of traversability.


```
my ($boolean, $path) = $m.is-traversable-wall(:get-path);
my @visited = @($path);

```

The method follows the right wall by default. Specify «:left» to override this:

```
my $boolean = $m.is-traversable-wall (:left)
```

Note that the Wall Follower Algorith will return you to the entrance if the maze is 
untraversable. The Left and Right variants will thus give the same result on an
untraversable maze (but from opposite directions).


It is possible to get some verbose output from the method, with the «:verbose» option.

```
my $boolean = $m.is-traversable-wall(:verbose);
```

This is normally not very useful to end users.

An example, where the `<red>` tag should not be taken literally:

```
my ($boolean, $path) = $m.is-traversable-wall(:get-path);
my @visited = @($path);
for ^$m.rows -> $row
{
  for ^$m.cols -> $col
  {
    print @visited[$row][$col]
	  ?? '<red>' ~ $m.maze[$row][$col] ~ '</red>'
	  ?? $m.maze[$row][$col];
  }
  say '';
}
```

*Note that this method assumes that the entrance and exit are located in the upper left
and lower right corners (or vice versa).*

transform
---------

Transform the maze in the specified way. This will generate a new maze, which is the 
return value, and will not affect the current maze. 

The method takes one argument, which is one of: 
* __R__ or  __90__ - rotate  90 degrees to the right
* __D__ or __180__ - rotate 180 degrees (down)
* __L__ or __270__ - rotate  90 degrees to the left
* __H__ - flip horizonatally
* __V__ - flip vertically


```
my $new = $m.transform("R");
```

Note that the entrance and exit symbols (which are identical) will not be fixed when 
moved to the _wrong_ corners, but this can be fixed by using the «corners» option:

```
my $new = $m.transform("R", :corners);
```

The corners that are un-entrancified and un-exitified get a symbol with two exits.
This will actually roundtrip, as long as the original maze does not have any spurious
exits (exits leading out of the maze). Scroll down to «An Even More Amazing Program»
in https://raku-musings.com/amazing1.html for more information.

EXAMPLES
========

The _bin_ directory has some programs that will be installed on installation. *zef* 
will tell you where they are installed, so that you can choose to add the directory 
to the path.

Below is a short description. You can run any of them with the «-h» command line
option to get more information.

The programs:

mazemaker
---------

Generate a random maze.

maze-solver-spa
---------------

Check if a given maze is traversable, using the «Shortest Path Algorithm».

maze-solver-wall
----------------

Check if a given maze is traversable, using the «Wall Follower Algorithm».

maze-solver-summary
-------------------

Check if one or more mazes are traversable, and report how difficult they are.

amazing-termbox
---------------

A game. Traverse the maze in your terminal window. It sses the «Termbox» module.

amazing-gtk
-----------

Another game. Traverse the maze in a graphical window. It uses the «Gnome::GTK» 
module.

This program can also edit mazes.

maze-transform
--------------

Transform a maze file. It supports rotation (90, 180 and 270 degrees) and flipping
(horizontal and vertical). By default it doesn't move the entrance and exit, but 
this can be done with a command line option.

AUTHOR
======

Arne Sommer <arne@perl6.eu>

COPYRIGHT AND LICENSE
=====================

Copyright 2020 Arne Sommer

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

