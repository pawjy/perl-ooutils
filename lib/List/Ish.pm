package List::Ish;
use strict;
use warnings;
our $VERSION = '0.04';
use Carp qw/croak/;
use List::Util ();
use List::MoreUtils ();

sub new {
    my $class = shift;
    $class = ref $class if ref $class;
    return bless $_[0] || [], $class;
}

sub push {
    my $self = shift;
    push @$self, @_;
    $self;
}

sub unshift {
    my $self = shift;
    unshift @$self, @_;
    $self;
}

sub shift {
    shift @{$_[0]};
}

sub pop {
    pop @{$_[0]};
}

sub first {
    return $_[0]->[0];
}

sub last {
    return $_[0]->[-1];
}

sub slice {
    my $self = CORE::shift;
    my ($start, $end) = @_;
    my $last = $#{$self};
    if (defined $end) {
        if ($start == 0 && $last <= $end) {
            return $self;
        } else {
            $end = $last if $last < $end;
            return $self->new([ @$self[ $start .. $end ] ]);
        }
    } elsif (defined $start && 0 < $start && $last <= $start) {
        return $self->new([]);
    } else {
        return $self;
    }
}

sub join {
    my ($self, $delimiter) = @_;
    join $delimiter, @$self;
}

sub concat {
    my ($self, $array) = @_;
    $self->push(@$array);
    $self;
}

*append = \&concat;

sub prepend {
    my ($self, $array) = @_;
    $self->unshift(@$array);
    $self;
}

sub _append_undestructive {
    my ($self, $array) = @_;
    $self->dup->push(@$array);
}

sub _prepend_undestructive {
    my ($self, $array) = @_;
    $self->dup->unshift(@$array);
}

sub each {
    my ($self, $code) = @_;
    croak "Argument must be a code" unless ref $code eq 'CODE';
    $code->($_) for @{$self->dup};
    $self;
}

sub map {
    my ($self, $code) = @_;
    croak "Argument must be a code" unless ref $code eq 'CODE';
    my @collected = CORE::map &$code, @{$self->dup};
    wantarray ? @collected : $self->new(\@collected);
}

sub grep {
    my ($self, $code) = @_;
    $code or return;
    my @grepped;
    if (!ref($code)) {
        for (@$self) {
            if (ref($_) eq 'HASH') {
                CORE::push @grepped, $_ if $_->{$code};
            } else {
                CORE::push @grepped, $_ if $_->$code;
            }
        }
    } elsif (ref $code eq 'CODE') {
        @grepped = CORE::grep &$code, @$self;
    } else {
        croak "Invalid code";
    }
    wantarray ? @grepped : $self->new(\@grepped);
}

sub find {
    my ($self, $cond) = @_;
    my $code = (ref $cond and ref $cond eq 'CODE')
        ? $cond
        : sub { $_ eq $cond };

    for (@$self) { &$code and return $_ }
    return;
}

sub sort {
    my ($self, $code) = @_;
    my @sorted = $code ? CORE::sort { $code->($a, $b) } @$self : CORE::sort @$self;
    wantarray ? @sorted : $self->new(\@sorted);
}

sub sort_by {
    my ($self, $code, $cmp) = @_;

    my @sorted = $cmp ?
        CORE::map { $_->[1] } CORE::sort { $cmp->($a->[0], $b->[0]) } CORE::map { [$code->($_), $_] } @$self :
        CORE::map { $_->[1] } CORE::sort { $a->[0] <=> $b->[0] } CORE::map { [$code->($_), $_] } @$self;

    wantarray ? @sorted : $self->new(\@sorted);
}

sub length {
    scalar @{$_[0]};
}

*size = \&length;

sub uniq {
    my $self = CORE::shift;
    $self->new([ List::MoreUtils::uniq(@$self) ]);
}

sub to_a {
    my @unblessed = @{$_[0]};
    \@unblessed;
}

sub dup {
    __PACKAGE__->new($_[0]->to_a);
}

sub reverse {
    my $self = CORE::shift;
    $self->new([ reverse @$self ]);
}

1;

__END__

=head1 NAME

List::Rubyish - Array iterator like the Ruby

=head1 SYNOPSIS

  my $array_ref = [
    {name => 'jkondo'},
    {name => 'cinnamon'}
  ];
  my $list = List::Rubyish->new($array_ref);

  $list->size;              #=> 2
  my $first = $list->shift; #=> {name => 'jkondo'}
  $list->push($first);      #=> [{name => 'cinnamon'}, {name => 'jkondo'}];

  # List::Rubyish provides much more useful methods. For more
  # details, see the sections below.

=head1 OVERVIEW

L<DBIx::MoCo::List> is very useful, However installation is complex.

List::Rubyish was made in order to enable use of L<DBIx::MoCo::List> independently.

=head1 METHODS

=over 4

=item dump ()

Dump the content of C<$self> using L<Data::Dumper>.

=item push ( I<@array> )

=item unshift ( I<@array> )

