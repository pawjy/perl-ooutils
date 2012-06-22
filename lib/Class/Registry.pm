package Class::Registry;
use strict;
use warnings;
our $VERSION = '3.0';
use Carp;

my $defs = {};

sub default {
    my ($class, $key, $class_name) = @_;
    
    $defs->{$key} ||= $class_name;
}

sub set {
    my ($class, $key, $class_name) = @_;

    $defs->{$key} = $class_name;
}

sub get {
    my ($class, $key) = @_;
    
    return $defs->{$key};
}

sub require {
    my ($class, $key) = @_;
    
    my $class_name = $defs->{$key} or die "$key: not defined", Carp::longmess;
    eval qq{ require $class_name } or die "$key: $@";
    
    return $class_name;
}

sub load {
    my ($class, $key) = @_;
    
    my $class_name = $defs->{$key} || $key;
    eval qq{ require $class_name } or die "$key: $@";
    
    return $class_name;
}

sub keys {
    return CORE::keys %$defs;
}

1;
