package test::MyProject::MyDiamond;
use strict;
use warnings;
use test::MyModule1::MyDiamond;
use test::MyModule2::MyDiamond;
use test::MyDiamond;
push our @ISA, qw(
    test::MyProject::MyDiamond::impl
    test::MyModule1::MyDiamond::impl
    test::MyModule2::MyDiamond::impl
    test::MyDiamond::impl
);

use Class::Registry;
Class::Registry->default(my_diamond => __PACKAGE__);
Class::Registry->default(my_diamond_child1 => __PACKAGE__ . '::Child1');
Class::Registry->default(my_diamond_child2 => __PACKAGE__ . '::Child2');


package test::MyProject::MyDiamond::impl;


1;
