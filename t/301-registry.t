use v6;

use Perl6::Documentable;
use Perl6::Documentable::Registry;
use Pod::Load;
use Test;

plan *;

my $registry = Perl6::Documentable::Registry.new(
    :topdir("t/test-doc"),
    :dirs(["Programs", "Native"]),
    :verbose(False)
);

$registry.compose;

subtest "Composing" => {
    is $registry.composed, True, "Composed set to True";
    is-deeply $registry.documentables.map({.name}).sort,
              ("Debugging", "Reading", "int"),
              "Composing docs";
}

subtest "Lookup by kind" => {
    is $registry.lookup(Kind::Type, by => "kind").map({.name}).sort,
       ["int"],
       "Lookup by Kind::Type";
    is $registry.lookup(Kind::Programs, by => "kind").map({.name}).sort,
       ["Debugging", "Reading"],
       "Lookup by Kind::Programs";
}

done-testing;