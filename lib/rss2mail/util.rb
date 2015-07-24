#--
###############################################################################
#                                                                             #
# A component of rss2mail, the RSS to e-mail forwarder.                       #
#                                                                             #
# Copyright (C) 2007-2015 Jens Wille                                          #
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

require 'safe_yaml/store'
require 'open-uri'
require 'nokogiri'

require 'rss2mail/version'

module RSS2Mail

  module Util

    extend self

    USER_AGENT = "RSS2Mail/#{VERSION}".freeze

    FEED_RE = %r{\Aapplication/(?:atom|rss)\+xml\z}i

    URI_RE = URI.regexp(%w[http https])

    ALTERNATE_XPATH = '//link[@rel="alternate"]'

    FACEBOOK_XPATH = '//div[starts-with(@id, "PageAuxContentPagelet_")]'

    FACEBOOK_FEED = 'https://www.facebook.com/feeds/page.php?format=atom10&id='

    # cf. <http://www.rssboard.org/rss-autodiscovery>
    def discover_feed(url, fallback = false)
      unless url.nil? || url.empty? || url == 'about:blank'
        load_feed(url) { |doc|
          doc.xpath(ALTERNATE_XPATH).each { |link|
            if link[:type] =~ FEED_RE && href = link[:href]
              return href =~ URI_RE ? href : begin
                base = doc.at_xpath('//base')
                URI.join(base && base[:href] || url, href).to_s
              end
            end
          }

          doc.xpath(FACEBOOK_XPATH).each { |node|
            return FACEBOOK_FEED + node[:id][/\d+/]
          } if url.include?('facebook.com')
        }
      end

      url if fallback
    end

    def load_feed(url)
      doc = Nokogiri.HTML(open_feed(url))
    rescue => err
      warn "Unable to load feed `#{url}': #{err} (#{err.class})"
    else
      block_given? ? yield(doc) : doc
    end

    def open_feed(url, options = {}, &block)
      open(url, options.merge('User-Agent' => USER_AGENT), &block)
    end

    def load_feeds(feeds_file, options = { deserialize_symbols: true })
      SafeYAML::Store.new(feeds_file, {}, options).tap { |store|
        def store.get(key); transaction(true) { self[key] }; end
      }
    end

    def dump_feeds(store, key, value)
      store.transaction { store[key] = value }
    end

  end

end
