package Test::Operation::Response;
use strict;
use warnings;
our $VERSION = '1.0';
use Exporter::Lite;
use Test::More;

our @EXPORT = qw(
    res_ok
    res_ng
);

sub res_ok ($;$) {
    my ($res, $name) = @_;
    
    local $Test::Builder::Level = $Test::Builder::Level + 1;
    if ($res->is_success) {
        ok 1, $name;
    } else {
        is $res->msgid, '', $name;
    }
}

sub res_ng ($;$$) {
    my ($res, $msgid, $name) = @_;
    
    local $Test::Builder::Level = $Test::Builder::Level + 1;
    if ($res->is_success) {
        if (defined $msgid) {
            is $res->msgid, $msgid, $name;
        } else {
            ok !$res->is_success, $name;
        }
    } else {
        if (defined $msgid) {
            is $res->msgid, $msgid, $name;
        } else {
            ok $res->msgid, $name;
        }
    }
}

1;

__END__

=head1 AUTHOR

Wakaba (id:wakabatan) <wakabatan@hatena.ne.jp>.

=head1 LICENSE

Copyright 2009-2011 Hatena <http://www.hatena.ne.jp/>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
