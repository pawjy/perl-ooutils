package List::Ish;
use strict;
use warnings;
our $VERSION = '0.04';

$Test::MoreMore::ListClass{+__PACKAGE__} = 1;

sub new {
    my $class = shift;
    $class = ref $class if ref $class;
    return $_[0] if UNIVERSAL::isa($_[0], $class);
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
    my ($self, $start, $end) = @_;
    my $last = $#{$self};
    if (defined $end) {
        if ($start == 0 && $last <= $end) {
            return $self->dup;
        } else {
            $end = $last if $last < $end;
            return $self->new([ @$self[ $start .. $end ] ]);
        }
    } elsif (defined $start && 0 < $start && $last <= $start) {
        return $self->new([]);
    } else {
        return $self->dup;
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
    $code->($_) for @{$self->dup};
    $self;
}

sub map {
    my ($self, $code) = @_;
    my @collected = CORE::map &$code, @{$self->dup};
    return $self->new(\@collected);
}

sub grep {
    my ($self, $code) = @_;
    my @grepped = CORE::grep &$code, @$self;
    return $self->new(\@grepped);
}

sub uniq_by {
    my ($self, $is_equal) = @_;
    my @result;
    $self->each(
        sub {
            foreach (@result) {
                return if $is_equal->($_[0], $_);
            }
            CORE::push @result, $_[0];
        }
    );
    return $self->new(\@result);
}

sub uniq_by_key {
    my ($self, $to_key) = @_;
    my %has;
    return scalar $self->grep(sub { not($has{$to_key->()}++) });
}

sub find {
    my ($self, $code) = @_;
    for (@$self) { &$code and return $_ }
    return;
}

sub has {
    my ($self, $code) = @_;
    for (@$self) { &$code and return 1 }
    return 0;
}

sub sort {
    my ($self, $code) = @_;
    my @sorted = $code ? CORE::sort { $code->($a, $b) } @$self : CORE::sort @$self;
    return $self->new(\@sorted);
}

sub length {
    scalar @{$_[0]};
}

*size = \&length;

sub to_a {
    my @unblessed = @{$_[0]};
    \@unblessed;
}

sub to_list {
    return @{$_[0]};
}

sub TO_JSON {
    return [@{$_[0]}];
}

sub clone {
    return bless [@{$_[0]}], ref $_[0];
}

*dup = \&clone;

sub as_hashref {
    return {map { $_ => 1 } @{$_[0]}};
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
