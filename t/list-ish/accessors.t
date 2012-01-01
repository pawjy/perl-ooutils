package test::List::Ish::accessors;
use strict;
use warnings;
use Path::Class;
use lib file (__FILE__)->dir->parent->parent->subdir ('lib')->stringify;
use Test::More;
use base qw(Test::Class);
use List::Ish;

sub _first_zero : Test(2) {
  my $l = List::Ish->new ([]);
  is $l->first, undef;
  is $l->last, undef;
} # _first_zero

sub _first_one : Test(2) {
  my $l = List::Ish->new ([4]);
  is $l->first, 4;
  is $l->last, 4;
} # _first_one

sub _first : Test(2) {
  my $l = List::Ish->new ([1, 2, 3]);
  is $l->first, 1;
  is $l->last, 3;
} # _first

__PACKAGE__->runtests;

1;

=head1 LICENSE

Copyright 2012 Wakaba <w@suika.fam.cx>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
