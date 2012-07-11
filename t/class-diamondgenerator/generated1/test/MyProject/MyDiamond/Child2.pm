package test::MyProject::MyDiamond::Child2;
use strict;
use warnings;
use test::MyProject::MyDiamond;
use test::MyModule1::MyDiamond::Child2;
use test::MyModule1::MyDiamond;
use test::MyModule2::MyDiamond::Child2;
use test::MyModule2::MyDiamond;
use test::MyDiamond::Child2;
use test::MyDiamond;
push our @ISA, qw(
    test::MyProject::MyDiamond::Child2::impl
    test::MyModule1::MyDiamond::Child2::impl
    test::MyModule2::MyDiamond::Child2::impl
    test::MyDiamond::Child2::impl
    test::MyProject::MyDiamond::impl
    test::MyModule1::MyDiamond::impl
    test::MyModule2::MyDiamond::impl
    test::MyDiamond::impl
);

package test::MyProject::MyDiamond::Child2::impl;


1;
