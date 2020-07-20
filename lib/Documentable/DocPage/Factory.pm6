
use Documentable;
use Documentable::Config;
use Documentable::Utils::IO;
use Documentable::Registry;

# html generation
use Documentable::To::HTML::Wrapper;
use Documentable::DocPage::Primary;
use Documentable::DocPage::Secondary;
use Documentable::DocPage::Index;
use Documentable::Search;

class Documentable::DocPage::Factory {

   has Documentable::Config $.config;
   has Documentable::Registry $.registry;
   has Documentable::To::HTML::Wrapper $.wrapper;

    method BUILD(
        Documentable::Config :$!config,
        Documentable::Registry :$registry,
    ) {
        $!registry = $registry;
        $!wrapper = Documentable::To::HTML::Wrapper.new(:$!config);

        say "Template found at {zef-path('template/main.mustache')}" if $!registry.verbose;
    }

    method generate-home-page() {
        my $path = "{$!registry.topdir}/HomePage.pod6";
        my $pod = $!registry.load(:$path)[0];
        %(
          document => $!wrapper.render($pod, :pod-path("HomePage.pod6")),
          url => '/index'
        )
    }

    method generate-error-page() {
        my $path = "{$!registry.topdir}/404.pod6";
        my $pod = $!registry.load(:$path)[0];
        %(
          document => $!wrapper.render($pod, :pod-path("404.pod6")),
          url => '/404'
        )
    }

    method generate-primary(Documentable::Primary $doc) {
        my %pod-to-render = do given $doc.kind {
            when Kind::Type {
                Documentable::DocPage::Primary::Type.new.render($!registry, $doc.name);
            }
            when Kind::Language {
                Documentable::DocPage::Primary::Language.new.render($!registry, $doc.name);
            }
            when Kind::Programs {
                Documentable::DocPage::Primary::Programs.new.render($!registry, $doc.name);
            }
        }

        my Str $html = $!wrapper.render( %pod-to-render<document>,
                                         $doc.kind.Str,
                                         pod-path => ($doc.url),
                                        );
        return %(
            document => $html,
            url      => %pod-to-render<url>
        )
    }

    method generate-secondary(Kind $kind, Str $name) {
        my %pod-to-render = Documentable::DocPage::Secondary.new.render($!registry, $name, $kind);
        my Str $html = $!wrapper.render( %pod-to-render<document>,
                                         $kind.Str,
                                        );
        return %(
            document => $html,
            url      => %pod-to-render<url>
        )
    }

    method generate-index(Kind $kind) {
        my %pod-to-render = do given $kind {
            when Kind::Type {
                Documentable::DocPage::Index::Type.new.render($!registry);
            }
            when Kind::Language {
                my @categories = $!config.get-categories(Kind::Language);
                Documentable::DocPage::Index::Language.new.render(
                    $!registry,
                    $!config.get-kind-config(Kind::Language).sort || False,
                    @categories
                );
            }
            when Kind::Programs {
                Documentable::DocPage::Index::Programs.new.render($!registry);
            }
            when Kind::Routine {
                Documentable::DocPage::Index::Routine.new.render($!registry);
            }
        }

        my Str $html = $!wrapper.render( %pod-to-render<document>,
                                         $kind.Str,
                                        );
        return %(
            document => $html,
            url      => %pod-to-render<url>
        )
    }

    method generate-subindex(Kind $kind, $category) {
        my %pod-to-render = do given $kind {
            when Kind::Routine {
                Documentable::DocPage::SubIndex::Routine.new.render($!registry, $category);
            }
            when Kind::Type {
                Documentable::DocPage::SubIndex::Type.new.render($!registry, $category);
            }
        }

        my Str $html = $!wrapper.render( %pod-to-render<document>,
                                         $kind.Str,
                                        );
        return %(
            document => $html,
            url      => %pod-to-render<url>
        )
    }

    method generate-search-file() {
        my $search-generator = Documentable::Search.new(prefix => $.config.url-prefix );
        my @items = $search-generator.generate-entries($.registry);
        my $template-path = zef-path("template/search_template.js");
        my $template = slurp($template-path);
        $template    = $template.subst("ITEMS", @items.join(",\n"))
                                .subst("WARNING", "DO NOT EDIT generated by $?FILE:$?LINE");
        return %(
            document => $template,
            url      => "/js/search.js"
        )
    }

}