package test::List::Ish;
use strict;
use warnings;
use Path::Class;
use lib file (__FILE__)->dir->parent->parent->subdir ('lib')->stringify;
use Test::More;
use base qw(Test::Class);
use List::Ish;

sub _new_no_args : Test(2) {
  my $l = List::Ish->new;
  
  isa_ok $l, 'List::Ish';
  is scalar @$l, 0;
} # _new_no_args

sub _new_empty_arrayref : Test(4) {
  my $arrayref = [];
  my $l = List::Ish->new ($arrayref);
  
  isa_ok $l, 'List::Ish';
  is scalar @$l, 0;

  is $l, $arrayref;
  is ref $arrayref, 'List::Ish';
} # _new_empty_arrayref

sub _new_arrayref : Test(7) {
  my $arrayref = [1, "abc", {}];
  my $l = List::Ish->new ($arrayref);
  
  isa_ok $l, 'List::Ish';
  is scalar @$l, 3;
  is $l->[0], 1;
  is $l->[1], 'abc';
  is_deeply $l->[2], {};

  is $l, $arrayref;
  is ref $arrayref, 'List::Ish';
} # _new_arrayref

__PACKAGE__->runtests;

1;

=head1 LICENSE

Copyright 2012 Wakaba <w@suika.fam.cx>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
