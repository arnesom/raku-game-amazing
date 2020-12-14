use v6;

unit class Game::Amazing:ver<0.9.1>:auth<cpan:ARNE>;

use File::Temp;

has @.maze is rw;
has $.rows is rw;
has $.cols is rw;
has Bool $!traversable;
has $!path;
has @!coverage;

our %desc2symbol = (
   SW   => '╗',
   EW   => '═',
   NW   => '╝',
   ES   => '╔',
   NS   => '║',
   EN   => '╚',
   ESW  => '╦',
   ENS  => '╠',
   NSW  => '╣',
   ENW  => '╩',
   ENSW => '╬'
);

our %symbol2desc = %desc2symbol.antipairs;
   
constant $end      = '█';
%symbol2desc{$end} = 'ENSW';
%symbol2desc{' '}  = '';

our %transform = (
   '╔' => ('90' => '╗', '180' => '╝', '270' => '╚', 'V' => '╗', 'H' => '╚'),
   '╠' => ('90' => '╦', '180' => '╣', '270' => '╩', 'V' => '╣', 'H' => '╠'),
   '╚' => ('90' => '╔', '180' => '╗', '270' => '╝', 'V' => '╝', 'H' => '╔'),
   '╦' => ('90' => '╣', '180' => '╩', '270' => '╠', 'V' => '╦', 'H' => '╩'),
   '╬' => ('90' => '╬', '180' => '╬', '270' => '╬', 'V' => '╬', 'H' => '╬'),
   '╩' => ('90' => '╠', '180' => '╦', '270' => '╣', 'V' => '╩', 'H' => '╦'),
   '╗' => ('90' => '╝', '180' => '╚', '270' => '╔', 'V' => '╔', 'H' => '╝'),
   '╣' => ('90' => '╩', '180' => '╠', '270' => '╦', 'V' => '╠', 'H' => '╣'),
   '╝' => ('90' => '╚', '180' => '╔', '270' => '╗', 'V' => '╚', 'H' => '╗'),
   '═' => ('90' => '║', '180' => '═', '270' => '║', 'V' => '═', 'H' => '═'),
   '║' => ('90' => '═', '180' => '║', '270' => '═', 'V' => '║', 'H' => '║'),
);

multi method new-embed($embed)
{
  my $m = self.bless;

  if $embed
  {
    $m.maze = $embed.lines>>.comb>>.Array;
    $m.rows = $m.maze.elems;
    $m.cols = $m.maze[0].elems;
  }
  else
  {
    $m.maze = ();
    $m.rows = 0;
    $m.cols = 0;
  }
  return $m;
}

multi method new ($file)
{
  die "Unable to read $file" unless $file.IO.f && $file.IO.r;
  my $m = self.bless;
  $m.maze = $file.IO.lines>>.comb>>.Array;
  $m.rows = $m.maze.elems;
  $m.cols = $m.maze[0].elems;
  
  return $m;
}

multi method new (:$rows = 25, :$cols = 25, :$scale = 7, :$ensure-traversable = False)
{
  my $m = self.defined ?? self !! self.bless;

  my %weight = (
   '╗'  => 1,
   '═'  => 1,
   '╝'  => 1,
   '╔'  => 1,
   '║'  => 1,
   '╚'  => 1,
   '╦'  => $scale,
   '╠'  => $scale,
   '╣'  => $scale,
   '╩'  => $scale,
   '╬'  => $scale
  );

  my @maze;
  my @symbols = %weight.keys.map({ $_ xx %weight{$_} }).flat;   

  repeat
  {
    @maze = ();
    @maze.push: @symbols.roll($cols).join for ^$rows;

    remove-direction(@maze[0].substr-rw($_,1),       "N") for ^$cols;
    remove-direction(@maze[$_].substr-rw(0,1),       "W") for ^$rows;
    remove-direction(@maze[$_].substr-rw($cols-1,1), "E") for ^$rows;
    remove-direction(@maze[$rows-1].substr-rw($_,1), "S") for ^$cols;

    @maze[0].substr-rw(0,1) = @maze[$rows-1].substr-rw($cols-1,1) = $end;

    $m.maze = @maze>>.comb>>.Array;
    $m.rows = $m.maze.elems;
    $m.cols = $m.maze[0].elems;
  }
  while $ensure-traversable && !$m.is-traversable(:force);
  
  sub remove-direction($symbol is rw, $direction) ## Replace with method below.
  {
    my $desc = %symbol2desc{$symbol} // return $symbol;
    $desc ~~ s/$direction//;
    $symbol = %desc2symbol{$desc} // ' ';
  }

  return $m;
}

