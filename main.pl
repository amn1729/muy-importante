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
    "app/Common",
    "RolesMap",
    "apis",
    "AppRoutes",
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

sub sort_module_imports {
    my $imports = shift;
    my ($default, $named) = $imports =~ m/(.*?)\{(.*?)\}/;
    my @named_imports = split ",", $named;
    @named_imports = map { $_ =~ s/^\s+|\s+$//g; $_ } @named_imports;
    @named_imports = sort naturally @named_imports;
    return $default . "{ " . (join ", ", @named_imports) . " }";
}

sub main {
    my $last_line_valid = 1;
    my $rest = "";

    my $content = "";
    while (<>) { $content .= $_ };
    $content =~ s/,\n/,/g;
    $content =~ s/(import.*?)\{\n/$1\{/g;

    for (split "\n", $content) {
        # next unless ($_);
        # if ($_ eq "\n") {
        unless ($_) {
            $rest .= "\n";
            next;
        }
        my $line = $_;
        chomp($_);
        my $curr_line_valid = $_ =~ m/^(\/\/|import)/;

        unless ($curr_line_valid && $last_line_valid) {
            $rest .= $line . "\n";
            $last_line_valid = 0;
            next;
        }

        next unless ($_);
        my ($imports, $from) = $_ =~ m/.*?import (.*?) from "(.*)"/;
        next unless ($from);

        if ($imports =~ m/.*\{.*\}.*/) {
            my $sorted_module_imports = sort_module_imports($imports);
            $_ = qq{import $sorted_module_imports from "$from";};
        }

        if ($from eq "react") {
            push(@reacts, $_);
        } elsif ($imports =~ m/Icon\b/) {
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
    print_imports(\@others, "other");
    print_imports(\@local_pacs, "local");
    print_imports(\@screens);
    print_imports(\@local_files);

    $rest =~ s/^\n+/\n/;
    print $rest;
}

main()
