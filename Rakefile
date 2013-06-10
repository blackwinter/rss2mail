require File.expand_path(%q{../lib/rss2mail/version}, __FILE__)

begin
  require 'hen'

  Hen.lay! {{
    :gem => {
      :name         => %q{rss2mail},
      :version      => RSS2Mail::VERSION,
      :summary      => %q{Send RSS feeds as e-mail},
      :author       => %q{Jens Wille},
      :email        => %q{jens.wille@gmail.com},
      :homepage     => :blackwinter,
      :extra_files  => FileList['templates/*'].to_a,
      :dependencies => %w[nokogiri unidecode ruby-nuggets simple-rss sinatra]
    }
  }}
rescue LoadError => err
  warn "Please install the `hen' gem. (#{err})"
end
