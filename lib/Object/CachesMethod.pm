package Object::CachesMethod;
use strict;
use warnings;
use base qw(Class::Data::Inheritable);
use Carp;

__PACKAGE__->mk_classdata(__coderefs_to_cache => []);
__PACKAGE__->mk_classdata(__cached_methods    => []);
__PACKAGE__->mk_classdata(__has_flush_cached_methods => {});

sub MODIFY_CODE_ATTRIBUTES {
    my ($class, $code) = splice @_, 0, 2;

    my @attrs;
    foreach (@_) {
        push @attrs, $_ and next unless $_ eq 'Caches';
        push @{$class->__coderefs_to_cache}, $code;
    }
    @attrs;
}

sub _find_sub_names {
    my ($class, $code) = @_;

    no strict 'refs';
    my @names;
    while (my ($name, $symbol) = each %{"$class\::"}) {
        push @names, $name if (ref $symbol ne 'SCALAR') && (ref $symbol ne 'REF') && *{$symbol}{CODE} && *{$symbol}{CODE} == $code;
    }
    @names;
}

sub cache_methods {
    my $class = shift;
    my @methods = ref $_[0] eq 'ARRAY' ? @$_[0] : @_;

    foreach my $coderef (@{$class->__coderefs_to_cache}) {
        foreach  my $method ($class->_find_sub_names($coderef)) {
            push @methods, $method;
        }
    }

    $class->_cache_methods(@methods);
}

sub add_cached_methods {
    my $class = shift;
    my @methods = ref $_[0] eq 'ARRAY' ? @$_[0] : @_;
    
    push @{$class->__cached_methods}, @methods;
}

sub _cache_methods {
    my ($class, @methods) = @_;

    no strict 'refs';
    no warnings 'redefine';
    foreach my $method (@methods) {
        my $code = $class->can($method) or carp "$class\::$method is not defined";
        *{"$class\::$method"} = sub {
            my $self = shift;
            if (@_) {
                delete $self->{"_$method"};
                return $self->$code(@_);
            }
            return $self->{"_$method"}
                if exists $self->{"_$method"};
            $self->{"_$method"} = $self->$code;
        };
        push @{$class->__cached_methods}, $method;
    }
}

sub add_to_has_flush_cached_methods {
    my ($class, @key) = @_;
    
    for my $key (@key) {
        $class->__has_flush_cached_methods({%{$class->__has_flush_cached_methods}, $key => 1});
    }
}

sub flush_cached_methods {
    my $self  = shift;
    my $class = ref $self;

    foreach (@{$class->__cached_methods}) {
        delete $self->{"_$_"};
    }

    foreach (keys %{$class->__has_flush_cached_methods}) {
        my $obj = $self->{$_};
        if ($obj and ref $obj) {
            $obj->flush_cached_methods;
        }
    }
}

sub instance_cache {
    my $self = shift;
    $self->{_icache} ||= {};
}

1;
