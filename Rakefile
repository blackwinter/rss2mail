require_relative 'lib/rss2mail/version'

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
        cyclops nokogiri nuggets
        simple-rss sinatra unidecoder
      ] << ['safe_yaml-store', '~> 0.0'],

      required_ruby_version: '>= 1.9.3'
    }
  }}
rescue LoadError => err
  warn "Please install the `hen' gem. (#{err})"
end
