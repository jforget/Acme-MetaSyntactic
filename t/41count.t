use Test::More;
use Acme::MetaSyntactic;

plan tests => 1;

my $count = $Acme::MetaSyntactic::VERSION;
$count =~ s/^0\.//;
$count += 6; # 6 as from version 0.38
             # 7 as from version 0.25

is( scalar Acme::MetaSyntactic->themes, $count, "$count themes" );

