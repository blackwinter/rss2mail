#--
###############################################################################
#                                                                             #
# rss2mail -- Send RSS feeds as e-mail                                        #
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

require 'erb'
require 'nuggets/env/user_home'

require 'rss2mail/transport'
require 'rss2mail/util'
require 'rss2mail/feed'
require 'rss2mail/rss'

module RSS2Mail

  BASE_PATH          = ENV['RSS2MAIL_BASE_PATH'] ||
    File.expand_path('../..', __FILE__)

  TEMPLATE_PATH      = ENV['RSS2MAIL_TEMPLATE_PATH'] ||
    File.join(BASE_PATH, 'templates')

  DEFAULT_FEEDS_PATH = ENV['RSS2MAIL_DEFAULT_FEEDS_PATH'] ||
    File.join(ENV.user_home, '.rss2mail')

  DEFAULT_FEEDS_FILE = ENV['RSS2MAIL_DEFAULT_FEEDS_FILE'] ||
    File.join(BASE_PATH, 'feeds.yaml')

end

require 'nuggets/pluggable'
Nuggets::Pluggable.load_plugins_for(RSS2Mail)
