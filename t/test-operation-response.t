package test::Test::Operation::Response;
use strict;
use warnings;
use Path::Class;
use lib file(__FILE__)->dir->parent->subdir('lib')->stringify;
use base qw(Test::Class);
use Test::Test::More;
use Operation::Response;
use Test::Operation::Response;

{
    package test::Operation::Response::Response;
    use base qw(Operation::Response);

    __PACKAGE__->set_category(test => 999);
    __PACKAGE__->define_error(error1 => 1);
    __PACKAGE__->define_error(error2 => 100);

    __PACKAGE__->define_error_data_fields(qw(data1 data2));

    $INC{'test/Operation/Response/Response.pm'} = 1;
}

sub _res_ok : Test(6) {
    my $res = test::Operation::Response::Response->new;
    test_ok_ok {
        res_ok $res;
    };
    test_ng_ok {
        res_ng $res;
    };
    test_ng_ok {
        res_ng $res, 'error1';
    };
    failure_output_like {
        res_ng $res, 'response.test.error1';
    } qr[
#          got: undef
#     expected: 'response.test.error1'
];
    test_ng_ok {
        res_ng $res, '';
    };
    test_ng_ok {
        res_ng $res, undef;
    };
}

sub _res_ng : Test(8) {
    my $res = test::Operation::Response::Response->new;
    $res->set_error('error1');
    test_ok_ok {
        res_ng $res, 'response.test.error1';
    };
    test_ok_ok {
        res_ng $res, undef;
    };
    test_ok_ok {
        res_ng $res;
    };
    test_ng_ok {
        res_ng $res, 'response.test.error2';
    };
    failure_output_like {
        res_ng $res, 'response.test.error2';
    } qr[
#          got: 'response.test.error1'
#     expected: 'response.test.error2'
];
    test_ng_ok {
        res_ng $res, '';
    };
    test_ng_ok {
        res_ok $res;
    };
    failure_output_like {
        res_ok $res;
    } qr[
#          got: 'response.test.error1'
#     expected: ''
];
}

__PACKAGE__->runtests;

1;
