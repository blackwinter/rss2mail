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

require 'open-uri'
require 'nokogiri'

require 'rss2mail/version'

module RSS2Mail

  module Util

    extend self

    USER_AGENT = "RSS2Mail/#{VERSION}".freeze

    FEED_RE = %r{\Aapplication/(?:atom|rss)\+xml\z}i

    URI_RE = URI.regexp(%w[http https])

    # cf. <http://www.rssboard.org/rss-autodiscovery>
    def discover_feed(url, or_self = false)
      unless url.nil? || url.empty? || url == 'about:blank'
        doc = Nokogiri.HTML(open_feed(url))

        if link = doc.xpath('//link[@rel="alternate"]').find { |i| i[:type] =~ FEED_RE }
          if href = link[:href]
            return href =~ URI_RE ? href :
              URI.join((base = doc.at_xpath('//base')) && base[:href] || url, href).to_s
          end
        end
      end

      url if or_self
    end

    def open_feed(url, options = {}, &block)
      open(url, options.merge('User-Agent' => USER_AGENT), &block)
    end

  end

end
