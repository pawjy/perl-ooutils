package test::List::Ish::clone;
use strict;
use warnings;
use Path::Class;
use lib file (__FILE__)->dir->parent->parent->subdir ('lib')->stringify;
use Test::More;
use base qw(Test::Class);
use List::Ish;

# ------ slice ------

sub _slice_all : Test(6) {
  my $l1 = List::Ish->new ([1, 2, 3]);
  my $l2 = $l1->slice (0, 2);
  isa_ok $l2, 'List::Ish';
  isnt $l2, $l1;
  is $l2->[0], 1;
  is $l2->[1], 2;
  is $l2->[2], 3;
  is $l2->length, 3;
} # _slice_all

sub _slice_too_many : Test(6) {
  my $l1 = List::Ish->new ([1, 2, 3]);
  my $l2 = $l1->slice (0, 5);
  isa_ok $l2, 'List::Ish';
  isnt $l2, $l1;
  is $l2->[0], 1;
  is $l2->[1], 2;
  is $l2->[2], 3;
  is $l2->length, 3;
} # _slice_too_many

sub _slice_no_args : Test(6) {
  my $l1 = List::Ish->new ([1, 2, 3]);
  my $l2 = $l1->slice;
  isa_ok $l2, 'List::Ish';
  isnt $l2, $l1;
  is $l2->[0], 1;
  is $l2->[1], 2;
  is $l2->[2], 3;
  is $l2->length, 3;
} # _slice_no_args

__PACKAGE__->runtests;

1;

=head1 LICENSE

Copyright 2012 Wakaba <w@suika.fam.cx>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
