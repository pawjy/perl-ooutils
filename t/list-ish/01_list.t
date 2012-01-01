use strict;
use warnings;
use Path::Class;
use lib file (__FILE__)->dir->parent->parent->subdir ('lib')->stringify;

package Hatena;

sub new {
    my($class, %args) = @_;
    bless {%args}, $class;
}

sub name { shift->{name} };

package List::Ish::Test;
use base qw/Test::Class/;

use Test::More;
use List::Ish;

__PACKAGE__->runtests;

sub use_test : Tests(1) {
    use_ok 'List::Ish';
}

sub new_test : Tests(6) {
    my $array_ref = [1,2];
    my $list = List::Ish->new($array_ref);
    ok $list;
    isa_ok $list, 'List::Ish';
    isa_ok $list, 'ARRAY';
    is $list->size, 2;
    is $list->first, 1;
    is $list->last, 2;
}

sub grep_hash : Tests(1) {
    my $list = List::Ish->new([
        { name => 0 },
        { name => 1 },
        { name => '' },
        { name => 'lopnor' },
    ])->grep('name');
    is ($list->size, 2, 'grep hash');
}

sub grep_class : Tests(1) {
    my $list = List::Ish->new([
        Hatena->new( name => 0 ),
        Hatena->new( name => 1 ),
        Hatena->new( name => '' ),
        Hatena->new( name => 'lopnor' ),
    ])->grep('name');
    is ($list->size, 2, 'grep object');
}

1;
