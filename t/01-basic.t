use v6;
use Test;

use lib "lib";
use Game::Amazing;

for dir("mazes").sort -> $file
{
  my $pass = ! so($file ~~ /\-fail\.maze$/);
  my $maze = Game::Amazing.new: $file;

  ok($maze, "Loaded maze $file");

  ok($maze.is-traversable.so == $pass, "Maze $file is { $pass ?? '' !! 'not' } traversable");
}

done-testing;
