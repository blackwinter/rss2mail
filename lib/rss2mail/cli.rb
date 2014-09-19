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

require 'cyclops'
require 'rss2mail'

module RSS2Mail

  class CLI < Cyclops

    class << self

      def defaults
        super.merge(
          files:   nil,
          smtp:    nil,
          lmtp:    nil,
          reload:  false,
          verbose: false,
          debug:   false
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
        unless File.readable?(feeds_file)
          warn "Feeds file not found: #{feeds_file}"
          next
        end

        feeds = Util.load_feeds(feeds_file)

        unless target_feeds = feeds.get(target)
          warn "Feeds target not found in #{feeds_file}: #{target}"
          next
        end

        target_feeds.each { |feed|
          Feed.new(feed, options).deliver(templates) unless feed[:skip]
        }

        Util.dump_feeds(feeds, target, target_feeds) unless options[:debug]
      }
    end

    private

    def opts(opts)
      opts.option(:directory__DIRECTORY, 'Process all feeds in directory') { |dir|
        quit "#{dir}: No such file or directory" unless File.directory?(dir)
        quit "#{dir}: Permission denied"         unless File.readable?(dir)

        options[:files] = Dir[File.join(dir, '*.yaml')]
      }

      opts.separator

      %w[smtp lmtp].each { |type|
        klass = Transport.const_get(type.upcase)

        opts.on("-#{type[0, 1]}", "--#{type} [HOST[:PORT]]", "Send mail through #{type.upcase} server",
                "[Default host: #{klass::DEFAULT_HOST}, default port: #{klass::DEFAULT_PORT}]") { |host|
          options[type.to_sym] = host.to_s
        }
      }

      opts.separator

      opts.switch(:reload, 'Reload feeds')
    end

    def default_files
      File.directory?(dir = DEFAULT_FEEDS_PATH) ?
        Dir[File.join(dir, '*.yaml')] : [DEFAULT_FEEDS_FILE]
    end

  end

end
