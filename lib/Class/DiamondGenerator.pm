package Class::DiamondGenerator;
use strict;
use warnings;
use base qw(Class::Data::Inheritable);

__PACKAGE__->mk_classdata('supermost_parent_package');
__PACKAGE__->mk_classdata('child_names');

sub decamelize ($) {
    return lc join '_', grep $_, split /([A-Z]*)(?=[A-Z][a-z]|$)/, (split /::/, shift)[-1]
}

sub parent_decamelize {
    my (undef, $s) = @_;
    return decamelize $s;
}

sub child_decamelize {
    my (undef, $ps, $cs) = @_;
    $cs =~ s/^\Q$ps\E//;
    $cs =~ s/:://g;
    return decamelize $cs;
}

sub generate_missing_classes {
    my ($class, %args) = @_;
    
    my $lib_d = $args{lib_d} or die "lib_d is not specified";
    my $sub_parent_package = $args{parent_package}
        or die "parent_package is not specified";

    my $super_parent_packages = [@{ $args{super_parent_packages} || [] }];
    push @$super_parent_packages, $class->supermost_parent_package;
    
    for my $child_name (undef, @{$class->child_names}) {
        my $file_name = $sub_parent_package;
        if (defined $child_name) {
            $file_name =~ s/::Base$//;
            $file_name .= '::' . $child_name;
        }
        $file_name =~ s[::][/]g;
        $file_name .= '.pm';
        
        my $f = $lib_d->file($file_name);
        next if -f $f;

        my $file = $args{dry} ? *STDERR : do { $f->dir->mkpath; $f->openw };
        warn "$f...\n";
        print $file $class->create_module(
            $child_name,
            $sub_parent_package,
            $super_parent_packages,
        );
    }

    if (defined $args{config_package}) {
        my $file_name = $args{config_package};
        $file_name =~ s[::][/]g;
        $file_name .= '.pm';
        
        my $f = $lib_d->file($file_name);
        
        my $file = $args{dry} ? *STDERR : do { $f->dir->mkpath; $f->openw };
        warn "$f...\n";
        print $file $class->create_config_module($args{config_package}, $sub_parent_package);
    }
}

sub load_module {
    my ($class, $child_name, $_sub_parent_name) = @_;

    my @to_be_checked = ($_sub_parent_name);
    my $check_done = {};
    my @module;
    my $new_module_name;
    while (@to_be_checked) {
        my $sub_parent_name = shift @to_be_checked;
        next if $check_done->{$sub_parent_name};
        $check_done->{$sub_parent_name} = 1;
        
        no strict 'refs';
        my $super_parent_packages = [
            grep { $_ ne $sub_parent_name }
            map { my $v = $_; $v =~ s/::impl$//; $v }
            grep { /::impl$/ }
            @{$sub_parent_name . '::ISA'}
        ];
        
        my $data = $class->generate_module_data($child_name, $sub_parent_name, $super_parent_packages);

        for my $module (map { my $v = $_; $v =~ s/::impl$//; $v } @{$data->{parent_impls}}) {
            push @to_be_checked, $module;
        }

        my $this_file_name = $data->{this_package} . ".pm";
        $this_file_name =~ s[::][/]g;
        next if $INC{$this_file_name};
        if (eval qq{ require $data->{this_package} }) {
            next;
        } elsif ($@ =~ m[^Can't locate .*? in \@INC]s) {
            #
        } else {
            require Carp;
            die $@, Carp::longmess();
        }

        my $module = $class->create_module($child_name, $sub_parent_name, $super_parent_packages);
        push @module, [$module, $data->{this_package}];
        $new_module_name ||= $data->{this_package};
    }
    
    for (reverse @module) {
        my $module = $_->[0];
        my $new_file_name = $_->[1];
        
        eval $module or die $@;
        $new_file_name =~ s[::][/]g;
        $new_file_name .= '.pm';
        $INC{$new_file_name} = 1;
    }

    return $new_module_name || die "Can't load module $class, $child_name, $_sub_parent_name";
}

sub generate_module_data {
    my ($class, $child_name, $sub_parent_package, $super_parent_packages) = @_;

    my $this_package = $sub_parent_package;
    if (defined $child_name) {
        $this_package =~ s/::Base$//;
        $this_package .= '::' . $child_name;
    }

    my @child_impl;
    my @parent_impl;
    my @use;

    if (defined $child_name) {
        push @child_impl, $sub_parent_package . '::' . $child_name . '::impl';
        push @use, $sub_parent_package;
    }
    {
        push @parent_impl, $sub_parent_package . '::impl';
    }
    
    for (@$super_parent_packages) {
        my $super_parent_package = $_;
        if (defined $child_name) {
            my $super_parent_package = $super_parent_package;
            $super_parent_package =~ s/::Base$//;
            push @child_impl,
                $super_parent_package . '::' . $child_name . '::impl';
            push @use, $super_parent_package . '::' . $child_name;
        }
        {
            push @parent_impl, $super_parent_package . '::impl';
            push @use, $super_parent_package;
        }
    }

    return {
        this_package => $this_package,
        child_impls => \@child_impl,
        parent_impls => \@parent_impl,
        uses => \@use,
    };
}

sub create_module {
    my ($class, $child_name, $sub_parent_package, $super_parent_packages) = @_;

    my $data = $class->generate_module_data($child_name, $sub_parent_package, $super_parent_packages);
    
    my $r = sprintf "package %s;\nuse strict;\nuse warnings;\n", $data->{this_package};
    $r .= "use $_;\n" for @{$data->{uses}};
    $r .= sprintf "push our \@ISA, qw(\n    %s\n);\n",
        join "\n    ", @{$data->{child_impls}}, @{$data->{parent_impls}};

    unless (defined $child_name) {
        my $supermost_parent_key = $class->parent_decamelize($class->supermost_parent_package);
        $r .= qq[\nuse Class::Registry;\n];
        $r .= sprintf "Class::Registry->default(%s => __PACKAGE__);\n",
            $supermost_parent_key;
        for my $child_name (@{$class->child_names}) {
            $r .= sprintf "Class::Registry->default(%s_%s => __PACKAGE__ . '::%s');\n",
                $supermost_parent_key,
                $class->child_decamelize($class->supermost_parent_package, $child_name),
                $child_name;
        }
        $r .= qq[\n];
    }

    $r .= sprintf "\npackage %s::impl;\n\n",
        $data->{this_package};
    
    $r .= "\n1;\n";
    
    return $r;
}

sub create_config_module {
    my ($class, $config_package, $sub_parent_package) = @_;

    my $supermost_parent_key = $class->parent_decamelize($class->supermost_parent_package);
    my $r = qq[package $config_package;\nuse strict;\nuse warnings;\n\nuse Class::Registry;\n];
    $r .= sprintf "Class::Registry->set(%s => '%s');\n",
        $supermost_parent_key, $sub_parent_package;
    for my $child_name (@{$class->child_names}) {
        $r .= sprintf "Class::Registry->set(%s_%s => '%s::%s');\n",
            $supermost_parent_key,
            $class->child_decamelize($class->supermost_parent_package, $child_name),
            $sub_parent_package,
            $child_name;
    }
    $r .= qq[\n1;\n];

    return $r;
}

1;
