require File.expand_path(%q{../lib/rss2mail/version}, __FILE__)

begin
  require 'hen'

  Hen.lay! {{
    :rubyforge => {
      :project => %q{rss2mail}
    },

    :gem => {
      :version      => RSS2Mail::VERSION,
      :summary      => %q{Send RSS feeds as e-mail},
      :author       => %q{Jens Wille},
      :email        => %q{ww@blackwinter.de},
      :extra_files  => FileList['templates/*'].to_a,
      :dependencies => %w[simple-rss hpricot unidecode ruby-nuggets]
    }
  }}
rescue LoadError => err
  warn "Please install the `hen' gem. (#{err})"
end
