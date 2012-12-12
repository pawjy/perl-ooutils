package test::Operation::Response;
use strict;
use warnings;
use Path::Class;
use lib file(__FILE__)->dir->parent->subdir('lib')->stringify;
use base qw(Test::Class);
use Test::More;

BEGIN {
    $Operation::Response::GlobalCategoryCode ||= 10_107_000_000;
}

{
    package test::Operation::Response::Response;
    use base qw(Operation::Response);
    
    __PACKAGE__->set_category(test => 999);
    __PACKAGE__->define_error(error1 => 1);
    __PACKAGE__->define_error(error2 => 100, http_status => 401);
    
    __PACKAGE__->define_error_data_fields(qw(data1 data2));
    
    $INC{'test/Operation/Response/Response.pm'} = 1;
}

{
    package test::Operation::Response::Import;
    eval q{ use test::Operation::Response::Response };
}

sub _instantiation : Test(7) {
    my $res = test::Operation::Response::Response->new;
    isa_ok $res, 'test::Operation::Response::Response';
    isa_ok $res, 'Operation::Response';
    ok !$res->is_error;
    ok $res->is_success;
    is $res->code, undef;
    is $res->msgid, undef;
    is $res->http_status, 200;
}

sub _constants : Test(4) {
    my $res = test::Operation::Response::Response->new;
    is $res->ERROR1, 10_107_999_001;
    is $res->ERROR2, 10_107_999_100;
    is test::Operation::Response::Import::ERROR1(), 10_107_999_001;
    is test::Operation::Response::Import::ERROR2(), 10_107_999_100;
}

sub _set_error_1 : Test(6) {
    my $res = test::Operation::Response::Response->new;
    $res->set_error('error1');
    is $res->code, 10_107_999_001;
    is $res->msgid, 'response.test.error1';
    is $res->http_status, 400;
    ok $res->is_error;
    ok !$res->is_success;
    is_deeply $res->errors, [
        {msgid => 'response.test.error1', code => 10_107_999_001},
    ];
}

sub _set_error_2 : Test(6) {
    my $res = test::Operation::Response::Response->new;
    $res->set_error('error2');
    is $res->code, 10_107_999_100;
    is $res->msgid, 'response.test.error2';
    is $res->http_status, 401;
    ok $res->is_error;
    ok !$res->is_success;
    is_deeply $res->errors, [
        {msgid => 'response.test.error2', code => 10_107_999_100},
    ];
}

sub _set_error_3 : Test(10) {
    my $res = test::Operation::Response::Response->new;

    $res->set_error('error2');
    is $res->code, 10_107_999_100;
    is $res->msgid, 'response.test.error2';
    ok $res->is_error;
    ok !$res->is_success;
    is_deeply $res->errors, [
        {msgid => 'response.test.error2', code => 10_107_999_100},
    ];

    $res->set_error('error1');
    is $res->code, 10_107_999_001;
    is $res->msgid, 'response.test.error1';
    ok $res->is_error;
    ok !$res->is_success;
    is_deeply $res->errors, [
        {msgid => 'response.test.error2', code => 10_107_999_100},
        {msgid => 'response.test.error1', code => 10_107_999_001},
    ];
}

sub _define_error_fields : Test(9) {
    my $res = test::Operation::Response::Response->new;
    
    ok !$res->data1;
    ok !$res->data2;
    
    $res->set_error('error1');
    $res->data1('data1value');
    is $res->data1, 'data1value';
    is_deeply $res->errors, [{msgid => 'response.test.error1', code => 10_107_999_001, data1 => 'data1value'}];
    
    $res->set_error('error2');
    $res->data2('data2value');
    is $res->data2, 'data2value';
    is_deeply $res->errors, [
        {msgid => 'response.test.error1', code => 10_107_999_001, data1 => 'data1value'},
        {msgid => 'response.test.error2', code => 10_107_999_100, data2 => 'data2value'},
    ];
    
    $res->set_error('error2');
    $res->data1('DATA1VALUE');
    $res->data2('DATA2VALUE');
    is $res->data1, 'DATA1VALUE';
    is $res->data2, 'DATA2VALUE';
    is_deeply $res->errors, [
        {msgid => 'response.test.error1', code => 10_107_999_001, data1 => 'data1value'},
        {msgid => 'response.test.error2', code => 10_107_999_100, data2 => 'data2value'},
        {msgid => 'response.test.error2', code => 10_107_999_100, data1 => 'DATA1VALUE', data2 => 'DATA2VALUE'},
    ];
}

