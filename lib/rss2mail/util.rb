#--
###############################################################################
#                                                                             #
# A component of rss2mail, the RSS to e-mail forwarder.                       #
#                                                                             #
# Copyright (C) 2007-2013 Jens Wille                                          #
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

require 'uri'
require 'open-uri'
require 'hpricot'

require 'rss2mail/version'

module RSS2Mail

  module Util

    extend self

    USER_AGENT = "RSS2Mail/#{VERSION}".freeze

    FEED_RE = %r{\Aapplication/(?:atom|rss)\+xml\z}i

    # cf. <http://www.rssboard.org/rss-autodiscovery>
    def discover_feed(url, or_self = false)
      default = or_self ? url : nil

      unless url.nil? || url.empty? || url == 'about:blank'
        doc = Hpricot(open_feed(url))

        if feed_element = doc.search('//link[@rel="alternate"').find { |link|
          link[:type] =~ FEED_RE
        }
          if feed_href = feed_element[:href]
            return feed_href if feed_href =~ URI.regexp(%w[http https])

            base_href = doc.at('base')[:href] rescue url
            return URI.join(base_href, feed_href).to_s
          end
        end
      end

      default
    end

    def open_feed(url, options = {}, &block)
      open(url, options.merge('User-Agent' => USER_AGENT), &block)
    end

  end

end
