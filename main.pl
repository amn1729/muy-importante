#!/usr/bin/env perl

use strict;
use warnings;

my @reacts      = ();
my @muis        = ();
my @icons       = ();
my @others      = ();
my @local_pacs  = ();
my @local_files = ();
my @screens     = ();

my @LOCAL_DIRS = (
    "components",
    "helpers",
    "hooks",
    "services",
    "time-fns",
    # "screens",
    "store",
    );

sub naturally { # Minimal natural sort (could fail in some cases)
    my ($A, $B) = ($a, $b);
    $A =~ s/\/\/ //;
    $B =~ s/\/\/ //;
    my ($digit_a) = $A =~ /(\d+)/;
    my ($digit_b) = $B =~ /(\d+)/;
    $digit_a ||= -1;
    $digit_b ||= -1;
    return ($A cmp $B) if ($digit_a * $digit_b < 0 || $digit_a + $digit_b < 0);
    return $digit_a <=> $digit_b;
}

sub hierarchically {
    my ($A, $B) = ($a, $b);
    $A =~ s/\.\.\//.\/..\//;
    $B =~ s/\.\.\//.\/..\//;
    my $a_depth = $A =~ tr[/][];
    my $b_depth = $B =~ tr[/][];
    return $b_depth <=> $a_depth;
}

sub print_imports {
    my ($arr_ref, $comment) = @_;
    return unless (@$arr_ref);
    print "\n// $comment imports\n" if ($comment);
    print join "\n", @$arr_ref;
    print "\n";
}

sub main {
    my $last_line_valid = 1;
    my $rest = "";

    while (<>) {
        next unless ($_);
        if ($_ eq "\n") {
            $rest .= $_;
            next;
        }
        my $line = $_;
        chomp($_);
        my $curr_line_valid = $_ =~ m/^(\/\/|import)/;

        unless ($curr_line_valid && $last_line_valid) {
            $rest .= $line;
            $last_line_valid = 0;
            next;
        }

        next unless ($_);
        my ($module, $from) = $_ =~ m/.*?import (.*?) from "(.*)"/;
        next unless ($from);

        if ($from eq "react") {
            push(@reacts, $_);
        } elsif ($module =~ m/Icon\b/) {
            push(@icons, $_);
        } elsif ($from =~ m/\@mui/) {
            push(@muis, $_);
        } elsif (grep(/$from/, @LOCAL_DIRS)) {
            push(@local_pacs, $_);
        } elsif ($from =~ m/^screens.*/) {
            push(@screens, $_);
        } elsif ($from =~ m/(\.\/|\.\.\/)/) {
            push(@local_files, $_);
        } else {
            push(@others, $_);
        }
    }

    @reacts  = sort naturally @reacts;
    @muis = sort naturally @muis;
    @icons = sort naturally @icons;
    @others = sort naturally @others;
    @local_pacs = sort naturally @local_pacs;
    @screens = sort hierarchically @screens;
    @local_files = sort hierarchically @local_files;

    print_imports(\@reacts);
    print_imports(\@muis);
    print_imports(\@icons, "icons");
    print_imports(\@others, "others");
    print_imports(\@local_pacs, "local");
    print_imports(\@screens);
    print_imports(\@local_files);

    $rest =~ s/^\n+/\n/;
    print $rest;
}

main()
