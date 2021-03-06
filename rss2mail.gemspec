# -*- encoding: utf-8 -*-
# stub: rss2mail 0.4.6 ruby lib

Gem::Specification.new do |s|
  s.name = "rss2mail"
  s.version = "0.4.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Jens Wille"]
  s.date = "2015-08-14"
  s.description = "Send RSS feeds as e-mail"
  s.email = "jens.wille@gmail.com"
  s.executables = ["rss2mail"]
  s.extra_rdoc_files = ["README", "COPYING", "ChangeLog"]
  s.files = ["COPYING", "ChangeLog", "README", "Rakefile", "bin/rss2mail", "example/config.ru", "example/feeds.yaml", "lib/rss2mail.rb", "lib/rss2mail/app.rb", "lib/rss2mail/cli.rb", "lib/rss2mail/feed.rb", "lib/rss2mail/rss.rb", "lib/rss2mail/transport.rb", "lib/rss2mail/util.rb", "lib/rss2mail/version.rb", "templates/html.erb", "templates/plain.erb"]
  s.homepage = "http://github.com/blackwinter/rss2mail"
  s.licenses = ["AGPL-3.0"]
  s.rdoc_options = ["--title", "rss2mail Application documentation (v0.4.6)", "--charset", "UTF-8", "--line-numbers", "--all", "--main", "README"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.3")
  s.rubygems_version = "2.4.8"
  s.summary = "Send RSS feeds as e-mail"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<cyclops>, [">= 0"])
      s.add_runtime_dependency(%q<nokogiri>, [">= 0"])
      s.add_runtime_dependency(%q<nuggets>, [">= 0"])
      s.add_runtime_dependency(%q<simple-rss>, [">= 0"])
      s.add_runtime_dependency(%q<sinatra>, [">= 0"])
      s.add_runtime_dependency(%q<unidecoder>, [">= 0"])
      s.add_runtime_dependency(%q<safe_yaml-store>, ["~> 0.0"])
      s.add_development_dependency(%q<hen>, [">= 0.8.3", "~> 0.8"])
      s.add_development_dependency(%q<rake>, [">= 0"])
    else
      s.add_dependency(%q<cyclops>, [">= 0"])
      s.add_dependency(%q<nokogiri>, [">= 0"])
      s.add_dependency(%q<nuggets>, [">= 0"])
      s.add_dependency(%q<simple-rss>, [">= 0"])
      s.add_dependency(%q<sinatra>, [">= 0"])
      s.add_dependency(%q<unidecoder>, [">= 0"])
      s.add_dependency(%q<safe_yaml-store>, ["~> 0.0"])
      s.add_dependency(%q<hen>, [">= 0.8.3", "~> 0.8"])
      s.add_dependency(%q<rake>, [">= 0"])
    end
  else
    s.add_dependency(%q<cyclops>, [">= 0"])
    s.add_dependency(%q<nokogiri>, [">= 0"])
    s.add_dependency(%q<nuggets>, [">= 0"])
    s.add_dependency(%q<simple-rss>, [">= 0"])
    s.add_dependency(%q<sinatra>, [">= 0"])
    s.add_dependency(%q<unidecoder>, [">= 0"])
    s.add_dependency(%q<safe_yaml-store>, ["~> 0.0"])
    s.add_dependency(%q<hen>, [">= 0.8.3", "~> 0.8"])
    s.add_dependency(%q<rake>, [">= 0"])
  end
end