method remove-direction($row, $col, $direction where $direction eq any('N', 'E', 'S', 'W'))
{
  my $symbol-desc = %symbol2desc{self.maze[$row][$col]} // return False;

  return False unless $symbol-desc ~~ /$direction/;

  $symbol-desc ~~ s/$direction//;
  self.maze[$row][$col] = %desc2symbol{$symbol-desc} // ' ';

  return True;
}

method add-direction($row, $col, $direction where $direction eq any('N', 'E', 'S', 'W'))
{
  my $symbol-desc = %symbol2desc{self.maze[$row][$col]} // return False;

  return False if $symbol-desc ~~ /$direction/;

  $symbol-desc = ($symbol-desc ~ $direction).comb.sort.join;

  self.maze[$row][$col] = %desc2symbol{$symbol-desc} // ' ';

  return True;
}

method toggle-direction($row, $col, $direction where $direction eq any('N', 'E', 'S', 'W'))
{
  my $symbol-desc = %symbol2desc{self.maze[$row][$col]} // return False;

  if $symbol-desc ~~ /$direction/
  {
    $symbol-desc ~~ s/$direction//;
    self.maze[$row][$col] = %desc2symbol{$symbol-desc} // ' ';
    return True;
  }

  return False if $symbol-desc eq "";

  $symbol-desc = ($symbol-desc ~ $direction).comb.sort.join;

  self.maze[$row][$col] = %desc2symbol{$symbol-desc} // ' ';

  return True;
}

method set-cell ($row, $col, $symbol)
{
  self.maze[$row][$col] = $symbol;
}

multi method save (IO::Handle $fh)
{
  $fh.spurt: self.as-string;
}

multi method save ($file where $file.ends-with('.maze'))
{
  spurt $file, self.as-string;
  return $file;
}

multi method save (:$with-size)
{
  my $suffix = $with-size
    ?? "-{ self.rows }x{ self.cols}.maze"
    !! ".maze";
  
  my ($fname, $fh) = tempfile( :!unlink, :suffix($suffix) );
  $fh.spurt: self.as-string;
  return $fname;
}

method as-string
{
  return self.maze>>.join.join("\n") ~ "\n";
}

method get-directions ($row, $col)
{
  my @directions;

  return '' unless %symbol2desc{self.maze[$row][$col]};

  for %symbol2desc{self.maze[$row][$col]}.comb -> $direction
  {
    @directions.push: 'N' if $direction eq 'N' && self.has-direction($row -1, $col, 'S');
    @directions.push: 'S' if $direction eq 'S' && self.has-direction($row +1, $col, 'N');
    @directions.push: 'W' if $direction eq 'W' && self.has-direction($row, $col -1, 'E');
    @directions.push: 'E' if $direction eq 'E' && self.has-direction($row, $col +1, 'W');
  }

  return @directions.join;
}

method has-direction ($row, $col, $direction)
{
  return False unless self.maze[$row][$col].defined;
  return %symbol2desc{self.maze[$row][$col]}.contains: $direction;
}

method is-traversable (:$force = False)
{
  if !$force
  {
    return $!traversable if defined $!traversable;
  }

  my @visited;
  my @todo = ("0;0;");
  my $path;

  while @todo
  {
    my $current = @todo.shift;
    my ($row, $col, $possible-path) = $current.split(';');
  
    @visited[$row][$col] = True;

    if $row == self.rows -1 && $col == self.cols -1
    {
      $!path = $possible-path;
      $!traversable = True;
      return True;
    }

    for self.get-directions($row, $col).comb -> $direction
    {
      @todo.push: "{ $row -1 };{ $col };{ $possible-path }N" if $direction eq "N" and ! @visited[$row-1][$col]++;
      @todo.push: "{ $row +1 };{ $col };{ $possible-path }S" if $direction eq "S" and ! @visited[$row+1][$col]++;
      @todo.push: "{ $row };{ $col -1 };{ $possible-path }W" if $direction eq "W" and ! @visited[$row][$col-1]++;
      @todo.push: "{ $row };{ $col +1 };{ $possible-path }E" if $direction eq "E" and ! @visited[$row][$col+1]++;
    }
  }

  $!path        = "";
  $!traversable = False;
  @!coverage    = @visited;
  return False;
}

