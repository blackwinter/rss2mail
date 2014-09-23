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

module RSS2Mail

  class Feed

    include Util

    KEEP = 100

    def initialize(feed, options = {})
      raise TypeError, "Hash expected, got #{feed.class}" unless feed.is_a?(Hash)

      required = [:url, :to, :title].delete_if { |key| feed.key?(key) }

      unless required.empty?
        raise ArgumentError, "Feed incomplete: #{required.join(', ')} missing"
      end

      @feed    = feed
      @simple  = feed[:simple]
      @updated = feed[:updated]

      @reload  = options[:reload]
      @verbose = options[:verbose]
      @debug   = options[:debug]

      klass, opt = transport_from(options)
      @transport = "#{klass.name.split('::').last} @ #{opt}"

      extend klass
    end

    attr_reader :feed, :simple, :updated,
                :reload, :verbose, :debug,
                :transport, :content, :rss

    def deliver(templates)
      check_deliver_requirements if respond_to?(:check_deliver_requirements)

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

      type = feed[:content_type] || 'text/html'

      if template = templates[type[/\/(.*)/, 1]]
        type = "Content-type: #{type}; charset=#{feed[:encoding] || 'UTF-8'}"
      else
        log "Template not found: #{type}"
        return
      end

      sent = feed[:sent] ||= []
      count, title = 0, feed[:title]

      items.each { |item|
        link, subject, body = render(feed, item, template)

        send_mail(to, "[#{title}] #{subject}", body, type) {
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

    def transport_from(options)
      if lmtp = options[:lmtp] or smtp = options[:smtp]
        klass = smtp ? Transport::SMTP : Transport::LMTP

        case @smtp = lmtp || smtp
          when Array  # ok
          when true   then @smtp = []
          when Fixnum then @smtp = [nil, @smtp]
          when String then @smtp = @smtp.split(':')
          else raise TypeError, "Array expected, got #{@smtp.class}"
        end

        host, port = @smtp.shift, @smtp.shift

        host = klass::DEFAULT_HOST if host.nil? || host.empty?
        port = klass::DEFAULT_PORT if port.nil?

        [klass, @smtp.unshift(port.to_i).unshift(host)[0, 4].join(':')]
      else
        [klass = Transport::Mail, "#{klass::CMD} = #{klass::BIN.inspect}"]
      end
    end

    def get(reload = reload())
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
          else
            feed.delete(:etag)
          end

          if mtime = begin; uri.last_modified; rescue ArgumentError; end
            feed[:mtime] = mtime.rfc822
          else
            feed.delete(:mtime)
          end

          unless etag || mtime
            feed[:updated] = Time.now
          else
            feed.delete(:updated)
          end

          @content ||= uri.read
        }

        log feed.values_at(:etag, :mtime, :updated).inspect, debug
      rescue OpenURI::HTTPError => err
        log "Feed not found or unchanged: #{err} (#{err.class})"
      rescue Exception => err
        error err, 'while getting feed'
      end

      content
    end

    def parse(reload = reload())
      @rss = nil if reload

      if content
        @rss ||= RSS.feed(content, simple) { |err|
          error err, 'while parsing feed'
        }

        if rss && !reload
          if update = updated
            rss.items.delete_if { |item| (date = item.date) && date <= update }
          end

          if sent = feed[:sent]
            set = Set.new(sent)
            rss.items.delete_if { |item| set.include?(item.link) }
          end
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

    def send_mail(*args)
      return if debug

      deliver_mail(*args)

      yield if block_given?
    rescue Exception => err
      error err, 'while sending mail', transport
    end

    def log(msg, verbose = verbose())
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
