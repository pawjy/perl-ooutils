package test::List::Ish::iteration;
use strict;
use warnings;
use Path::Class;
use lib file (__FILE__)->dir->parent->parent->subdir ('lib')->stringify;
use Test::More;
use base qw(Test::Class);
use List::Ish;

# ------ find ------

sub _find_1 : Test(7) {
  my $l1 = List::Ish->new ([1, 2, 3]);
  
  is $l1->find (sub { $_ == 1 }), 1;
  is $l1->find (sub { $_ == 2 }), 2;
  is $l1->find (sub { $_ == 3 }), 3;
  is $l1->find (sub { $_ == 4 }), undef;
  is $l1->find (sub { $_ == 0 }), undef;
  is $l1->find (sub { $_ eq '' }), undef;
  is $l1->find (sub { not defined $_ }), undef;
} # _find_1

sub _find_2 : Test(7) {
  no warnings 'uninitialized';
  no warnings 'numeric';
  my $l1 = List::Ish->new ([1, undef, 0, 3, '']);
  
  is $l1->find (sub { $_ == 1 }), 1;
  is $l1->find (sub { $_ == 2 }), undef;
  is $l1->find (sub { $_ == 3 }), 3;
  is $l1->find (sub { $_ == 4 }), undef;
  is $l1->find (sub { $_ eq 0 }), 0;
  is $l1->find (sub { defined $_ and $_ eq '' }), '';
  is $l1->find (sub { not defined $_ }), undef;
} # _find_2

sub _find_empty : Test(7) {
  my $l1 = List::Ish->new ([]);
  
  is $l1->find (sub { $_ == 1 }), undef;
  is $l1->find (sub { $_ == 2 }), undef;
  is $l1->find (sub { $_ == 3 }), undef;
  is $l1->find (sub { $_ == 4 }), undef;
  is $l1->find (sub { $_ eq 0 }), undef;
  is $l1->find (sub { defined $_ and $_ eq '' }), undef;
  is $l1->find (sub { not defined $_ }), undef;
} # _find_empty

# ------ has ------

sub _has_1 : Test(7) {
  my $l1 = List::Ish->new ([1, 2, 3]);
  
  ok $l1->has (sub { $_ == 1 });
  ok $l1->has (sub { $_ == 2 });
  ok $l1->has (sub { $_ == 3 });
  ok !$l1->has (sub { $_ == 4 });
  ok !$l1->has (sub { $_ == 0 });
  ok !$l1->has (sub { $_ eq '' });
  ok !$l1->has (sub { not defined $_ });
} # _has_1

sub _has_2 : Test(7) {
  no warnings 'uninitialized';
  no warnings 'numeric';
  my $l1 = List::Ish->new ([1, undef, 0, 3, '']);
  
  ok $l1->has (sub { $_ == 1 });
  ok !$l1->has (sub { $_ == 2 });
  ok $l1->has (sub { $_ == 3 });
  ok !$l1->has (sub { $_ == 4 });
  ok $l1->has (sub { $_ eq 0 });
  ok $l1->has (sub { defined $_ and $_ eq '' });
  ok $l1->has (sub { not defined $_ });
} # _has_2

sub _has_empty : Test(7) {
  my $l1 = List::Ish->new ([]);
  
  ok !$l1->has (sub { $_ == 1 });
  ok !$l1->has (sub { $_ == 2 });
  ok !$l1->has (sub { $_ == 3 });
  ok !$l1->has (sub { $_ == 4 });
  ok !$l1->has (sub { $_ eq 0 });
  ok !$l1->has (sub { defined $_ and $_ eq '' });
  ok !$l1->has (sub { not defined $_ });
} # _has_empty

__PACKAGE__->runtests;

1;

=head1 LICENSE

Copyright 2012 Wakaba <w@suika.fam.cx>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
