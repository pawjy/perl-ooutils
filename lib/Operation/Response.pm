package Operation::Response;
use strict;
use warnings;
our $VERSION = '1.0';
use base qw(Class::Accessor::Fast Class::Data::Inheritable);
use Exporter::Lite;
use List::Rubyish;
use Data::Dumper;

__PACKAGE__->mk_classdata(category_name => undef);
__PACKAGE__->mk_classdata(category_code => undef);
__PACKAGE__->mk_classdata(error_codes => undef);
__PACKAGE__->mk_classdata(error_msgids => undef);
__PACKAGE__->mk_classdata(code_to_msgid => undef);
__PACKAGE__->mk_classdata(error_data_fields => undef);

__PACKAGE__->mk_accessors(qw(
    error
    code
    msgid
));

sub set_category {
    my ($class, $name, $code) = @_;
    
    $class->category_name($name);
    $class->category_code($code * 1_000);
}

sub define_error {
    my $class = shift;
    my $type = uc shift;
    my $code = shift;
    $code += $class->category_code + 8107_000_000;
    my $msgid = sprintf 'response.%s.%s', $class->category_name, lc $type;
    
    $class->error_codes({}) unless $class->error_codes;
    $class->error_msgids({}) unless $class->error_msgids;
    $class->code_to_msgid({}) unless $class->code_to_msgid;

    $class->error_codes->{$type} = $code;
    $class->error_msgids->{$type} = $msgid;
    $class->code_to_msgid->{$code} = $msgid;

    no strict 'refs';
    *{$class . '::' . $type} = sub { $code };

    push @{$class . '::EXPORT'}, $type;
    push @{$class . '::EXPORT_OK'}, $type;
}

sub set_error {
    my $self = shift;
    my $type = uc shift;
    $self->error(1);
    $self->code($self->error_codes->{$type} or die "Unknown error type $type");
    $self->msgid($self->error_msgids->{$type});
    $self->errors->push({msgid => $self->msgid, code => $self->code});

    my $edf = $self->error_data_fields;
    $edf->each(sub { delete $self->{$_} }) if $edf;
}

sub define_error_data_fields {
    my ($class, @fields) = @_;

    $class->error_data_fields($class->error_data_fields || List::Rubyish->new);
    $class->error_data_fields->push(@fields);
    
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
    return $self->{errors} ||= List::Rubyish->new;
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
            for my $field (@{$self->error_data_fields or []}) {
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

__END__

=head1 AUTHOR

Wakaba (id:wakabatan) <wakabatan@hatena.ne.jp>.

=head1 ACKNOWLEDGEMENTS

This module was originally developed as part of the Flipnote Hatena
project.  Thanks to id:antipop and id:onishi for their useful inputs.

=head1 LICENSE

Copyright 2009-2011 Hatena <http://www.hatena.ne.jp/>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
