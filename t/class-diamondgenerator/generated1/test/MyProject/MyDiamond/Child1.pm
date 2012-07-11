package test::MyProject::MyDiamond::Child1;
use strict;
use warnings;
use test::MyProject::MyDiamond;
use test::MyModule1::MyDiamond::Child1;
use test::MyModule1::MyDiamond;
use test::MyModule2::MyDiamond::Child1;
use test::MyModule2::MyDiamond;
use test::MyDiamond::Child1;
use test::MyDiamond;
push our @ISA, qw(
    test::MyProject::MyDiamond::Child1::impl
    test::MyModule1::MyDiamond::Child1::impl
    test::MyModule2::MyDiamond::Child1::impl
    test::MyDiamond::Child1::impl
    test::MyProject::MyDiamond::impl
    test::MyModule1::MyDiamond::impl
    test::MyModule2::MyDiamond::impl
    test::MyDiamond::impl
);

package test::MyProject::MyDiamond::Child1::impl;


1;
