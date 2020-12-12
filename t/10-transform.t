use v6;
use Test;

use lib "lib";
use Game::Amazing;

my $maze = "ABC\nDEF\nGHI";

my $m1 = Game::Amazing.new(embed => $maze);

my $m11 = $m1.transform('V');
is($m11.as-string, "CBA\nFED\nIHG\n", "3x3 Flip Vertical");
my $m12 = $m11.transform('V');
is($m12.as-string, $m1.as-string, "3x3 Flip Vertical x 2");

my $m21 = $m1.transform('H');
is($m21.as-string, "GHI\nDEF\nABC\n", "3x3 Flip Horizontal");
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

$m1 = Game::Amazing.new(embed => $maze);

$m11 = $m1.transform('V');
is($m11.as-string, "DCBA\nHGFE\n", "4x2 Flip Vertical");
$m12 = $m11.transform('V');
is($m12.as-string, $m1.as-string, "4x2 Flip Vertical x 2");

$m21 = $m1.transform('H');
is($m21.as-string, "EFGH\nABCD\n", "4x2 Flip Horizontal");
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









done-testing;
