use Test;

use Documentable;
use Documentable::Config;

plan *;

throws-like { my $config = Documentable::Config.new(filename => "bad-config-1.json")},
        X::Documentable::Config::InvalidConfig,
        "Bad config, no kinds, detected",
        message => /kinds/;

throws-like { my $config = Documentable::Config.new(filename => "bad-config-2.json")},
        X::Documentable::Config::InvalidConfig,
        "Bad config, no title page, detected",
        message => /title/;

throws-like {
        my $config = Documentable::Config.new(filename => "bad-config-3.json")
    },
        X::Documentable::Config::InvalidConfig,
        "Bad config, no root, detected",
        message => /root/;

my $config = Documentable::Config.new(filename => "good-config.json");
isa-ok $config, Documentable::Config, "Config instantiated";

for <language type routine programs> -> $k {
    ok( $config.get-kind-config(Kind($k)), "Config for $k retrieved");
}

done-testing;