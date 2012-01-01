package test::List::Ish::filter;
use strict;
use warnings;
use Path::Class;
use lib file (__FILE__)->dir->parent->parent->subdir ('lib')->stringify;
use Test::More;
use base qw(Test::Class);
use List::Ish;

# ------ uniq_by ------

sub _uniq_by : Test(9) {
    my $list = List::Ish->new([1, 4, 3, 2, 0, 1, 2]);
    isa_ok $list->uniq_by(sub { $_[0] == $_[1] }), "List::Ish";
    is_deeply $list->uniq_by(sub { $_[0] == $_[1] })->to_a, [1, 4, 3, 2, 0];
    is_deeply $list->uniq_by(sub { $_[0] % 3 == $_[1] % 3 })->to_a, [1, 3, 2];
    is_deeply $list->to_a, [1, 4, 3, 2, 0, 1, 2];

    my @ret = $list->uniq_by(sub { $_[0] == $_[1] });
    is_deeply \@ret, [[1, 4, 3, 2, 0]];

    $list = List::Ish->new([0]);
    isa_ok $list->uniq_by(sub { $_[0] == $_[1] }), "List::Ish";
    is_deeply $list->uniq_by(sub { $_[0] == $_[1] })->to_a, [0];

    $list = List::Ish->new();
    isa_ok $list->uniq_by(sub { $_[0] == $_[1] }), "List::Ish";
    is_deeply $list->uniq_by(sub { $_[0] == $_[1] })->to_a, [];
}

sub _uniq_by_2 : Test(1) {
    my $list = List::Ish->new([qw(1 2 4 3)]);
    my $list2 = $list->uniq_by(sub { $_[0] == $_[1] or $_[0] == $_[1] * 2 });
    is_deeply $list2->to_a, [1, 4, 3];
}

sub _uniq_by_key_empty : Test(1) {
    my $l1 = List::Ish->new;
    is_deeply $l1->uniq_by_key(sub { rand })->to_a, [];
}

sub _uniq_by_key_1 : Test(1) {
    my $l1 = List::Ish->new([1, 2, 5, 1, 10, 2, 4]);
    is_deeply $l1->uniq_by_key(sub { $_ })->to_a, [1, 2, 5, 10, 4];
}

sub _uniq_by_key_2 : Test(1) {
    my $l1 = List::Ish->new([1, 2, 5, 1, 10, 2, 4]);
    is_deeply $l1->uniq_by_key(sub { $_ % 3 })->to_a, [1, 2];
}

sub _uniq_by_key_3 : Test(1) {
    my $l1 = List::Ish->new([1, 2, 5, 1, 10, 2, 4]);
    is_deeply $l1->uniq_by_key(sub { int($_ / 3) })->to_a, [1, 5, 10];
}

sub _uniq_by_key_4 : Test(1) {
  my $list = List::Ish->new([[1, 2], [4, 2], [2, 4], [3, 3], [0, 10]]);
  my $list2 = $list->uniq_by_key(sub { $_->[0] + $_->[1] });
  is_deeply $list2, [[1, 2], [4, 2], [0, 10]];
}

__PACKAGE__->runtests;

1;

=head1 LICENSE

Copyright 2010-2011 Hatena <http://www.hatena.com/>.

Copyright 2012 Wakaba <w@suika.fam.cx>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
