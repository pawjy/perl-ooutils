package Class::Registry;
use strict;
use warnings;
our $VERSION = '1.1';
use UNIVERSAL::require;
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

sub Class::Registry::require {
    my ($class, $key) = @_;
    
    my $class_name = $defs->{$key} or die "$key: not defined", Carp::longmess;
    $class_name->require or die "$key: $@";
    
    return $class_name;
}

sub keys {
    return CORE::keys %$defs;
}

1;
