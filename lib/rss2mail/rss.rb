# encoding: utf-8

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

require 'rss'
require 'nokogiri'
require 'unidecoder'
require 'simple-rss'
require 'nuggets/i18n'

module RSS2Mail

  class RSS

    include Util

    SUB = {
      '–'     => '--',
      '«'     => '<<',
      '&amp;' => '&'
    }

    SUB_RE = Regexp.union(*SUB.keys)

    KEEP = %w[a p br h1 h2 h3 h4]

    class << self

      def parse(url, *args)
        new(open_feed(url), *args)
      end

      def feed(*args)
        new(*args)
      rescue ::SimpleRSSError, ::RSS::NotWellFormedError => err
        yield err if block_given?
      end

    end

    def initialize(content, simple = false)
      @content = content
      @simple  = simple

      @rss = simple ? simple_parse : parse
    end

    attr_reader :content, :rss

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

      include Util

      def initialize(item)
        @item = item
      end

      def title
        @title ||= value_for(:title, :content)
      end

      def link
        @link ||= value_for([:links, :link], :href) { |field, value|
          field == :links ? value.find { |link| link.rel == 'alternate' } : value
        }
      end

      def description(unescape_html = false)
        @description ||= get_description(unescape_html)
      end

      def date
        @date ||= value_for({ :date => %w[pubDate updated dc_date] }, :content) { |field, value|
          field == 'updated' && value.respond_to?(:content) ? Time.at(value.content.to_i) : value
        }
      end

      def author
        @author ||= value_for({ :author => %w[contributor dc_creator] }, %w[name content])
      end

      def body(tag = nil, encoding = nil)
        @body ||= get_body(tag, encoding)
      end

      def subject
        @subject ||= title ? clean_subject(title.dup) : 'NO TITLE'
      end

      private

      def value_for(field, methods = nil, &block)
        value = get_value_for(field, &block)

        if methods
          [*methods].each { |method|
            break unless value.respond_to?(method)
            value = value.send(method)
          }
        end

        value.respond_to?(:strip) ? value.strip : value
      end

      def get_value_for(fields, &block)
        fields = fields.is_a?(Hash) ? fields.to_a.flatten : [*fields]

        fields.each { |field|
          begin
            value = @item.send(field)
            value = block[field, value] if block
            return value if value
          rescue NoMethodError
          end
        }

        nil
      end

      def get_description(unescape_html)
        description = value_for({ :description => %w[summary content] }, :content)

        if description && unescape_html
          description.gsub!(/&lt;/, '<')
          description.gsub!(/&gt;/, '>')
        end

        description
      end

      def get_body(tag, encoding)
        body = case tag
          when nil    then return
          when true   then open_feed(link).read
          when String then extract_body(tag)
          when Array  then extract_body(*tag)
          else raise ArgumentError, "don't know how to handle tag of type #{tag.class}"
        end

        body.gsub!(/<\/?(.*?)>/) { |m| m if KEEP.include?($1.split.first.downcase) }
        body.gsub!(/<a\s+href=['"](?!http:).*?>(.*?)<\/a>/mi, '\1')

        body.encode!(encoding) if encoding
        body
      rescue OpenURI::HTTPError, EOFError
      end

      def extract_body(expr, attribute = nil)
        elem = Nokogiri.HTML(open_feed(link)).at(expr)
        attribute ? elem[attribute] : elem.to_s
      end

      def clean_subject(str)
        str.replace_diacritics!
        str.gsub!(SUB_RE) { |m| SUB[m] }
        str.to_ascii
      end

    end

  end

end
