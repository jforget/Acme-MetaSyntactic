use strict;
use Test::More;
use Acme::MetaSyntactic;

my @themes = grep { !/^(?:any)/ } Acme::MetaSyntactic->themes;
my @metas;

for my $theme (@themes) {
    no strict 'refs';
    eval "require Acme::MetaSyntactic::$theme;";
    diag "$theme $@" if $@;
    my %isa = map { $_ => 1 } @{"Acme::MetaSyntactic::$theme\::ISA"};
    if ( exists $isa{'Acme::MetaSyntactic::List'} ) {
        push @metas, "Acme::MetaSyntactic::$theme"->new();
    }
    elsif ( exists $isa{'Acme::MetaSyntactic::Locale'} ) {
        for my $lang ( "Acme::MetaSyntactic::$theme"->languages() ) {
            push @metas, "Acme::MetaSyntactic::$theme"->new( lang => $lang );
        }
    }
}

plan tests => scalar @metas;

for my $meta (@metas) {
    my %items;
    my $items = $meta->name(0);
    $items{$_}++ for $meta->name(0);
    
    is( scalar keys %items, $items, "No duplicates for @{[ref $meta]} ($items items)" );
    my $dupes = join " ", grep { $items{$_} > 1 } keys %items;
    diag "Duplicates: $dupes" if $dupes;
}
