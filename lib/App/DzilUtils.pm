package App::DzilUtils;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

our $_complete_stuff = sub {
    require Complete::Module;
    my $which = shift;
    my %args = @_;

    my $word = $args{word} // '';
    my $sep = $word =~ /::/ ? '::' : '/';
    $word =~ s/\Q$sep\E/::/g;

    # convenience: allow Foo/Bar.{pm,pod,pmc}
    $word =~ s/\.(pm|pmc|pod)\z//;

    my $ns_prefix    = 'Dist::Zilla::'.
        ($which eq 'bundle' ? 'PluginBundle' :
             $which eq 'plugin' ? 'Plugin' :
                 $which eq 'role' ? 'Role' : '').'::';

    my $compres = Complete::Module::complete_module(
        word      => $word,
        ns_prefix => $ns_prefix,
        find_pmc  => 0,
        find_pod  => 0,
    );

    for (@$compres) { s/::/$sep/g }

    {
        words => $compres,
        path_sep => $sep,
    };
};

our $_complete_bundle = sub {
    $_complete_stuff->('bundle', @_);
};

our $_complete_plugin = sub {
    $_complete_stuff->('plugin', @_);
};

our $_complete_role = sub {
    $_complete_stuff->('role', @_);
};

1;
# ABSTRACT: Collection of CLI utilities for Dist::Zilla

=head1 SYNOPSIS

This distribution provides several command-line utilities related to
L<Dist::Zilla>.

=cut