Sets the argument into C<$self>, a refernce to an array blessed by
List::Rubyish, like the same name functions provided by Perl core,
then returns a List::Rubyish object.

  my $list = List::Rubyish->new([qw(1 2 3)]);
  $list->push(4, 5); #=> [1, 2, 3, 4, 5]
  $list->unshift(0); #=> [0, 1, 2, 3, 4, 5]

=item concat ( I<\@array> )

=item prepend ( I<\@array> )

They're almost the same as C<push()>/C<unshift()> described above
except that the argument shoud be a reference to an array.

  my $list = List::Rubyish->new([1, 2, 3]);
  $list->concat([4, 5]); #=> [1, 2, 3, 4, 5]
  $list->prepend([0]);   #=> [0, 1, 2, 3, 4, 5]

=item shift ()

=item pop ()

Pulls out the first/last element from C<$self>, a refernce to an array
blessed by List::Rubyish, then returns it like the same name
functions in Perl core.

  $list = List::Rubyish->new([1, 2, 3]);
  $list->shift; #=> 1
  $list->pop;   #=> 3
  $list->dump   #=> [2]

=item first ()

=item last ()

Returns the first/last element of C<$self>, a refernce to an array
blessed by List::Rubyish. These methods aren't destructive contrary
to C<shift()>/C<pop()> method.

  $list = List::Rubyish->new([1, 2, 3]);
  $list->first; #=> 1
  $list->last;  #=> 3
  $list->dump   #=> [1, 2, 3]

=item slice ( I<$start>, I<$end> )

Returns the elements whose indexes are between C<$start> and C<$end>
as a List::Rubyish object.

  $list = List::Rubyish->new([qw(1 2 3 4)]);
  $list->slice(1, 2) #=> [2, 3]

=item zip ( I<\@array1>, I<\@array2>, ... )

Bundles up the elements in each arguments into an array or a
List::Rubyish object along with the context.

  my $list = List::Rubyish->new([1, 2, 3]);
  $list->zip([4, 5, 6], [7, 8, 9]);
      #=> [[1, 4, 7], [2, 5, 8], [3, 6, 9]]

  # When the numbers of each list are different...
  $list = List::Rubyish->new([1, 2, 3]);
  $list->zip([4, 5], [7, 8, 9]);
      #=> [[1, 4, 7], [2, 5, 8], [3, undef, 9]]

  my $list   = List::Rubyish->new([1, 2]);
  $list->zip([4, 5], [7, 8, 9]);
      #=> [[1, 4, 7], [2, 5, 8]]

=item delete ( I<$value>, I<$code> )

Deletes the same values as C<$value> in C<$self>, a refernce to an
array blessed by List::Rubyish, and returns the value if found. If
the value is not found in C<$self> and C<$code> is passed in, the code
is executed using the value as an argument to find the value to be
deleted.

  $list = List::Rubyish->new([1, 2, 3, 2, 1]);
  $list->delete(2); #=> 2
  $list->dump       #=> [1, 3, 1]

=item delete_at ( I<$pos> )

Deletes the element at C<$pos> and returns it.

  $list = List::Rubyish->new([1, 2, 3, 2, 1]);
  $list->delete_at(3); #=> 2
  $list->dump          #=> [1, 2, 3, 1]

=item delete_if ( I<$code> )

Deletes the elements if C<$code> returns true value with each element
as an argument.

  $list = List::Rubyish->new([1, 2, 3, 4]);
  $list->delete_if(sub { ($_ % 2) == 0) });
  $list->dump #=> [1, 3]

=item inject ( I<$result>, I<$code> )

Executes folding calculation using C<$code> through each element and
returns the result.

  $list = List::Rubyish->new([1, 2, 3, 4]);
  $list->inject(0, sub { $_[0] + $_[1] }); #=> 10

=item join ( I<$delimiter> )

Joins all the elements by C<$delimiter>.

  $list = List::Rubyish->new([0 1 2 3]);
  $list->join(', ') #=> '0, 1, 2, 3'

=item each_index ( I<$code> )

Executes C<$code> with each index of C<$self>, a refernce to an array
blessed by List::Rubyish.

  $list = List::Rubyish->new([1, 2, 3]);
  $list->each_index(sub { do_something($_) });

=item each ( I<$code> )

Executes C<$code> with each value of C<$self>, a refernce to an array
blessed by List::Rubyish.

  $list = List::Rubyish->new([1, 2, 3]);
  $list->each(sub { do_something($_) });

=item collect ( I<$code> )

Executes C<$code> with each element of C<$self>, a refernce to an
array blessed by List::Rubyish using CORE::map() and returns the
results as a list or List::Rubyish object along with the context.

  $list = List::Rubyish->new([1, 2, 3]);
  $list->map(sub { $_ * 2 }); #=> [2, 4, 6]

=item map ( I<$code> )

An alias of C<collect()> method described above.

=item grep ( I<$code> )

Executes C<$code> with each element of C<$self>, a refernce to an
array blessed by List::Rubyish using CORE::grep() and returns the
results as a list or List::Rubyish object along with the context.

  $list = List::Rubyish->new([qw(1 2 3 4)]);
  $list->grep(sub { ($_ % 2) == 0 }); #=> [2, 4]

