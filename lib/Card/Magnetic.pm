package Card::Magnetic;

use strict;
use warnings;

# ABSTRACT: Magnetic Stripe parser


sub new {
    my ( $class ) = @_;

    my $self = { stripe => undef };

    return bless $self, $class;
}

sub stripe{
    my ( $self , $stripe ) = @_;

    return $self->{ stripe } if ! $stripe;

    $self->{ stripe } = $stripe;

}

sub parse{
    my ( $self ) = @_;

    my $stripe = $self->{ stripe };

    #track1
    if ( $stripe =~ /^%[\w|\^]+\?\n/ ){
        my $track1 = $&;
        $stripe = $` . $';
        $self->{ track1 }{ track } = $track1;
        chomp $track1;
        if( $track1 =~ /^%(\w)(\d+)\^(\w+)\^(\d{4})(\d{3})(\d{4})(\d{3})/ ) {
            $self->{ track1 } = {
                format_code     => $1,
                PAN             => $2,
                NAME            => $3,
                EXPIRATION_DATE => $4,
                SERVICE_CODE    => $5,
                PVV             => $6,
                CVV             => $7,
            };
        }
    }
    #track2
    if( $stripe =~ /\;[\w\^]+\?\n/ ){
        my $track2 =  $&;
        $stripe = $` . $';
        $self->{ track2 }{ track } = $track2;
        chomp $track2;
        if( $track2 =~ /(\d+)\^(\d{4})(\d{3})(\d{4})(\d{3})/ ) {
            $self->{ track2 } = {
                PAN             => $1,
                EXPIRATION_DATE => $2,
                SERVICE_CODE    => $3,
                PVV             => $4,
                CVV             => $5,
            };
        }
    }
    #track3
    if( $stripe =~ /\;[\w\^]+\?\n/ ){
        my $track3 = $&;
        $stripe = $` . $';
        $self->{ track3 }{ track } = $track3;
        chomp $track3;
        if( $track3 =~ /
            (\d+)\^
            (\d{3})
            (\d{3})
            (\d{4})
            (\d{4})
            (\d{4})
            (\d{2})
            (\d{1})
            (\d{6})
            (\d{1})
            (\d{2})
            (\d{2})
            (\d{2})
            (\d{4})
            (\d{1})
            (\d{9})
            (\d{1})
            (\d{6})
            /x){
            $self->{ track3 } = {
                PAN             => $1,
                COUNTRY_CODE    => $2,
                CURRENCY_CODE   => $3,
                AMOUNTAUTH      => $4,
                AMOUNTREMAINING => $5,
                CYCLE_BEGIN     => $6,
                CYCLE_LENGHT    => $7,
                RETRY_COUNT     => $8,
                PINCP           => $9,
                INTERCHANGE     => $10,
                PANSR           => $11,
                SAN1            => $12,
                SAN2            => $13,
                EXPIRATION_DATE => "1717",
                CARD_SEQUENCE   => "1",
                CARD_SECURITY   => "234567890",
                RELAY_MARKER    => "3",
                CRYPTO_CHECK    => "456789",
           };
        }
    }
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Card::Magnetic - Magnetic Stripe parser

=head1 VERSION

version 0.001

=head1 SYNOPSIS

This module is a parser to the contents of the magnetic stripe from cards that follow the ISO 7810 norm.

Now it parse the strip and create the basic structure on the object

    use Card::Magnetic;

    my $card = Card::Magnetic->new();
    $card->stripe( "stripe content" );
    $card->parse();

=head1 NAME

Card::Magnetic - Magnetic stripe parser and builder

=head1 SUBROUTINES/METHODS

=head2 new

Instanciate a new card

=head2 stripe

Stripe accessor

=head2 parse

Parse the stripe and create a internal hash hashref structure with the exploded layout of the card.

=head1 AUTHOR

Frederico Recsky <recsky@cpan.org>

This program is free software; you can redistribute it
and/or modify it under the same terms as Perl itself.

=head1 AUTHOR

Frederico Recsky <cartas@frederico.me>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Frederico Recsky.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
