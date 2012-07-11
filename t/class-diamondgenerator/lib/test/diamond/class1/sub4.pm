package test::diamond::class1::sub4;
our @ISA = qw(
    test::diamond::class1::sub4::impl
    test::diamond::class1::impl
);

package test::diamond::class1::sub4::impl;

sub sub4_method {
    return 4;
}

1;
