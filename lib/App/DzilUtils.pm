package App::DzilUtils;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

our $_complete_plugin_or_bundle = sub {
    require Complete::Module;
    my $which = shift;
    my %args = @_;

    my $word = $args{word} // '';

    # convenience: allow Foo/Bar.{pm,pod,pmc}
    $word =~ s/\.(pm|pmc|pod)\z//;

    # compromise, if word doesn't contain :: we use the safer separator /, but
    # if already contains '::' we use '::' (but this means in bash user needs to
    # use quote (' or ") to make completion behave as expected since : is a word
    # break character in bash/readline.
    my $sep = $word =~ /::/ ? '::' : '/';
    $word =~ s/\W+/::/g;
    my $ns_prefix    = 'Dist::Zilla::Plugin'.
        ($which eq 'bundle' ? 'Bundle':'').'::';

    {
        completion => Complete::Module::complete_module(
            word      => $word,
            ns_prefix => $ns_prefix,
            find_pmc  => 0,
            find_pod  => 0,
            separator => $sep,
            ci        => 1, # convenience
        ),
        path_sep   => $sep,
    };
};

our $_complete_plugin = sub {
    $_complete_plugin_or_bundle->('plugin', @_);
};

our $_complete_bundle = sub {
    $_complete_plugin_or_bundle->('bundle', @_);
};

1;
# ABSTRACT: Collection of CLI utilities for Dist::Zilla

=head1 SYNOPSIS

This distribution provides several command-line utilities related to
L<Dist::Zilla>.

=cut
