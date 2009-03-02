# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{rss2mail}
  s.version = "0.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jens Wille"]
  s.date = %q{2009-03-02}
  s.default_executable = %q{rss2mail}
  s.description = %q{Send RSS feeds as e-mail}
  s.email = %q{jens.wille@uni-koeln.de}
  s.executables = ["rss2mail"]
  s.extra_rdoc_files = ["COPYING", "ChangeLog", "README"]
  s.files = ["lib/rss2mail/rss.rb", "lib/rss2mail/version.rb", "lib/rss2mail/util.rb", "lib/rss2mail/feed.rb", "lib/rss2mail.rb", "bin/rss2mail", "Rakefile", "COPYING", "ChangeLog", "README", "example/feeds.yaml"]
  s.has_rdoc = true
  s.homepage = %q{http://rss2mail.rubyforge.org/}
  s.rdoc_options = ["--line-numbers", "--main", "README", "--inline-source", "--title", "rss2mail Application documentation", "--charset", "UTF-8", "--all"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{rss2mail}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Send RSS feeds as e-mail}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
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
