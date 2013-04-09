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

require 'erb'
require 'open3'
require 'nuggets/file/which'
require 'nuggets/string/evaluate'

module RSS2Mail

  class Feed

    include Util

    unless MAIL = File.which(mail = 'mail'.freeze)
      class << MAIL; self; end.send(:define_method, :to_s) { mail }
    end

    HOST = ENV['HOSTNAME'] || ENV['HOST'] || %x{hostname}.chomp.freeze

    FROM = "From: rss2mail@#{HOST}".freeze

    KEEP = 100

    def initialize(feed, options = {})
      raise TypeError, "Hash expected, got #{feed.class}" unless feed.is_a?(Hash)

      @feed    = feed
      @simple  = feed[:simple]
      @updated = feed[:updated]

      @reload  = options[:reload]
      @verbose = options[:verbose]
      @debug   = options[:debug]

      required = [:url, :to, :title]
      required.delete_if { |key| feed.has_key?(key) }

      unless required.empty?
        raise ArgumentError, "Feed incomplete: #{required.join(', ')} missing"
      end
    end

    attr_reader :feed, :simple, :updated,
                :reload, :verbose, :debug,
                :content, :rss

    def deliver(templates)
      raise "Mail command not found: #{MAIL}" unless MAIL

      if (to = Array(feed[:to])).empty?
        log 'No one to send to'
        return
      end

      unless get && parse
        log 'Nothing to send'
        return
      end

      if (items = rss.items).empty?
        log 'No new items'
        return
      end

      type     = feed[:content_type] || 'text/html'
      encoding = feed[:encoding]     || 'UTF-8'

      type_header = "Content-type: #{type}; charset=#{encoding}"

      unless template = templates[type[/\/(.*)/, 1]]
        log "Template not found: #{type}"
        return
      end

      sent = feed[:sent] ||= []
      count, title = 0, feed[:title]

      items.each { |item|
        link, subject, body = render(feed, item, template)

        send_mail(type_header, to, title, subject, body) {
          sent << link
          count += 1
        }
      }

      sent.uniq!
      sent.slice!(0...-KEEP)

      log "#{count} items sent"
      count
    end

    private

    def get(reload = reload)
      conditions = {}

      if reload
        @content = nil
      else
        if etag = feed[:etag]
          conditions['If-None-Match'] = etag
        end

        if mtime = feed[:mtime]
          conditions['If-Modified-Since'] = mtime
        end
      end

      log conditions.inspect, debug

      begin
        open_feed(feed[:url], conditions) { |uri|
          if etag = uri.meta['etag']
            feed[:etag] = etag
          end

          if mtime = begin; uri.last_modified; rescue ArgumentError; end
            feed[:mtime] = mtime.rfc822
          end

          unless etag || mtime
            feed[:updated] = Time.now
          end

          @content ||= uri.read
        }

        log feed.values_at(:etag, :mtime, :updated).inspect, debug
      rescue OpenURI::HTTPError
        log 'Feed not found or unchanged'
      rescue Exception => err
        error err, 'while getting feed'
      end

      content
    end

    def parse(reload = reload)
      @rss = nil if reload

      if content
        @rss ||= RSS.feed(content, simple) { |err|
          error err, 'while parsing feed'
        }

        if rss && !reload
          sent = feed[:sent]

          rss.items.delete_if { |item|
            if updated && date = item.date
              date <= updated
            elsif sent
              sent.include?(item.link)
            end
          }
        end
      else
        log 'Nothing to parse'
      end

      rss
    end

    def render(feed, item, template)
      title       = item.title
      link        = item.link
      description = item.description(feed[:unescape_html])
      date        = item.date
      author      = item.author
      body        = item.body(feed[:body])
      subject     = item.subject

      log "#{title} / #{date} [#{author}]", debug
      log "<#{link}>", debug

      [link, subject, ERB.new(template).result(binding)]
    end

    def send_mail(type_header, to, title, subject, body)
      return if debug

      Open3.popen3(MAIL, '-e', '-a', type_header, '-a', FROM,
        '-s', "[#{title}] #{subject}", *to) { |mail, _, _|
        mail.puts body
        mail.close
      }

      yield if block_given?
    rescue Errno::EPIPE, IOError => err
      error err, 'while sending mail', cmd
    end

    def log(msg, verbose = verbose)
      warn "[#{feed[:title]}] #{msg}" if verbose
    end

    def error(err = nil, occasion = nil, extra = nil)
      msg = 'Error'

      msg << " #{occasion}"            if occasion
      msg << ": #{err} (#{err.class})" if err
      msg << " [#{extra}]"             if extra

      msg = [msg, *err.backtrace].join("\n    ") if debug

      log msg, true
    end

  end

end
