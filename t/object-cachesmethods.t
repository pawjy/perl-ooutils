package test::Object::CachesMethods;
use strict;
use warnings;
no  warnings 'once';
use base qw(Test::Class);
use Path::Class;
use lib file(__FILE__)->dir->parent->subdir('lib')->stringify;
use Test::More;

sub cache_methods : Test(22) {
    my $instance = ThePackage->new;

    is $instance->foo, 1;
    is $instance->foo, 2;
    is $instance->bar, 1;
    is $instance->bar, 2;
    is $instance->baz, 3;
    is $instance->baz, 4;

    ThePackage->cache_methods;

    is $instance->foo, 3;
    is $instance->foo, 4;
    is $instance->bar, 5;
    is $instance->bar, 5;
    is $instance->baz, 6;
    is $instance->baz, 6;

    ThePackage->cache_methods(qw(foo));

    is $instance->foo, 5;
    is $instance->foo, 5;
    is $instance->bar, 5;
    is $instance->bar, 5;

    is $instance->{_foo}, 5;
    is $instance->{_bar}, 5;
    is $instance->{_baz}, 6;

    $instance->flush_cached_methods;

    ok !exists $instance->{_foo};
    ok !exists $instance->{_bar};
    ok !exists $instance->{_baz};
}

{
    package test::object::Object::CachesMethod;
    use base qw(Object::CachesMethod);

    sub new {
        my $class = shift;
        return bless {@_}, $class;
    }
}

{
    package ThePackage;
    use base qw(Object::CachesMethod);
    
    sub new {
        bless {};
    }
    
    sub foo {
        ++$_[0]->{foo};
    }
    
    sub bar : Caches {
        ++$_[0]->{bar};
    }
    
    *baz = \&bar;
}

{
    package test::Object::CachesMethod::main_object;
    use base qw(test::object::Object::CachesMethod);
    
    __PACKAGE__->add_to_has_flush_cached_methods(qw(has sub_has));

    sub has {
        my $self = shift;
        return $self->{has} ||= test::Object::CachesMethod::has_object->new;
    }

    sub sub_has {
        my $self = shift;
        return $self->{sub_has} ||= test::Object::CachesMethod::has_object::subclass->new;
    }

    __PACKAGE__->cache_methods;
}

{
    package test::Object::CachesMethod::has_object;
    use base qw(test::object::Object::CachesMethod);
    
    sub foo : Caches {
        return ++$_[0]->{foo};
    }
    
    sub bar {
        return ++$_[0]->{bar};
    }

    __PACKAGE__->cache_methods;
}

{
    package test::Object::CachesMethod::has_object::subclass;
    use base qw(test::Object::CachesMethod::has_object);
    
    sub bar : Caches {
        return ++$_[0]->{bar};
    }

    sub baz : Caches {
        return ++$_[0]->{baz};
    }

    __PACKAGE__->cache_methods;
}

sub _has_object : Test(3) {
    my $obj = test::Object::CachesMethod::main_object->new;
    
    is $obj->has->foo, 1;
    is $obj->has->foo, 1;
    
    $obj->flush_cached_methods;
    
    is $obj->has->foo, 2;
}

sub _sub_has_object : Test(18) {
    my $obj = test::Object::CachesMethod::main_object->new;
    
    is $obj->sub_has->foo, 1;
    is $obj->sub_has->foo, 1;
    
    is $obj->sub_has->baz, 1;
    is $obj->sub_has->baz, 1;
    
    is $obj->has->foo, 1;
    is $obj->has->foo, 1;

    is $obj->has->bar, 1;
    is $obj->has->bar, 2;
    
    is $obj->sub_has->bar, 1;
    is $obj->sub_has->bar, 1;
    
    $obj->flush_cached_methods;
    
    is $obj->sub_has->foo, 2;

    is $obj->has->bar, 3;
    is $obj->has->bar, 4;

    is $obj->sub_has->bar, 2;
    is $obj->sub_has->bar, 2;
    
    $obj->flush_cached_methods;
    
    is $obj->sub_has->foo, 3;
    is $obj->sub_has->baz, 2;
    is $obj->has->foo, 2;
}

{
    package test::Object::CachesMethod::setter;
    use base qw(test::object::Object::CachesMethod);
    
    sub foo : Caches {
        my $self = shift;
        
        if (@_) {
            $self->{real_foo} = shift;
        }

        return ++$self->{real_foo};
    }

    __PACKAGE__->cache_methods;
}

sub _setter : Test(11) {
    my $obj = test::Object::CachesMethod::setter->new;
    
    is $obj->foo, 1;
    is $obj->foo, 1;
    is $obj->foo, 1;
    
    $obj->foo(4);
    is $obj->foo, 6;
    is $obj->foo, 6;
    
    $obj->foo(0);
    is $obj->foo, 2;
    is $obj->foo, 2;
    
    $obj->foo(-1);
    is $obj->foo, 1;
    
    $obj->foo('');
    is $obj->foo, 2;

    $obj->foo('abc');
    is $obj->foo, 'abe';
    
    $obj->foo(undef);
    is $obj->foo, 2;
}

{
    package test::Object::CachesMethod::getter_or_setter;
    use base qw(test::object::Object::CachesMethod);
    
    sub foo : Caches {
        my $self = shift;
        
        if (@_) {
            $self->{real_foo} = shift;
            return 'invalid value';
        } else {
            return ++$self->{real_foo};
        }
    }

    __PACKAGE__->cache_methods;
}

sub _getter_or_setter : Test(11) {
    my $obj = test::Object::CachesMethod::getter_or_setter->new;
    
    is $obj->foo, 1;
    is $obj->foo, 1;
    is $obj->foo, 1;
    
    $obj->foo(4);
    is $obj->foo, 5;
    is $obj->foo, 5;
    
    $obj->foo(0);
    is $obj->foo, 1;
    is $obj->foo, 1;
    
    $obj->foo(-1);
    is $obj->foo, 0;
    
    $obj->foo('');
    is $obj->foo, 1;

    $obj->foo('abc');
    is $obj->foo, 'abd';
    
    $obj->foo(undef);
    is $obj->foo, 1;
}

{
    package test::Object::CachesMethod::custom;
    use base qw(test::object::Object::CachesMethod);

    __PACKAGE__->add_cached_methods(qw(custom1 custom2));
}

sub _custom_cached_items : Test(3) {
    my $obj = test::Object::CachesMethod::custom->new;
    $obj->{_custom1} = 1;
    $obj->{_custom2} = 2;
    $obj->{_custom3} = 3;
    $obj->flush_cached_methods;
    is $obj->{_custom1}, undef;
    is $obj->{_custom2}, undef;
    is $obj->{_custom3}, 3;
}

__PACKAGE__->runtests;

1;
