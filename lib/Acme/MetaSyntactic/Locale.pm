package Acme::MetaSyntactic::Locale;
use strict;
use Acme::MetaSyntactic (); # do not export metaname and friends
use List::Util qw( shuffle );
use Carp;

sub init {
    my $class = caller(0);
    my $data  = Acme::MetaSyntactic->load_data( $class );
    no strict 'refs';
    no warnings;
    for my $lang ( keys %{ $data->{names} } ) {
        @{${"$class\::Locale"}{$lang}} = split /\s+/, $data->{names}{$lang};
    }
    croak "$class defines no default language" unless $data->{default};
    ${"$class\::Default"} = $data->{default};

    # export the function
    my $callpkg = caller(1); # init is called from the subclass
    my $theme   = (split/::/, $class)[-1];
    my $meta    = $class->new;
    *{"$callpkg\::meta$theme"} = sub { $meta->name( @_ ) };
}

sub import {
}

sub name {
    my ( $self, $count ) = @_;
    my $class = ref $self;

    if ( defined $count && $count == 0 ) {
        no strict 'refs';
        return wantarray
          ? shuffle @{ ${"$class\::Locale"}{ $self->{lang} } }
          : scalar @{ ${"$class\::Locale"}{ $self->{lang} } };
    }

    $count ||= 1;
    my $list = $self->{cache};
    {
        no strict 'refs';
        push @$list, shuffle @{ ${"$class\::Locale"}{ $self->{lang} } }
          while @$list < $count;
    }
    splice( @$list, 0, $count );
}


sub new {
    my $class = shift;

    no strict 'refs';
    my $self = bless { @_, cache => [] }, $class;

    # compute some defaults
    if( ! exists $self->{lang} ) {
        if( $^O eq 'MSWin32' ) {
            eval { require Win32::Locale; };
            $self->{lang} = Win32::Locale::get_language() unless $@;
        }
        else {
            $self->{lang} = $ENV{LANGUAGE} || $ENV{LANG};
        }
    }
    $self->{lang} = ${"$class\::Default"} unless $self->{lang};
    $self->{lang} = substr( $self->{lang}, 0, 2 );

    # fall back to last resort
    $self->{lang} = ${"$class\::Default"}
      if !exists ${"$class\::Locale"}{ $self->{lang} };

    return $self;
}

sub lang { $_[0]->{lang} }

sub languages {
    my $class = shift;
    $class = ref $class if ref $class;

    no strict 'refs';
    return keys %{"$class\::Locale"};
}

1;

__END__

=head1 NAME

Acme::MetaSyntactic::Locale - Base class for multilingual themes

=head1 SYNOPSIS

    package Acme::MetaSyntactic::digits;
    use Acme::MetaSyntactic::Locale;
    our @ISA = ( Acme::MetaSyntactic::Locale );
    __PACKAGE__->init();
    1;

    =head1 NAME
    
    Acme::MetaSyntactic::digits - The numbers theme
    
    =head1 DESCRIPTION
    
    You can count on this module. Almost.

    =cut
    
    __DATA__
    # default
    en
    # names en
    zero one two three four five six seven eight nine
    # names fr
    zero un deux trois quatre cinq six sept huit neuf
    # names it
    zero uno due tre quattro cinque sei sette otto nove
    # names yi
    nul eyn tsvey dray fir finf zeks zibn akht nayn

=head1 DESCRIPTION

C<Acme::MetaSyntactic::Locale> is the base class for all themes that are
meant to return a random excerpt from a predefined list.

=head1 METHODS

Acme::MetaSyntactic::Locale offers several methods, so that the subclasses
are easy to write (see full example in L<SYNOPSIS>):

=over 4

=item new( lang => $lang )

The constructor of a single instance. An instance will not repeat items
until the list is exhausted.

If no C<lang> parameter is given, Acme::MetaSyntactic::Locale will try
to find the user locale (with the help of environment variables
C<LANGUAGE>, C<LANG> and Win32::Locale).

$lang is a two-letter language code (ISO 3166, RFC 3066). If the list
is not available in the requested language, the default is used.

=item init()

init() must be called when the subclass is loaded, so as to read the
__DATA__ section and fully initialise it.

=item name( $count )

Return $count names (default: C<1>).

Using C<0> will return the whole list in list context, and the size of the
list in scalar context (according to the C<lang> parameter passed to the
constructor).

=item lang()

Return the selected language for this instance.

=item languages()

Return the languages supported by the theme.

=back

=head1 AUTHOR

Philippe 'BooK' Bruhat, C<< <book@cpan.org> >>

=head1 COPYRIGHT & LICENSE

Copyright 2005 Philippe 'BooK' Bruhat, All Rights Reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