sub _debug_info : Test(3) {
    my $res = test::Operation::Response::Response->new;

    is $res->debug_info, '<test::Operation::Response::Response: ok>';
    
    $res->set_error('error1');
    is $res->debug_info, '<test::Operation::Response::Response: <response.test.error1: data1: (undef); data2: (undef)>>';
    
    $res->set_error('error2');
    is $res->debug_info, '<test::Operation::Response::Response: <response.test.error1: data1: (undef); data2: (undef)>, <response.test.error2: data1: (undef); data2: (undef)>>';
}

sub _merge_errors : Test(5) {
    my $res1 = test::Operation::Response::Response->new;
    my $res2 = test::Operation::Response::Response->new;
    
    $res1->set_error('error1');
    $res2->set_error('error2');
    $res2->set_error('error2');
    $res1->merge_response($res2);
    
    is_deeply $res1->errors, [{
        msgid => 'response.test.error1',
        code => 10_107999001,
    }, {
        msgid => 'response.test.error2',
        code => 10_107999100,
    }, {
        msgid => 'response.test.error2',
        code => 10_107999100,
    }];
    is $res1->error, 1;
    is $res1->code, 10_107999100;
    is $res1->msgid, 'response.test.error2';
    ok $res1->is_error;
}

sub _merge_empty : Test(4) {
    my $res1 = test::Operation::Response::Response->new;
    my $res2 = test::Operation::Response::Response->new;
    
    $res1->merge_response($res2);
    is $res1->error, undef;
    is $res1->code, undef;
    is $res1->msgid, undef;
    ok $res1->is_success;
}

sub _merge_error_empty : Test(4) {
    my $res1 = test::Operation::Response::Response->new;
    my $res2 = test::Operation::Response::Response->new;
    $res1->set_error('error1');
    
    $res1->merge_response($res2);
    is $res1->error, 1;
    is $res1->code, 10_107999001;
    is $res1->msgid, 'response.test.error1';
    ok $res1->is_error;
}

sub _mk_classdata : Test(6) {
    {
        package test::response::classdata;
        use base qw(Operation::Response);
        __PACKAGE__->mk_classdata(hoge => 123);
        __PACKAGE__->mk_classdata('fuga');
    }
    {
        package test::response::classdata2;
        use base qw(Operation::Response);
        __PACKAGE__->mk_classdata(fuga => 31);
    }

    is +test::response::classdata->hoge, 123;
    is +test::response::classdata->fuga, undef;
    test::response::classdata->fuga("aa");
    is +test::response::classdata->fuga, "aa";
    test::response::classdata->hoge("aa1");
    is +test::response::classdata->hoge, "aa1";

    is +test::response::classdata2->fuga, 31;
    eval {
        test::response::classdata2->hoge;
        ok 0;
    } or do {
        ok 1;
    };
}

sub _mk_accessors : Test(6) {
    {
        package test::response::accessors;
        use base qw(Operation::Response);

        __PACKAGE__->mk_accessors(qw(ab ss));
        __PACKAGE__->mk_accessors('f');
    }

    my $res = test::response::accessors->new;
    is $res->ab, undef;
    $res->ab(464);
    is $res->ab, 464;
    $res->ab(0);
    is $res->ab, 0;

    $res->f('');
    is $res->f, '';

    my $res2 = test::response::accessors->new;
    is $res2->f, undef;
    $res2->f(343);
    is $res2->f, 343;
} # _mk_accessors

sub _as_jsonable_not_error : Test(2) {
    my $res = test::Operation::Response::Response->new;
    is_deeply $res->as_jsonable, {};
    is_deeply $res->TO_JSON, $res->as_jsonable;
}

sub _as_jsonable_is_error : Test(2) {
    my $res = test::Operation::Response::Response->new;
    $res->set_error('error1');
    is_deeply $res->as_jsonable, {
        is_error => 1,
        error_code => 10107999001,
        error_msgid => 'response.test.error1',
    };
    is_deeply $res->TO_JSON, $res->as_jsonable;
}

__PACKAGE__->runtests;

1;
