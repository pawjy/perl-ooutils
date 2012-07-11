package test::Class::DiamondGenerator;
use strict;
use warnings;
use Path::Class;
use lib glob file(__FILE__)->dir->parent->parent->subdir('*/lib')->stringify;
use base qw(Test::Class);
use Test::MoreMore;
use Test::Directory::Diff;
use Class::DiamondGenerator;
use File::Temp qw(tempdir);
use lib file(__FILE__)->dir->subdir('class-diamondgenerator/lib')->stringify;

# 大元のクラス
{
    package test::diamond::class1;
    our @ISA = qw(
        test::diamond::class1::impl
    );
    $INC{'test/diamond/class1.pm'} = 1;
    package test::diamond::class1::impl;
}
{
    package test::diamond::class1::sub1;
    our @ISA = qw(
        test::diamond::class1::sub1::impl
        test::diamond::class1::impl
    );
    $INC{'test/diamond/class1/sub1.pm'} = 1;
    package test::diamond::class1::sub1::impl;
}
{
    package test::diamond::class1::sub2;
    our @ISA = qw(
        test::diamond::class1::sub2::impl
        test::diamond::class1::impl
    );
    $INC{'test/diamond/class1/sub2.pm'} = 1;
    package test::diamond::class1::sub2::impl;
}
{
    package test::diamond::class1::sub3;
    our @ISA = qw(
        test::diamond::class1::sub3::impl
        test::diamond::class1::impl
        test::mysuperclass1
    );
    $INC{'test/diamond/class1/sub3.pm'} = 2;
    package test::diamond::class1::sub3::impl;
    package test::mysuperclass1;
}
# sub4, sub5 は別ファイルとして存在
{
    package test::diamond::class1::ClassGenerator;
    use base qw(Class::DiamondGenerator);
}

# 大元のクラスだけを継承したサブクラス
{
    package test::diamond::my::class1;
    our @ISA = qw(
        test::diamond::my::class1::impl
        test::diamond::class1::impl
    );
    $INC{'test/diamond/my/class1.pm'} = 1;
    package test::diamond::my::class1::impl;
}
{
    package test::diamond::my::class1::sub1;
    our @ISA = qw(
        test::diamond::my::class1::sub1::impl
        test::diamond::class1::sub1::impl
        test::diamond::my::class1::impl
        test::diamond::class1::impl
    );
    $INC{'test/diamond/my/class1/sub1.pm'} = 1;
    package test::diamond::my::class1::sub1::impl;
}

# 大元のクラスだけを継承したサブクラス2
{
    package test::diamond::my2::class1;
    our @ISA = qw(
        test::diamond::my2::class1::impl
        test::diamond::class1::impl
    );
    $INC{'test/diamond/my2/class1.pm'} = 1;
    package test::diamond::my2::class1::impl;
}
{
    package test::diamond::my2::class1::sub1;
    our @ISA = qw(
        test::diamond::my2::class1::sub1::impl
        test::diamond::class1::sub1::impl
        test::diamond::my2::class1::impl
        test::diamond::class1::impl
    );
    $INC{'test/diamond/my2/class1/sub1.pm'} = 1;
    package test::diamond::my2::class1::sub1::impl;
}

# 大元のクラスだけを継承したサブクラス2を継承したサブクラス
{
    package test::diamond::my2sub::class1;
    our @ISA = qw(
        test::diamond::my2sub::class1::impl
        test::diamond::my2::class1::impl
        test::diamond::class1::impl
    );
    $INC{'test/diamond/my2sub/class1.pm'} = 1;
    package test::diamond::my2sub::class1::impl;
}
{
    package test::diamond::my2sub::class1::sub1;
    our @ISA = qw(
        test::diamond::my2sub::class1::sub1::impl
        test::diamond::my2::class1::sub1::impl
        test::diamond::class1::sub1::impl
        test::diamond::my2sub::class1::impl
        test::diamond::my2::class1::impl
        test::diamond::class1::impl
    );
    $INC{'test/diamond/my2sub/class1/sub1.pm'} = 1;
    package test::diamond::my2sub::class1::sub1::impl;
}

