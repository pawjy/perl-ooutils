package List::Ish;
use strict;
use warnings;
our $VERSION = '0.04';
use Carp qw/croak/;
use List::MoreUtils ();

sub new {
    my $class = shift;
    $class = ref $class if ref $class;
    return $_[0] if UNIVERSAL::isa($_[0], __PACKAGE__);
    return bless $_[0] || [], $class;
}

sub push {
    my $self = shift;
    push @$self, @_;
    $self;
}

sub unshift {
    my $self = shift;
    unshift @$self, @_;
    $self;
}

sub shift {
    shift @{$_[0]};
}

sub pop {
    pop @{$_[0]};
}

sub first {
    return $_[0]->[0];
}

sub last {
    return $_[0]->[-1];
}

sub slice {
    my $self = CORE::shift;
    my ($start, $end) = @_;
    my $last = $#{$self};
    if (defined $end) {
        if ($start == 0 && $last <= $end) {
            return $self;
        } else {
            $end = $last if $last < $end;
            return $self->new([ @$self[ $start .. $end ] ]);
        }
    } elsif (defined $start && 0 < $start && $last <= $start) {
        return $self->new([]);
    } else {
        return $self;
    }
}

sub join {
    my ($self, $delimiter) = @_;
    join $delimiter, @$self;
}

sub append {
    my ($self, $array) = @_;
    $self->push(@$array);
    $self;
}

sub prepend {
    my ($self, $array) = @_;
    $self->unshift(@$array);
    $self;
}

sub each {
    my ($self, $code) = @_;
    croak "Argument must be a code" unless ref $code eq 'CODE';
    $code->($_) for @{$self->dup};
    $self;
}

sub map {
    my ($self, $code) = @_;
    croak "Argument must be a code" unless ref $code eq 'CODE';
    my @collected = CORE::map &$code, @{$self->dup};
    wantarray ? @collected : $self->new(\@collected);
}

sub grep {
    my ($self, $code) = @_;
    croak "Argument must be a code" unless ref $code eq 'CODE';
    my @grepped = CORE::grep &$code, @$self;
    wantarray ? @grepped : $self->new(\@grepped);
}

sub find {
    my ($self, $code) = @_;
    croak "Argument must be a code" unless ref $code eq 'CODE';
    for (@$self) { &$code and return $_ }
    return;
}

sub sort {
    my ($self, $code) = @_;
    my @sorted = $code ? CORE::sort { $code->($a, $b) } @$self : CORE::sort @$self;
    wantarray ? @sorted : $self->new(\@sorted);
}

sub sort_by {
    my ($self, $code, $cmp) = @_;

    my @sorted = $cmp ?
        CORE::map { $_->[1] } CORE::sort { $cmp->($a->[0], $b->[0]) } CORE::map { [$code->($_), $_] } @$self :
        CORE::map { $_->[1] } CORE::sort { $a->[0] <=> $b->[0] } CORE::map { [$code->($_), $_] } @$self;

    wantarray ? @sorted : $self->new(\@sorted);
}

sub length {
    scalar @{$_[0]};
}

*size = \&length;

sub uniq {
    my $self = CORE::shift;
    $self->new([ List::MoreUtils::uniq(@$self) ]);
}

sub to_a {
    my @unblessed = @{$_[0]};
    \@unblessed;
}

sub dup {
    __PACKAGE__->new($_[0]->to_a);
}

sub reverse {
    my $self = CORE::shift;
    $self->new([ reverse @$self ]);
}

1;

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
