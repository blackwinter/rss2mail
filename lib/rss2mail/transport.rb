# encoding: utf-8

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

  module Transport

    HOST = ENV['HOSTNAME'] || ENV['HOST'] || %x{hostname}.chomp.freeze

    FROM = "From: rss2mail@#{HOST}".freeze

    module Mail

      require 'open3'
      require 'nuggets/file/which'

      CMD = ENV['RSS2MAIL_MAIL_CMD'] || 'mail'.freeze

      BIN = ENV['RSS2MAIL_MAIL_BIN'] || File.which(CMD)

      def check_deliver_requirements
        raise "Mail command not found: #{CMD}" unless BIN
      end

      def deliver_mail(to, subject, body, type)
        Open3.popen3(
          BIN, '-e',
          '-a', type,
          '-a', FROM,
          '-s', subject,
          *to
        ) { |mail, _, _|
          mail.puts body
        }
      end

    end

    module SMTP

      require 'net/smtp'
      require 'securerandom'

      def deliver_mail(to, *args)
        deliver_smtp(Net::SMTP, @smtp, [to], *args)
      end

      private

      def deliver_smtp(klass, args, to, subject, body, type)
        klass.start(*args) { |smtp|
          to.each { |_to|
            smtp.send_message(<<-EOT, FROM, *_to)
#{FROM}
To: #{Array(_to).join(', ')}
Date: #{Time.now.rfc822}
Subject: #{subject}
Message-Id: #{SecureRandom.uuid}
#{type}

#{body}
            EOT
          }
        }
      end

    end

    module LMTP

      include SMTP

      def deliver_mail(to, *args)
        deliver_smtp(Net::LMTP, @lmtp, to, *args)
      end

    end

  end

end

module Net

  class LMTP < SMTP

    # Send LMTP's LHLO command instead of SMTP's HELO command
    def helo(domain)
      getok("LHLO #{domain}")
    end

    # Send LMTP's LHLO command instead of ESMTP's EHLO command
    def ehlo(domain)
      getok("LHLO #{domain}")
    end

  end

end
