# original code is http://github.com/naoya/list-rubylike/tree/master/t/01-methods.t
package List::Ish::Test;
use strict;
use warnings;
use Path::Class;
use lib file (__FILE__)->dir->parent->parent->subdir ('lib')->stringify;
use base qw/Test::Class/;

use Test::More;
use List::Ish;

__PACKAGE__->runtests;

sub list (@) {
    my @raw = (ref $_[0] and ref $_[0] eq 'ARRAY') ? @{$_[0]} : @_;
    List::Ish->new(\@raw);
}

sub test_instantiate : Tests(8) {
    my $list = list([qw/foo bar baz/]);
    isa_ok $list, 'List::Ish';
    is @$list, 3;

    $list = list(qw/foo bar baz/);
    isa_ok $list, 'List::Ish';
    is @$list, 3;

    $list = list();
    isa_ok $list, 'List::Ish';
    is @$list, 0;

    $list = list({ foo => 'bar' });
    isa_ok $list, 'List::Ish';
    is_deeply $list->to_a, [ { foo => 'bar' } ];
}

sub test_push_and_pop : Tests(7) {
    my $list = list(qw/foo bar baz/);
    $list->push('foo');
    is @$list, 4;
    is $list->[3], 'foo';

    $list->push('foo', 'bar');
    is @$list, 6;
    is $list->[5], 'bar';

    is $list->pop, 'bar';
    is @$list, 5;

    isa_ok $list->push('baz'), 'List::Ish';
}

sub test_unshift_and_shift : Tests(7) {
    my $list = list(qw/foo bar baz/);
    $list->unshift('hoge');
    is @$list, 4;
    is $list->[0], 'hoge';

    $list->unshift('moge', 'uge');
    is @$list, 6;
    is $list->[0], 'moge';

    is $list->shift, 'moge';
    is @$list, 5;

    isa_ok $list->unshift('baz'), 'List::Ish';
}

sub join : Tests(3) {
    my $list = list(qw/foo bar baz/);
    is $list->join('/'), 'foo/bar/baz';
    is $list->join('.'), 'foo.bar.baz';
    is $list->join(''), 'foobarbaz';
}

sub each : Tests(3) {
    my $list =list(qw/foo bar baz/);
    my @resulsts;
    my $ret = $list->each(sub{ s!^ba!!; push @resulsts, $_  });
    isa_ok $ret, 'List::Ish';
    is_deeply \@resulsts, [qw/foo r z/];
    is_deeply $ret->to_a, [qw/foo bar baz/];
}

sub test_concat_and_append : Test(5) {
    for my $method (qw/append/) {
        my $list = list(qw/foo bar baz/);
        $list->$method(['foo']);
        is @$list, 4;
        is $list->[3], 'foo';
        $list->$method(['foo', 'bar']);
        is @$list, 6;
        is $list->[5], 'bar';
        isa_ok $list->$method(['hoge']), 'List::Ish';
    }
}

sub test_prepend : Tests(5) {
    my $list = list(qw/foo bar baz/);
    $list->prepend(['foo']);
    is @$list, 4;
    is $list->[0], 'foo';
    $list->prepend(['foo', 'bar']);
    is @$list, 6;
    is $list->[0], 'foo';
    isa_ok $list->prepend(['hoge']), 'List::Ish';
}

sub test_collect_and_map : Tests(5) {
    for my $method (qw/map/) {
        my $list = list(qw/foo bar baz/);

        my $new = $list->$method(sub { s/^ba//; $_ });
        isa_ok $new, 'List::Ish';
        is_deeply $new->to_a, [qw/foo r z/];
        is_deeply $list->to_a, [qw/foo bar baz/];

        my @new = $list->$method(sub { s/^ba//; $_ });
        is_deeply \@new, [[qw/foo r z/]];
        is_deeply $list->to_a, [qw/foo bar baz/];
    }
}

sub test_grep : Tests(3) {
    my $list = list(qw/foo bar baz/);
    isa_ok $list->grep(sub { $_ }), 'List::Ish';
    is_deeply $list->grep(sub { m/^b/ })->to_a, [qw/bar baz/];

    my @ret = $list->grep(sub { m/^b/ });
    is_deeply \@ret, [[qw/bar baz/]];
}

sub test_sort : Tests(5) {
    my $list = list(3, 1, 2);
    isa_ok $list->sort, 'List::Ish';
    is_deeply $list->sort->to_a, [1, 2, 3];
    is_deeply $list->sort(sub { $_[1] <=> $_[0] })->to_a, [3, 2, 1];
    is_deeply $list->to_a, [3, 1, 2];

    my @ret = $list->sort(sub { $_[1] <=> $_[0] });
    is_deeply \@ret, [[3, 2, 1]];
}

sub test_sort_by : Tests(4) {
    my $list = list([ [3], [1], [2] ]);
    isa_ok $list->sort_by(sub { $_->[0] }), 'List::Ish';
    is_deeply $list->sort_by(sub { $_->[0] })->to_a, [[1], [2], [3]];
    is_deeply $list->sort_by(sub { $_->[0] }, sub { $_[1] <=> $_[0] })->to_a, [[3], [2], [1]];
    my @ret = $list->sort_by(sub { $_->[0] });
    is_deeply \@ret, [[[1], [2], [3]]];
}


sub test_length_and_size : Tests(4) {
    for my $method (qw/length size/) {
        is list(1, 2, 3, 4)->size, 4;
        is list()->size, 0;
    }
}

sub test_dup : Tests(3) {
    my $list = list(1, 2, 3);
    isnt $list, $list->dup;
    isa_ok $list->dup, 'List::Ish';
    is_deeply $list->to_a, $list->dup->to_a;
}

sub test_slice : Tests(12) {
    my $list = list(0, 1, 2);

    is_deeply $list->slice(0, 0)->to_a, [0];
    is_deeply $list->slice(0, 1)->to_a, [0, 1];
    is_deeply $list->slice(0, 2)->to_a, [0, 1, 2];
    is_deeply $list->slice(0, 3)->to_a, [0, 1, 2];

    is_deeply $list->slice(1, 1)->to_a, [1];
    is_deeply $list->slice(1, 2)->to_a, [1, 2];
    is_deeply $list->slice(1, 3)->to_a, [1, 2];

    is_deeply $list->slice(0)->to_a, [0, 1, 2];
    is_deeply $list->slice(1)->to_a, [0, 1, 2];
    is_deeply $list->slice(2)->to_a, [];

    is_deeply $list->slice(3)->to_a, [];
    is_deeply $list->slice->to_a, [0, 1, 2];
}

sub test_find_and_detect : Test(4) {
    my $list = list(1, 2, 3);

    for my $method (qw/find/) {
        is $list->$method(sub { $_ == 1 }), 1;
        is $list->$method(sub { $_ == 2 }), 2;
        is $list->$method(sub { $_ == 3 }), 3;
        is $list->$method(sub { $_ == 4 }), undef;
    }
}

sub test_reverse : Tests(1) {
    my $list = list(0, 1, 2, 3);
    is_deeply [3, 2, 1, 0], $list->reverse->to_a;
}

sub test_some_method_argument_in_not_a_code : Test(4) {
    my $obj = List::Ish->new;

    for my $method (qw/each map grep find/) {
        local $@;
        eval { $obj->$method( +{} ) };
        ok $@;
    }
}

1;
