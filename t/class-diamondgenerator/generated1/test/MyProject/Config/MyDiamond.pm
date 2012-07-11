package test::MyProject::Config::MyDiamond;
use strict;
use warnings;

use Class::Registry;
Class::Registry->set(my_diamond => 'test::MyProject::MyDiamond');
Class::Registry->set(my_diamond_child1 => 'test::MyProject::MyDiamond::Child1');
Class::Registry->set(my_diamond_child2 => 'test::MyProject::MyDiamond::Child2');

1;
