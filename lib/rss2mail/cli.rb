#--
###############################################################################
#                                                                             #
# A component of rss2mail, the RSS to e-mail forwarder.                       #
#                                                                             #
# Copyright (C) 2007-2014 Jens Wille                                          #
#                                                                             #
# Authors:                                                                    #
#     Jens Wille <jens.wille@gmail.com>                                       #
#                                                                             #
# rss2mail is free software; you can redistribute it and/or modify it under   #
# the terms of the GNU Affero General Public License as published by the Free #
# Software Foundation; either version 3 of the License, or (at your option)   #
# any later version.                                                          #
#                                                                             #
# rss2mail is distributed in the hope that it will be useful, but WITHOUT ANY #
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS   #
# FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for     #
# more details.                                                               #
#                                                                             #
# You should have received a copy of the GNU Affero General Public License    #
# along with rss2mail. If not, see <http://www.gnu.org/licenses/>.            #
#                                                                             #
###############################################################################
#++

require 'nuggets/cli'

require 'rss2mail'

module RSS2Mail

  class CLI < Nuggets::CLI

    class << self

      def defaults
        super.merge(
          :files   => nil,
          :smtp    => nil,
          :lmtp    => nil,
          :reload  => false,
          :verbose => false,
          :debug   => false
        )
      end

    end

    def usage
      "#{super} <target>"
    end

    def run(arguments)
      if target = arguments.shift
        target = target.to_sym
      else
        quit 'Feeds target is required!'
      end

      quit unless arguments.empty?

      templates = Hash.new { |h, k|
        h[k] = begin
          File.read(File.join(TEMPLATE_PATH, "#{k}.erb"))
        rescue Errno::ENOENT
          # silently ignore
        end
      }

      (options.delete(:files) || default_files).each { |feeds_file|
        feeds = begin
          SafeYAML.load_file(feeds_file, :deserialize_symbols => true)
        rescue Errno::ENOENT
          warn "Feeds file not found: #{feeds_file}"
          next
        end

        unless target_feeds = feeds[target]
          warn "Feeds target not found in #{feeds_file}: #{target}"
          next
        end

        target_feeds.each { |feed|
          Feed.new(feed, options).deliver(templates) unless feed[:skip]
        }

        unless options[:debug]
          File.open(feeds_file, 'w') { |file| YAML.dump(feeds, file) }
        end
      }
    end

    private

    def opts(opts)
      opts.on('-d', '--directory DIRECTORY', 'Process all feeds in directory') { |dir|
        quit "#{dir}: No such file or directory" unless File.directory?(dir)
        quit "#{dir}: Permission denied"         unless File.readable?(dir)

        options[:files] = Dir[File.join(dir, '*.yaml')]
      }

      opts.separator ''

      %w[smtp lmtp].each { |type|
        klass = Transport.const_get(type.upcase)

        opts.on("-#{type[0, 1]}", "--#{type} [HOST[:PORT]]",
                "Send mail through #{type.upcase} server",
                "[Default host: #{klass::DEFAULT_HOST}, default port: #{klass::DEFAULT_PORT}]") { |host|
          options[type.to_sym] = host.to_s
        }
      }

      opts.separator ''

      opts.on('-r', '--reload', 'Reload feeds') {
        options[:reload] = true
      }
    end

    def default_files
      File.directory?(dir = DEFAULT_FEEDS_PATH) ?
        Dir[File.join(dir, '*.yaml')] : [DEFAULT_FEEDS_FILE]
    end

  end

end