sub _load_module : Test(2) {
    test::diamond::class1::ClassGenerator->load_module('sub2', 'test::diamond::my::class1');
    eq_or_diff \@test::diamond::my::class1::sub2::ISA, [qw(
        test::diamond::my::class1::sub2::impl
        test::diamond::class1::sub2::impl
        test::diamond::my::class1::impl
        test::diamond::class1::impl
    )];
    ok $INC{'test/diamond/my/class1/sub2.pm'};
}

sub _load_module_multiple : Test(4) {
    test::diamond::class1::ClassGenerator->load_module('sub2', 'test::diamond::my2sub::class1');
    eq_or_diff \@test::diamond::my2sub::class1::sub2::ISA, [qw(
        test::diamond::my2sub::class1::sub2::impl
        test::diamond::my2::class1::sub2::impl
        test::diamond::class1::sub2::impl
        test::diamond::my2sub::class1::impl
        test::diamond::my2::class1::impl
        test::diamond::class1::impl
    )];
    ok $INC{'test/diamond/my2sub/class1/sub2.pm'};
    eq_or_diff \@test::diamond::my2::class1::sub2::ISA, [qw(
        test::diamond::my2::class1::sub2::impl
        test::diamond::class1::sub2::impl
        test::diamond::my2::class1::impl
        test::diamond::class1::impl
    )];
    ok $INC{'test/diamond/my2/class1/sub2.pm'};
}

sub _load_module_semi_existing : Test(4) {
    test::diamond::class1::ClassGenerator->load_module('sub3', 'test::diamond::my2::class1');
    eq_or_diff \@test::diamond::my2::class1::sub3::ISA, [qw(
        test::diamond::my2::class1::sub3::impl
        test::diamond::class1::sub3::impl
        test::diamond::my2::class1::impl
        test::diamond::class1::impl
    )];
    ok $INC{'test/diamond/my2/class1/sub3.pm'};
    eq_or_diff \@test::diamond::class1::sub3::ISA, [qw(
        test::diamond::class1::sub3::impl
        test::diamond::class1::impl
        test::mysuperclass1
    )];
    is $INC{'test/diamond/class1/sub3.pm'}, 2;
}

sub _load_module_semi_existing_file : Test(4) {
    test::diamond::class1::ClassGenerator->load_module('sub4', 'test::diamond::my2::class1');
    eq_or_diff \@test::diamond::my2::class1::sub4::ISA, [qw(
        test::diamond::my2::class1::sub4::impl
        test::diamond::class1::sub4::impl
        test::diamond::my2::class1::impl
        test::diamond::class1::impl
    )];
    ok $INC{'test/diamond/my2/class1/sub4.pm'};
    isnt $INC{'test/diamond/class1/sub4.pm'}, 1;
    is +test::diamond::my2::class1::sub4->sub4_method, 4;
}

sub _load_module_semi_broken_file : Test(4) {
    dies_ok { test::diamond::class1::ClassGenerator->load_module('sub5', 'test::diamond::my2::class1') };
    ng @test::diamond::my2::class1::sub5::ISA;
    ng $INC{'test/diamond/my2/class1/sub5.pm'};
    isnt $INC{'test/diamond/class1/sub5.pm'}, 1;
}

sub _generate_missing_classes : Test(1) {
    {
        package test::MyDiamond::ClassGenerator;
        use strict;
        use warnings;
        use base qw(Class::DiamondGenerator);
        
        __PACKAGE__->supermost_parent_package('test::MyDiamond');
        __PACKAGE__->child_names([qw/
            Child1 Child2
        /]);
        
        1;
    }

    my $lib_d = dir(tempdir);
    $lib_d->mkpath;
    #warn $lib_d, "\n";
    test::MyDiamond::ClassGenerator->generate_missing_classes(
        lib_d => $lib_d,
        parent_package => 'test::MyProject::MyDiamond',
        super_parent_packages => [
            'test::MyModule1::MyDiamond',
            'test::MyModule2::MyDiamond',
        ],
        config_package => 'test::MyProject::Config::MyDiamond',
    );

    my $expected_d = file(__FILE__)->dir->subdir('class-diamondgenerator')->subdir('generated1');
    eq_or_diff_dir $lib_d, $expected_d;
}

__PACKAGE__->runtests;

1;
