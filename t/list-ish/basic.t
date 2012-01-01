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

sub _new_blessed : Test(4) {
  my $l1 = List::Ish->new ([1, 2]);
  
  my $l2 = List::Ish->new ($l1);
  isa_ok $l2, 'List::Ish';
  is $l2, $l1;
  is $l2->[0], 1;
  is $l2->[1], 2;
} # _new_blessed

sub _new_rubyish : Test(4) {
  my $l1 = bless [1, 2], 'List::Rubyish';
  
  my $l2 = List::Ish->new ($l1);
  isa_ok $l2, 'List::Ish';
  is $l2, $l1;
  is $l2->[0], 1;
  is $l2->[1], 2;
} # _new_rubyish

sub _new_moco_list : Test(4) {
  my $l1 = bless [1, 2], 'DBIx::MoCo::List';
  
  my $l2 = List::Ish->new ($l1);
  isa_ok $l2, 'List::Ish';
  is $l2, $l1;
  is $l2->[0], 1;
  is $l2->[1], 2;
} # _new_moco_list

sub _new_moco_list_child : Test(4) {
  local @My::DBIx::MoCo::List::ISA = qw(DBIx::MoCo::List);
  my $l1 = bless [1, 2], 'My::DBIx::MoCo::List';
  
  my $l2 = List::Ish->new ($l1);
  isa_ok $l2, 'List::Ish';
  is $l2, $l1;
  is $l2->[0], 1;
  is $l2->[1], 2;
} # _new_moco_list_child

sub _to_list : Test(1) {
  my $l = List::Ish->new ([1, 2, undef, 3]);
  my @l = $l->to_list;
  is_deeply \@l, [1, 2, undef, 3];
} # _to_list

sub _to_list_2 : Test(1) {
  my $l = List::Ish->new ([undef]);
  my @l = $l->to_list;
  is_deeply \@l, [undef];
} # _to_list_2

sub _to_list_empty : Test(1) {
  my $l = List::Ish->new ([]);
  my @l = $l->to_list;
  is_deeply \@l, [];
} # _to_list_empty

__PACKAGE__->runtests;

1;

=head1 LICENSE

Copyright 2012 Wakaba <w@suika.fam.cx>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
