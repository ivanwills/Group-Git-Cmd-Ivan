package Group::Git::Cmd::Stats;

# Created on: 2013-07-07 20:48:23
# Create by:  Ivan Wills
# $Id$
# $Revision$, $HeadURL$, $Date$
# $Revision$, $Source$, $Date$

use strict;
use version;
use Moose::Role;
use Carp;
use Data::Dumper qw/Dumper/;
use English qw/ -no_match_vars /;
use DateTime::Format::Strptime qw/strptime/;
use File::chdir;
use Getopt::Alt;

our $VERSION = version->new('0.0.2');

my $strp = DateTime::Format::Strptime->new(
    pattern   => '%F %T %z',
    locale    => 'en_AU',
    time_zone => 'Australia/Sydney',
);
my $opt = Getopt::Alt->new(
    {
        helper  => 1,
        help    => __PACKAGE__,
        default => {
            bin => 'month'
        },
    },
    [
        'bin|b=s',
    ]
);
my %global;

sub stats {
    my ($self, $name) = @_;

    return unless -d $name;
    local $CWD = $name;

    $opt->process if !%{ $opt->opt || {} };

    my $cmd = qq{git log --format=format:' %h=|=%s=|=%an=|=%ci'};
    my @commits = `$cmd`;
    my %stats;

    for my $commit (@commits) {
        my ($hash, $subject, $user, $time) = split /=[|]=/, $commit;
        $time = $strp->parse_datetime($time) || die "Can't parse the time $time!\nFrom:\n$commit\n";
        my $stat = $time->clone;
        $stat->truncate( to => $opt->opt->bin );
        push @{$stats{$stat}}, {
            hash => $hash,
            subject => $subject,
            user    => $user,
            time    => $time,
        };
        $global{ $stat } ||= {};
        $global{ $stat }{count}++;
    }

    my $out = '';
    for my $stat ( sort keys %stats ) {
        $out .= sprintf "%s\t%d\n", $stat, scalar @{ $stats{$stat} };
    }

    return $out;
}

sub stats_end {
    my ($self) = @_;

    return if !%{ $opt->opt || {} };

    my $out = "\nTotal\n";

    for my $stat ( sort keys %global ) {
        $out .= sprintf "%s\t%d\n", $stat, $global{$stat}{count};
    }

    return $out;
}

1;

__END__

=head1 NAME

Group::Git::Cmd::Stats - Show stats (from git log) about all projects

=head1 VERSION

This documentation refers to Group::Git::Cmd::Stats version 0.0.2

=head1 SYNOPSIS

   group-git stats [options]

  Options:
   -b --bin[=](year|month|day|hour|minute|second)
                Put log counts into year/month/day ... groups

      --help    Show this help
      --man     Show detailed help

=head1 DESCRIPTION

=head1 SUBROUTINES/METHODS

=over 4

=item stats

Get repository stats

=item stats_end

Output the collated stats

=back

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
