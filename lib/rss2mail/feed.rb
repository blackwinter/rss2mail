#--
###############################################################################
#                                                                             #
# A component of rss2mail, the RSS to e-mail forwarder.                       #
#                                                                             #
# Copyright (C) 2007-2011 Jens Wille                                          #
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
require 'nuggets/file/which'
require 'nuggets/string/evaluate'

require 'rss2mail/rss'

module RSS2Mail

  class Feed

    HOST = ENV['HOSTNAME'] || ENV['HOST'] || %x{hostname}.chomp

    attr_reader :feed, :reload, :verbose, :debug, :simple, :updated, :content, :rss

    def initialize(feed, options = {})
      raise TypeError, "Hash expected, got #{feed.class}" unless feed.is_a?(Hash)

      @feed    = feed
      @simple  = feed[:simple]
      @updated = feed[:updated]

      @reload  = options[:reload]
      @verbose = options[:verbose]
      @debug   = options[:debug]

      required = [:url, :to, :title]
      required.delete_if { |i| feed.has_key?(i) }

      raise ArgumentError, "Feed incomplete: #{required.join(', ')} missing" unless required.empty?
    end

    def deliver(templates)
      unless mail_cmd = File.which(_mail_cmd = 'mail')
        raise "Mail command not found: #{_mail_cmd}"
      end

      to = [*feed[:to]]

      if to.empty?
        log 'No one to send to'
        return
      end

      unless get && parse
        log 'Nothing to send'
        return
      end

      if rss.items.empty?
        log 'No new items'
        return
      end

      content_type = feed[:content_type] || 'text/html'
      encoding     = feed[:encoding]     || 'UTF-8'

      feed[:sent] ||= []

      content_type_header = "Content-type: #{content_type}; charset=#{encoding}"

      unless template = templates[content_type[/\/(.*)/, 1]]
        log "Template not found: #{content_type}"
        return
      end

      cmd = [
        mail_cmd,
        '-e',
        "-a '#{content_type_header}'",
        "-a 'From: rss2mail@#{HOST}'",
        "-s '[#{feed[:title]}] \#{subject}'",
        *to
      ].join(' ')

      sent = 0

      rss.items.each { |item|
        title       = item.title
        link        = item.link
        description = item.description(feed[:unescape_html])
        date        = item.date
        author      = item.author
        body        = item.body(feed[:body])
        subject     = item.subject

        log "#{title} / #{date} [#{author}]", debug
        log "<#{link}>", debug

        send_mail(cmd.evaluate(binding), ERB.new(template).result(binding)) {
          feed[:sent] << link
          sent += 1
        }
      }

      # only keep the last 100 entries
      feed[:sent].uniq!
      feed[:sent].slice!(0...-100)

      log "#{sent} items sent"
      sent
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
        open(feed[:url], conditions) { |uri|
          if etag = uri.meta['etag']
            feed[:etag] = etag
          end

          if mtime = uri.last_modified
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

      @content
    end

    def parse(reload = reload)
      @rss = nil if reload

      if content && @rss ||= begin
        RSS2Mail::RSS.new(content, simple)
      rescue SimpleRSSError => err
        error err, 'while parsing feed'
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
        log 'Nothing to parse'
      end

      @rss
    end

    def send_mail(cmd, body)
      return if debug

      IO.popen(cmd, 'w') { |mail| mail.puts body }
      yield if block_given?
    rescue Errno::EPIPE => err
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
