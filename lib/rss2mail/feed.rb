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

require 'open-uri'
require 'erb'

require 'rubygems'
require 'hpricot'
require 'unidecode'
require 'nuggets/util/i18n'
require 'nuggets/string/evaluate'

require 'rss2mail/rss'

module RSS2Mail

  class Feed

    SUBSTITUTIONS = {
      '–'     => '--',
      '«'     => '<<',
      '&amp;' => '&'
    }

    SUBSTITUTIONS_RE = %r{Regexp.union(*SUBSTITUTIONS.keys)}o

    TAGS_TO_KEEP = %w[a p br h1 h2 h3 h4]

    attr_reader :feed, :verbose, :reload, :simple, :updated, :content, :rss

    def initialize(feed, options = {})
      raise TypeError, "Hash expected, got #{feed.class}" unless feed.is_a?(Hash)

      @feed    = feed
      @simple  = feed[:simple]
      @updated = feed[:updated]

      @verbose = options[:verbose]
      @reload  = options[:reload]

      required = [:url, :to, :title]
      required.delete_if { |i| feed.has_key?(i) }

      raise ArgumentError, "feed incomplete: #{required.join(', ')} missing" unless required.empty?
    end

    def deliver(templates)
      unless get && parse
        warn "[#{feed[:title]}] Nothing to send" if verbose
        return
      end

      if rss.items.empty?
        warn "[#{feed[:title]}] No new items" if verbose
        return
      end

      to = [*feed[:to]]
      if to.empty?
        warn "[#{feed[:title]}] No one to send to" if verbose
        return
      end

      feed_title   = feed[:title]
      content_type = feed[:content_type] || 'text/html'
      encoding     = feed[:encoding]     || 'UTF-8'

      feed[:sent] ||= []

      content_type_header = "Content-type: #{content_type}; charset=#{encoding}"

      unless template = templates[content_type[/\/(.*)/, 1]]
        warn "[#{feed[:title]}] Template not found: #{content_type}" if verbose
        return
      end

      cmd = [
        '/usr/bin/mail',
        '-e',
        "-a '#{content_type_header}'",
        "-a 'From: rss2mail@blackwinter.de'",
        "-s '[#{feed_title}] \#{subject}'",
        *to
      ].join(' ')

      sent = 0

      rss.items.each { |item|
        title       = item.title
        link        = item.link
        description = item.description
        date        = item.date
        author      = item.author

        if description && feed[:unescape_html]
          description.gsub!(/&lt;/, '<')
          description.gsub!(/&gt;/, '>')
        end

        if tag = feed[:body]
          body = case tag
            when true: open(link).read
            else       Hpricot(open(link)).at(tag).to_s
          end.gsub(/<\/?(.*?)>/) { |m|
            m if TAGS_TO_KEEP.include?($1.split.first.downcase)
          }.gsub(/<a\s+href=['"](?!http:).*?>(.*?)<\/a>/mi, '\1')

          if body_encoding = feed[:body_encoding]
            body = Iconv.conv('UTF-8', body_encoding, body)
          end
        end

        subject = title ? clean_subject(title) : 'NO TITLE'

        _cmd = cmd.evaluate(binding)

        begin
          IO.popen(_cmd, 'w') { |mail| mail.puts ERB.new(template).result(binding) }
          feed[:sent] << link
          sent += 1
        rescue Errno::EPIPE => err
          warn "[#{feed[:title]}] Error while sending mail (#{err.class}): #{_cmd}"
        end
      }

      # only keep the last 100 entries
      feed[:sent].slice!(0...-100)

      warn "[#{feed[:title]}] #{sent} items sent" if verbose
      sent
    end

    private

    def get(reload = reload)
      if reload
        @content = nil
        conditions = {}
      else
        conditions = case
          when etag  = feed[:etag]:  { 'If-None-Match'     => etag  }
          when mtime = feed[:mtime]: { 'If-Modified-Since' => mtime }
          else                         {}
        end
      end

      begin
        open(feed[:url], conditions) { |uri|
          case
            when etag  = uri.meta['etag']:  feed[:etag]    = etag
            when mtime = uri.last_modified: feed[:mtime]   = mtime.rfc822
            else                            feed[:updated] = Time.now
          end

          @content ||= uri.read
        }
      rescue OpenURI::HTTPError
        warn "[#{feed[:title]}] Feed not found or unchanged" if verbose
      rescue Timeout::Error, Errno::ETIMEDOUT, Errno::ECONNRESET => err
        warn "[#{feed[:title]}] Error while getting feed: #{err} (#{err.class})"
      end

      @content
    end

    def parse(reload = reload)
      @rss = nil if reload

      if content && @rss ||= begin
        RSS2Mail::RSS.new(content, simple)
      rescue SimpleRSSError => err
        warn "[#{feed[:title]}] Error while parsing feed: #{err} (#{err.class})"
      end
        sent = feed[:sent]

        unless reload
          @rss.items.delete_if { |item|
            if updated && date = item.date
              date <= updated
            else
              sent && sent.include?(item.link)
            end
          }
        end
      else
        warn "[#{feed[:title]}] Nothing to parse" if verbose
      end

      @rss
    end

    def clean_subject(string)
      string.
        replace_diacritics.
        gsub(SUBSTITUTIONS_RE) { |m| SUBSTITUTIONS[m] }.
        to_ascii.
        gsub(/'/, "'\\\\''")
    end

  end

end
