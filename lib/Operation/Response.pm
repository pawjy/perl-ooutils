package Operation::Response;
use strict;
use warnings;
our $VERSION = '1.0';
use Exporter::Lite;
use List::Ish;
use Data::Dumper;

our $GlobalCategoryCode ||= 9999_000_000;

our $Defs = {};

sub new {
    return bless {}, $_[0];
}

sub mk_accessors {
    my $class = shift;
    for my $method (@_) {
        eval sprintf q{
            sub %s::%s {
                if (@_ > 1) {
                    $_[0]->{%s} = $_[1];
                }
                return $_[0]->{%s};
            }
            1;
        }, $class, $method, $method, $method or die $@;
    }
}

sub mk_classdata {
    my ($class, $name, $default) = @_;
    eval sprintf q{
        sub %s::%s {
            if (@_ > 1) {
                $Operation::Response::Defs->{'%s'}->{%s} = $_[1];
            }
            return $Operation::Response::Defs->{'%s'}->{%s};
        }
        1;
    }, $class, $name, $class, $name, $class, $name or die $@;
    $Operation::Response::Defs->{$class}->{$name} = $default if defined $default;
}

sub category_name {
    if (@_ > 1) {
        $Defs->{$_[0]}->{category_name} = $_[1];
    }
    return $Defs->{$_[0]}->{category_name};
}

sub category_code {
    if (@_ > 1) {
        $Defs->{$_[0]}->{category_code} = $_[1];
    }
    return $Defs->{$_[0]}->{category_code};
}

sub set_category {
    my ($class, $name, $code) = @_;
    
    $class->category_name($name);
    $class->category_code($code * 1_000);
}

sub define_error {
    my $class = shift;
    my $type = uc shift;
    my $code = shift;
    my %args = @_;
    $code += $class->category_code + $GlobalCategoryCode;
    my $msgid = sprintf 'response.%s.%s', $class->category_name, lc $type;
    
    $Defs->{$class}->{error_codes}->{$type} = $code;
    $Defs->{$class}->{error_msgids}->{$type} = $msgid;
    $Defs->{$class}->{code_to_msgid}->{$code} = $msgid;
    $Defs->{$class}->{http_status}->{$code} = $args{http_status}
        if $args{http_status};

    no strict 'refs';
    *{$class . '::' . $type} = sub { $code };

    push @{$class . '::EXPORT'}, $type;
    push @{$class . '::EXPORT_OK'}, $type;
}

sub set_error {
    my $self = shift;
    my $type = uc shift;
    $self->error(1);
    $self->code($Defs->{ref $self}->{error_codes}->{$type}
                    or die "Unknown error type $type");
    $self->msgid($Defs->{ref $self}->{error_msgids}->{$type});
    $self->errors->push({msgid => $self->msgid, code => $self->code});

    for (@{$Defs->{ref $self}->{error_data_fields} ||= []}) {
        delete $self->{$_};
    }
}

sub define_error_data_fields {
    my ($class, @fields) = @_;

    push @{$Defs->{$class}->{error_data_fields} ||= []}, @fields;
    
    for my $field (@fields) {
        no strict 'refs';
        *{$class . '::' . $field} = sub {
            my $self = shift;
            
            if (@_) {
                $self->errors->[-1]->{$field} = $self->{$field} = shift;
            }

            return $self->{$field};
        };
    }
}

sub errors {
    my $self = shift;
    return $self->{errors} ||= List::Ish->new;
}

sub merge_response {
    my ($self, $res2) = @_;
    $self->errors->append($res2->errors);
    if ($res2->error) {
        $self->error($res2->error);
        $self->code($res2->code);
        $self->msgid($res2->msgid);
    }
    return $self;
}

sub is_success {  !shift->error }
sub is_error   { !!shift->error }

sub error {
    if (@_ > 1) {
        $_[0]->{error} = $_[1];
    }
    return $_[0]->{error};
}

sub code {
    if (@_ > 1) {
        $_[0]->{code} = $_[1];
    }
    return $_[0]->{code};
}

sub msgid {
    if (@_ > 1) {
        $_[0]->{msgid} = $_[1];
    }
    return $_[0]->{msgid};
}

sub http_status {
    return $_[0]->code 
        ? $Defs->{ref $_[0]}->{http_status}->{$_[0]->code} || 400
        : 200;
}

sub debug_msg_key {
    return 'RESPONSE';
}

sub debug_msg {
    my ($self, $msg) = @_;

    warn sprintf "%s: [%s] %s: %s\n",
        $self->debug_msg_key,
        (scalar localtime),
        $self->debug_info,
        $msg;
}

sub debug_info {
    my $self = shift;
    if ($self->is_success) {
        return sprintf '<%s: ok>', ref $self;
    } else {
        return sprintf '<%s: %s>', ref $self, $self->errors->map(sub {
            my $fields = [];
            for my $field (@{$Defs->{ref $self}->{error_data_fields} ||= []}) {
                my $value = $_->{$field};
                if (not defined $value) {
                    $value = '(undef)';
                } elsif (ref $value) {
                    if (UNIVERSAL::can($value, 'debug_info')) {
                        $value = $value->debug_info;
                    } elsif (UNIVERSAL::isa($value, 'Path::Class::File') or
                             UNIVERSAL::isa($value, 'Path::Class::Dir')) {
                        $value = $value . '';
                    } else {
                        $value = Dumper $value;
                    }
                } else {
                    $value = '"'.$value.'"';
                }
                push @$fields, $field . ': ' . $value;
            }
            return sprintf '<%s: %s>', $_->{msgid}, join '; ', @$fields;
        })->join(', ');
    }
}

1;

=head1 LICENSE

Copyright 2009-2012 Hatena <http://www.hatena.ne.jp/>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
