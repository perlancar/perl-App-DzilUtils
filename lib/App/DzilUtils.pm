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
        words => Complete::Module::complete_module(
            word      => $word,
            ns_prefix => $ns_prefix,
            find_pmc  => 0,
            find_pod  => 0,
            separator => $sep,
            ci        => 1, # convenience
        ),
        path_sep => $sep,
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

This distribution provides the following command-line utilities:

 list-dzil-bundle-contents
 list-dzil-bundles
 list-dzil-plugin-roles
 list-dzil-plugins

Bash tab completion is available. To activate, put this in your shell script
startup:

 complete -C list-dzil-bundle-contents list-dzil-bundle-contents
 complete -C list-dzil-bundles         list-dzil-bundles
 complete -C list-dzil-plugin-roles    list-dzil-plugin-roles
 complete -C list-dzil-plugins         list-dzil-plugins

Check back often, there will be more utilities added.


=head1 FAQ

=head2 In shell completion, why do you use / (slash) instead of :: (double colon) as it should be?

If you type module name which doesn't contain any ::, / will be used as
namespace separator. Otherwise if you already type ::, it will use ::.

Colon is problematic because by default it is a word breaking character in bash.
This means, in this command:

 % list-dzil-bundle-contents Author:<tab>

bash is completing a new word (empty string), and in this:

 % list-dzil-bundle-contents Author::SHARYAN<tab>

bash is completing C<SHARYAN> instead of what we want C<Author::SHARYAN>.

The solution is to use quotes, e.g.

 % list-dzil-bundle-contents "Author::SHARYAN<tab>
 % list-dzil-bundle-contents 'Author::SHARYAN<tab>

or, use /:

 % list-dzil-bundle-contents author/sharyan<tab>

Note that most completion are made case-insensitive for convenience.

=cut
