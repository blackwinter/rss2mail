# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "rss2mail"
  s.version = "0.1.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jens Wille"]
  s.date = "2013-04-10"
  s.description = "Send RSS feeds as e-mail"
  s.email = "jens.wille@gmail.com"
  s.executables = ["rss2mail"]
  s.extra_rdoc_files = ["README", "COPYING", "ChangeLog"]
  s.files = ["lib/rss2mail.rb", "lib/rss2mail/feed.rb", "lib/rss2mail/rss.rb", "lib/rss2mail/util.rb", "lib/rss2mail/version.rb", "bin/rss2mail", "templates/html.erb", "templates/plain.erb", "COPYING", "ChangeLog", "README", "Rakefile", "example/feeds.yaml"]
  s.homepage = "http://github.com/blackwinter/rss2mail"
  s.rdoc_options = ["--charset", "UTF-8", "--line-numbers", "--all", "--title", "rss2mail Application documentation (v0.1.4)", "--main", "README"]
  s.require_paths = ["lib"]
  s.rubygems_version = "2.0.3"
  s.summary = "Send RSS feeds as e-mail"

  if s.respond_to? :specification_version then
    s.specification_version = 4

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
