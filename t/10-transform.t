use v6;
use Test;

use lib "lib";
use Game::Amazing;

my $maze = "ABC\nDEF\nGHI";

my $m1 = Game::Amazing.new-embed($maze);

my $m11 = $m1.transform('V');
is($m11.as-string, "GHI\nDEF\nABC\n", "3x3 Flip Vertical");
my $m12 = $m11.transform('V');
is($m12.as-string, $m1.as-string, "3x3 Flip Vertical x 2");

my $m21 = $m1.transform('H');
is($m21.as-string, "CBA\nFED\nIHG\n", "3x3 Flip Horizontal");
my $m22 = $m21.transform('H');
is($m22.as-string, $m1.as-string, "3x3 Flip Horizontal x 2");

my $m31 = $m1.transform('90');
is($m31.as-string, "GDA\nHEB\nIFC\n", "3x3 Rotate 90");
my $m32 = $m31.transform('270');
is($m32.as-string, $m1.as-string, "3x3 Rotate 90 + 270");

my $m41 = $m1.transform('180');
is($m41.as-string, "IHG\nFED\nCBA\n", "3x3 Rotate 180");
my $m42 = $m41.transform('180');
is($m42.as-string, $m1.as-string, "3x3 Rotate 180 + 380");

my $m51 = $m1.transform('270');
is($m51.as-string, "CFI\nBEH\nADG\n", "3x3 Rotate 270");
my $m52 = $m51.transform('90');
is($m52.as-string, $m1.as-string, "3x3 Rotate 270 + 270");

$maze = "ABCD\nEFGH";

$m1 = Game::Amazing.new-embed($maze);

$m11 = $m1.transform('V');
is($m11.as-string, "EFGH\nABCD\n", "4x2 Flip Vertical");
$m12 = $m11.transform('V');
is($m12.as-string, $m1.as-string, "4x2 Flip Vertical x 2");

$m21 = $m1.transform('H');
is($m21.as-string, "DCBA\nHGFE\n", "4x2 Flip Horizontal");
$m22 = $m21.transform('H');
is($m22.as-string, $m1.as-string, "4x2 Flip Horizontal x 2");

$m31 = $m1.transform('90');
is($m31.as-string, "EA\nFB\nGC\nHD\n", "4x2 Rotate 90");
$m32 = $m31.transform('270');
is($m32.as-string, $m1.as-string, "4x2 Rotate 90 + 270");

$m41 = $m1.transform('180');
is($m41.as-string, "HGFE\nDCBA\n", "4x2 Rotate 180");
$m42 = $m41.transform('180');
is($m42.as-string, $m1.as-string, "4x2 Rotate 180 + 380");

$m51 = $m1.transform('270');
is($m51.as-string, "DH\nCG\nBF\nAE\n", "4x2 Rotate 270");
$m52 = $m51.transform('90');
is($m52.as-string, $m1.as-string, "4x2 Rotate 270 + 270");



my $maze1 = "╔═══╗\n╠═══╣\n╚═══╝\n";
my $maze2 = "╔╦╗\n║║║\n║║║\n║║║\n╚╩╝\n";

my $m8a = $m1.new-embed($maze1).transform('V');
is($m8a.as-string, $maze1, "5x3 Flip V");

my $m8b = $m1.new-embed($maze1).transform('H');
is($m8b.as-string, $maze1, "5x3 Flip H");

my $m8c = $m1.new-embed($maze1).transform('90');
is($m8c.as-string, $maze2, "5x3 Rotate 90");

my $m8d = $m1.new-embed($maze1).transform('180');
is($m8d.as-string, $maze1, "5x3 Rotate 180");

my $m8e = $m1.new-embed($maze1).transform('270');
is($m8e.as-string, $maze2, "5x3 Rotate 270");


test-rotate("╔═╗\n║ ║\n╚═╝\n", "box3");
test-rotate("╔╦╗\n╠╬╣\n╚╩╝\n", "3x3");
test-rotate("░╦╗\n╠╬╣\n╚╩█\n", "3x3-exit", True);

sub test-rotate ($maze, $label, $corners = False)
{
  subtest "Rotate $label",
  {
    plan 5;
    
    my $m91 = $m1.new-embed($maze).transform('V', corners => $corners);
    is($m91.as-string, $maze, "$label Flip V");

    my $m92 = $m1.new-embed($maze).transform('H', corners => $corners);
    is($m92.as-string, $maze, "$label Flip H");

    my $m93 = $m1.new-embed($maze).transform('90', corners => $corners);
    is($m93.as-string, $maze, "$label Rotate 90");

    my $m94 = $m1.new-embed($maze).transform('180', corners => $corners);
    is($m94.as-string, $maze, "$label Rotate 180");

    my $m95 = $m1.new-embed($maze).transform('270', corners => $corners);
    is($m95.as-string, $maze, "$label Rotate 270");
  }
}

done-testing;