=item find ( I<$code> )

Returns the first value found in C<$self>, a refernce to an array
blessed by List::Rubyish, as a result of C<$code>..

  $list = List::Rubyish->new([1, 2, 3, 4]);
  $list->find(sub { ($_ % 2) == 0 }); #=> 2

=item select ( I<$code> )

Returns the values found in C<$self>, a refernce to an array
blessed by List::Rubyish, as a result of C<$code>..

  $list = List::Rubyish->new([1, 2, 3, 4]);
  $list->select(sub { ($_ % 2) == 0 }); #=> 2, 4

=item index_of ( I<$arg> )

Returns index of given target or given code returns true.

  $list = List::Rubyish->new([qw(foo bar baz)]);
  $list->index_of('bar');                  #=> 1
  $list->index_of(sub { shift eq 'bar' }); #=> 1

=item sort ( I<$code> )

Sorts out each element and returns the result as a list or
List::Rubyish object along with the context.

  $list = List::Rubyish->new([qw(3 2 4 1]);
  $list->sort;                          #=> [1, 2, 3, 4]
  $list->sort(sub { $_[1] <=> $_[0] }); #=> [4, 3, 2, 1]

=item sort_by ( I<$code>, I<$cmp> )

Sorts out each element with Schwartzian transform returns the result as a list or
List::Rubyish object along with the context.

  $list = List::Rubyish->new([ [3], [2], [4], [1]]);
  $list->sort_by(sub { $_->[0] }); #=> [[1], [2], [3], [4]]
  $list->sort_by(sub { $_->[0] }, sub { $_[1} <=> $_[0] } ); #=> [[4], [3], [2], [1]]

=item compact ()

Eliminates undefined values in C<$self>, a refernce to an array
blessed by List::Rubyish.

  $list = List::Rubyish->new([1, 2, undef, 3, undef, 4]);
  $list->compact; #=> [1, 2, 3, 4]

=item length ()

Returns the length of C<$self>, a refernce to an array blessed by
List::Rubyish.

  $list = List::Rubyish->new([qw(1 2 3 4)]);
  $list->length; #=> 4

=item size ()

An alias of C<length()> method described above.

=item flatten ()

Returns a list or List::Rubyish object which is recursively
flattened out.

  $list = List::Rubyish->new([1, [2, 3, [4], 5]]);
  $list->flattern; #=> [1, 2, 3, 4, 5]

=item is_empty ()

Returns true if C<$self>, a refernce to an array blessed by
List::Rubyish, is empty.

=item uniq ()

Uniquifies the elements in C<$self>, a refernce to an array blessed by
List::Rubyish, and returns the result.

  $list = List::Rubyish->new([1, 2, 2, 3, 3, 4])
  $list->uniq; #=> [1, 2, 3, 4]

=item reduce ( I<$code> )

Reduces the list by C<$code>.

  # finds the maximum value
  $list = List::Rubyish->new([4, 1, 3, 2])
  $list->reduce(sub { $_[0] > $_[1] ? $_[0] : $_[1] }); #=> 4

See L<List::Util> to get to know about details of C<reduce()>.

=item reverse ()

Returns an reversely ordered C<$self>, a refernce to an array blessed
by List::Rubyish.

  $list = List::Rubyish->new([4, 1, 3, 2])
  $list->reverse; #=> [2, 3, 1, 4]

=item dup ()

Returns a duplicated C<$self>, a refernce to an array blessed by
List::Rubyish.

=item sum ()

Returns the sum of each element in C<$self>, a refernce to an array
blessed by List::Rubyish.

  $list = List::Rubyish->new([1, 2, 3, 4]);
  $list->sum; #=> 10

=back

=head1 SEE ALSO

L<DBIx::MoCo::List>, L<List::Util>, L<List::MoreUtils>, L<http://github.com/naoya/list-rubylike>, L<http://d.hatena.ne.jp/naoya/20080419/1208579525>, L<http://www.ruby-lang.org/ja/man/html/Enumerable.html>

=head1 AUTHOR

Junya Kondo, E<lt>jkondo@hatena.comE<gt>,
Naoya Ito, E<lt>naoya@hatena.ne.jpE<gt>,
Kentaro Kuribayashi, E<lt>kentarok@gmail.comE<gt>,
Yuichi Tateno, E<lt>secondlife at hatena ne jp<gt>,

Kazuhiro Osawa E<lt>yappo <at> shibuya <döt> plE<gt>

=head2 thanks to

naoya, kentaro, tokuhirom, kan, lopnor

=head1 REPOSITORY

  svn co http://svn.coderepos.org/share/lang/perl/List-Rubyish/trunk List-Rubyish

List::Rubyish is Subversion repository is hosted at L<http://coderepos.org/share/>.
patches and collaborators are welcome.

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 DBIx::MoCo::List's COPYRIGHT

Copyright (C) Hatena Inc. All  Rights  Reserved.

=cut