method get-path
{
  return $!path if defined $!path;

  sink self.is-traversable;
  return $!path;
}

method get-coverage
{
  return @!coverage if defined @!coverage;

  sink self.is-traversable;
  return @!coverage;
}

method get-difficulty
{
  return 0 unless self.is-traversable;

  return (self.get-path.chars / ( self.rows + self.cols -2)).round(0.1);
}

method is-traversable-wall (:$get-path = False, :$left = False, :$verbose = False)
{
  my @visited;
  my $heading = "S";
  my $row = 0;
  my $col = 0;
  my %zero;

  loop
  {
    @visited[$row][$col] = True;
 
    my $directions = self.get-directions($row, $col);

    last unless $directions;

    my $turn        = $left
      ?? new-direction-left($heading, $directions)
      !! new-direction-right($heading, $directions);

    my $new_heading = new-heading($heading, $turn);
  
    say ": At [$row,$col]: { self.maze[$row][$col] } (with directions: $directions). Heading: $heading. Turning: $turn ($new_heading)" if $verbose;
  
    if $row == 0 && $col == 0
    {
      last if %zero{$new_heading};
      %zero{$new_heading} = True;
    }
  
    if $row == self.rows -1 && $col == self.cols -1
    {
      return $get-path ?? (True, @visited) !! True;
    }

    $heading = $new_heading;

    ($row, $col) = new-position($row, $col, $heading);
  }
  
  return $get-path ?? (False, @visited) !! False;
}


sub new-direction-right ($heading, $directions)
{
  if $heading eq "N"
  {
    return "R" if $directions ~~ /E/;
    return "A" if $directions ~~ /N/;
    return "L" if $directions ~~ /W/;
    return "B" if $directions ~~ /S/;
  }
  if $heading eq "W"
  {
    return "R" if $directions ~~ /N/;
    return "A" if $directions ~~ /W/;
    return "L" if $directions ~~ /S/;
    return "B" if $directions ~~ /E/;
  }
  if $heading eq "S"
  {
    return "R" if $directions ~~ /W/;
    return "A" if $directions ~~ /S/;
    return "L" if $directions ~~ /E/;
    return "B" if $directions ~~ /N/;
  }
  if $heading eq "E"
  {
    return "R" if $directions ~~ /S/;
    return "A" if $directions ~~ /E/;
    return "L" if $directions ~~ /N/;
    return "B" if $directions ~~ /W/;
  }
}

sub new-direction-left ($heading, $directions)
{
  if $heading eq "N"
  {
    return "L" if $directions ~~ /W/;
    return "A" if $directions ~~ /N/;
    return "R" if $directions ~~ /E/;
    return "B" if $directions ~~ /S/;
  }
  if $heading eq "W"
  {
    return "L" if $directions ~~ /S/;
    return "A" if $directions ~~ /W/;
    return "R" if $directions ~~ /N/;
    return "B" if $directions ~~ /E/;
  }
  if $heading eq "S"
  {
    return "L" if $directions ~~ /E/;
    return "A" if $directions ~~ /S/;
    return "R" if $directions ~~ /W/;
    return "B" if $directions ~~ /N/;
  }
  if $heading eq "E"
  {
    return "L" if $directions ~~ /N/;
    return "A" if $directions ~~ /E/;
    return "R" if $directions ~~ /S/;
    return "B" if $directions ~~ /W/;
  }
}

