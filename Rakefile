require %q{lib/rss2mail/version}

begin
  require 'hen'

  Hen.lay! {{
    :rubyforge => {
      :project  => %q{rss2mail},
      :package  => %q{rss2mail},
      :rdoc_dir => nil
    },

    :gem => {
      :version      => RSS2Mail::VERSION,
      :summary      => %q{Send RSS feeds as e-mail},
      :homepage     => %q{http://rss2mail.rubyforge.org/},
      :files        => FileList['lib/**/*.rb', 'bin/*'].to_a,
      :extra_files  => FileList['[A-Z]*', 'example/*'].to_a,
      :dependencies => %w[simple-rss hpricot unidecode ruby-nuggets]
    }
  }}
rescue LoadError
  abort "Please install the 'hen' gem first."
end

### Place your custom Rake tasks here.
