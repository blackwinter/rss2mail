# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{rss2mail}
  s.version = "0.0.9"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = [%q{Jens Wille}]
  s.date = %q{2011-05-24}
  s.description = %q{Send RSS feeds as e-mail}
  s.email = %q{ww@blackwinter.de}
  s.executables = [%q{rss2mail}]
  s.extra_rdoc_files = [%q{README}, %q{COPYING}, %q{ChangeLog}]
  s.files = [%q{lib/rss2mail.rb}, %q{lib/rss2mail/util.rb}, %q{lib/rss2mail/feed.rb}, %q{lib/rss2mail/version.rb}, %q{lib/rss2mail/rss.rb}, %q{bin/rss2mail}, %q{templates/plain.erb}, %q{templates/html.erb}, %q{README}, %q{ChangeLog}, %q{Rakefile}, %q{COPYING}, %q{example/feeds.yaml}]
  s.homepage = %q{http://rss2mail.rubyforge.org/}
  s.rdoc_options = [%q{--main}, %q{README}, %q{--charset}, %q{UTF-8}, %q{--title}, %q{rss2mail Application documentation (v0.0.9)}, %q{--all}, %q{--line-numbers}]
  s.require_paths = [%q{lib}]
  s.rubyforge_project = %q{rss2mail}
  s.rubygems_version = %q{1.8.3}
  s.summary = %q{Send RSS feeds as e-mail}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<simple-rss>, [">= 0"])
      s.add_runtime_dependency(%q<hpricot>, [">= 0"])
      s.add_runtime_dependency(%q<unidecode>, [">= 0"])
      s.add_runtime_dependency(%q<ruby-nuggets>, [">= 0"])
    else
      s.add_dependency(%q<simple-rss>, [">= 0"])
      s.add_dependency(%q<hpricot>, [">= 0"])
      s.add_dependency(%q<unidecode>, [">= 0"])
      s.add_dependency(%q<ruby-nuggets>, [">= 0"])
    end
  else
    s.add_dependency(%q<simple-rss>, [">= 0"])
    s.add_dependency(%q<hpricot>, [">= 0"])
    s.add_dependency(%q<unidecode>, [">= 0"])
    s.add_dependency(%q<ruby-nuggets>, [">= 0"])
  end
end