sub new-heading ($old_heading, $turn)
{
  return "N" if $old_heading eq "N" && $turn eq "A";
  return "N" if $old_heading eq "E" && $turn eq "L";
  return "N" if $old_heading eq "S" && $turn eq "B";
  return "N" if $old_heading eq "W" && $turn eq "R";

  return "E" if $old_heading eq "N" && $turn eq "R";
  return "E" if $old_heading eq "E" && $turn eq "A";
  return "E" if $old_heading eq "S" && $turn eq "L";
  return "E" if $old_heading eq "W" && $turn eq "B";

  return "S" if $old_heading eq "N" && $turn eq "B";
  return "S" if $old_heading eq "E" && $turn eq "R";
  return "S" if $old_heading eq "S" && $turn eq "A";
  return "S" if $old_heading eq "W" && $turn eq "L";
  
  return "W" if $old_heading eq "N" && $turn eq "L";
  return "W" if $old_heading eq "E" && $turn eq "B";
  return "W" if $old_heading eq "S" && $turn eq "R";
  return "W" if $old_heading eq "W" && $turn eq "A";
}

sub new-position ($row, $col, $heading)
{
  return ($row-1, $col  ) if $heading eq "N";
  return ($row,   $col+1) if $heading eq "E";
  return ($row+1, $col  ) if $heading eq "S";
  return ($row,   $col-1) if $heading eq "W";
}

method transform ($type, :$corners = False)
{
  die "Unsupported transformation $type" unless $type eq "90" | "180" | "270" | "R" | "D" | "L" | "V" | "H";

  my $new = Game::Amazing.new-embed('');

  my $rotated = False;

  if $type eq "H"
  {
    $new.maze.unshift: self.maze[$_] for ^self.rows;
  }
  
  elsif $type eq "V"
  {
    $new.maze.push: self.maze[$_].reverse.Array for ^self.rows;
  }

  elsif $type eq "90" | "R"
  {
    for ^self.rows -> $row
    {
      for ^self.cols -> $col
      {
        $new.maze[$col][self.rows - $row -1]
	  = %transform{$type}{self.maze[$row][$col]} // self.maze[$row][$col];
      }
    }
    $rotated = True;
  }
  
  elsif $type eq "180" | "D"
  {
    for ^self.rows -> $row
    {
      for ^self.cols -> $col
      {
        $new.maze[self.rows - $row -1][self.cols - $col -1]
	  = %transform{$type}{self.maze[$row][$col]} // self.maze[$row][$col];
      }
    }
    $rotated = True;
  }

  elsif $type eq "270" | "L"
  {
    for ^self.rows -> $row
    {
      for ^self.cols -> $col
      {
        $new.maze[self.cols - $col -1][$row]
	  = %transform{$type}{self.maze[$row][$col]} // self.maze[$row][$col];
      }
    }  
    $rotated = True;
  }

  $new.rows = $new.maze.elems;
  $new.cols = $new.maze[0].elems;

  unless $rotated
  {
    for ^$new.rows -> $row
    {
      for ^$new.cols -> $col
      {
        $new.maze[$row][$col] = %transform{$type}{$new.maze[$row][$col]} // $new.maze[$row][$col];
      }
    }
  }
  
  if $corners
  {
    $new.maze[0][0] = $end if $new.maze[0][0] ne $end;
    $new.maze[0][$new.cols -1] = '╗' if $new.maze[0][0] eq $end;
    $new.maze[$new.rows -1][0] = '╚' if $new.maze[$new.rows -1][0] eq $end;
    $new.maze[$new.rows -1][$new.cols -1] = $end if $new.maze[$new.rows -1][$new.cols -1] ne $end;
  }
  
  return $new;
}



=begin pod

=head1 NAME

Game::Amazing - Create, edit and check mazes for traversability

=head1 SYNOPSIS

This example will generate a random maze, with default values, and print it to STDOUT.

=begin code :lang<raku>

  use Game::Amazing;
  my $m = Game::Amazing.new;
  $m.save;

=end code

See the README.md file for details of the other methods available.

=head1 DESCRIPTION

Game::Amazing is a module for setting up and manipulating mazes. The sample
programs include two games, and a maze editor.

=head1 AUTHOR

Arne Sommer <arne@perl6.eu>

=head1 COPYRIGHT AND LICENSE

Copyright 2020 Arne Sommer

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
