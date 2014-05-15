require File.expand_path(%q{../lib/rss2mail/version}, __FILE__)

begin
  require 'hen'

  Hen.lay! {{
    gem: {
      name:         %q{rss2mail},
      version:      RSS2Mail::VERSION,
      summary:      %q{Send RSS feeds as e-mail},
      author:       %q{Jens Wille},
      email:        %q{jens.wille@gmail.com},
      license:      %q{AGPL-3.0},
      homepage:     :blackwinter,
      extra_files:  FileList['templates/*'].to_a,
      dependencies: %w[
        cyclops nokogiri ruby-nuggets safe_yaml
        simple-rss sinatra unidecoder
      ],

      required_ruby_version: '>= 1.9.3'
    }
  }}
rescue LoadError => err
  warn "Please install the `hen' gem. (#{err})"
end
