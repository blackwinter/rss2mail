# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{rss2mail}
  s.version = "0.0.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jens Wille"]
  s.date = %q{2011-03-28}
  s.default_executable = %q{rss2mail}
  s.description = %q{Send RSS feeds as e-mail}
  s.email = %q{ww@blackwinter.de}
  s.executables = ["rss2mail"]
  s.extra_rdoc_files = ["README", "COPYING", "ChangeLog"]
  s.files = ["lib/rss2mail.rb", "lib/rss2mail/util.rb", "lib/rss2mail/feed.rb", "lib/rss2mail/version.rb", "lib/rss2mail/rss.rb", "bin/rss2mail", "templates/plain.erb", "templates/html.erb", "README", "ChangeLog", "Rakefile", "COPYING", "example/feeds.yaml"]
  s.homepage = %q{http://rss2mail.rubyforge.org/}
  s.rdoc_options = ["--line-numbers", "--main", "README", "--all", "--charset", "UTF-8", "--title", "rss2mail Application documentation (v0.0.7)"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{rss2mail}
  s.rubygems_version = %q{1.6.2}
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
