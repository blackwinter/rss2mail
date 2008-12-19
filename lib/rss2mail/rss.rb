#--
###############################################################################
#                                                                             #
# A component of rss2mail, the RSS to e-mail forwarder.                       #
#                                                                             #
# Copyright (C) 2007-2008 Jens Wille                                          #
#                                                                             #
# Authors:                                                                    #
#     Jens Wille <ww@blackwinter.de>                                          #
#                                                                             #
# rss2mail is free software; you can redistribute it and/or modify it under   #
# the terms of the GNU General Public License as published by the Free        #
# Software Foundation; either version 3 of the License, or (at your option)   #
# any later version.                                                          #
#                                                                             #
# rss2mail is distributed in the hope that it will be useful, but WITHOUT ANY #
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS   #
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more       #
# details.                                                                    #
#                                                                             #
# You should have received a copy of the GNU General Public License along     #
# with rss2mail. If not, see <http://www.gnu.org/licenses/>.                  #
#                                                                             #
###############################################################################
#++

require 'rss'

require 'rubygems'
require 'simple-rss'

module RSS2Mail

  class RSS

    attr_reader :content, :rss

    def initialize(content, simple = false)
      @content = content
      @simple  = simple

      @rss = simple ? simple_parse : parse
    end

    def simple?
      @simple
    end

    def items
      @items ||= rss.items.map { |item| Item.new(item) }
    end

    def parse
      ::RSS::Parser.parse(content, false) || simple_parse
    end

    def simple_parse
      SimpleRSS.parse(content)
    end

    class Item

      ALIASES = {
        :title       => %w[],
        :link        => %w[],
        :description => %w[summary content],
        :date        => %w[pubDate updated],
        :author      => %w[dc_creator]
      }

      def initialize(item)
        @item = item
      end

      def method_missing(method, *args, &block)
        if aliases = ALIASES[method]
          [method, *aliases].each { |name|
            begin
              res = @item.send(name)
              return res if res
            rescue NoMethodError
            end
          }

          nil
        else
          super
        end
      end

    end

  end

end
