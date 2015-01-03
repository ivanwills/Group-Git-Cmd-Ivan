package Group::Git::Cmd::SinceRelease;

# Created on: 2013-05-20 09:03:03
# Create by:  dev
# $Id$
# $Revision$, $HeadURL$, $Date$
# $Revision$, $Source$, $Date$

use strict;
use version;
use Moose::Role;
use Carp;
use Data::Dumper qw/Dumper/;
use English qw/ -no_match_vars /;
use File::chdir;

our $VERSION = version->new('0.0.1');

my $opt = Getopt::Alt->new(
    {
        helper  => 1,
        help    => __PACKAGE__,
        default => {
            min => 1,
        },
    },
    [
        'min|min-commits|m=i',
        'verbose|v+',
    ]
);

sub since_release {
    my ($self, $name) = @_;

    return unless -d $name;

    $opt->process if !%{ $opt->opt || {} };

    local $CWD = $name;

    # find the newest tag and count newer commits
    my @tags = map {/(.*)$/; $1} `git tag`;
    return if !@tags;

    my ($sha, $time) = split /\s+/, `git log -n 1 --format=format:'%H %at' $tags[-1]`;

    my @logs  = `git log -n 100 --format=format:'%H'`;
    my $count = -1;
    for my $log (@logs) {
        $count++;
        chomp $log;
        last if $log eq $sha;
    }

    return if $count < $opt->opt->min && !$opt->opt->verbose;
    return "Commits since last release: $count\n";
}

1;

__END__

=head1 NAME

Group::Git::Cmd::SinceRelease - Gets the number of commits each repository is ahead of the last release

=head1 VERSION

This documentation refers to Group::Git::Cmd::SinceRelease version 0.0.1

=head1 SYNOPSIS

   group-git since-release [options]

   Options:
    -m --min-commits[=]int
                    Set the minimum number of commits to be found since the
                    last release (ie tag) before the results are shown.
                    (Default 1)
    -v --verbose    Show all repository results.
       --help       Show this documentation
       --man        Show full documentation

=head1 DESCRIPTION

=head1 SUBROUTINES/METHODS

=head2 C<since_release <$name>

Calculates the number of commits since the last release (aka newest tag)

=head1 DESCRIPTION

=head1 SUBROUTINES/METHODS

=head2 C<tag ($name)>

Does the work of finding tags

=head1 DIAGNOSTICS

=head1 CONFIGURATION AND ENVIRONMENT

=head1 DEPENDENCIES

=head1 INCOMPATIBILITIES

=head1 BUGS AND LIMITATIONS

There are no known bugs in this module.

Please report problems to Ivan Wills (ivan.wills@gmail.com).

Patches are welcome.

=head1 AUTHOR

Ivan Wills - (ivan.wills@gmail.com)

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2013 Ivan Wills (14 Mullion Close, Hornsby Heights, NSW Australia 2077).
All rights reserved.

This module is free software; you can redistribute it and/or modify it under
the same terms as Perl itself. See L<perlartistic>.  This program is
distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.

=cut
