require 'rss2mail/app'

set :root,  File.dirname(__FILE__)
set :title, 'My RSS subscriptions'

run Sinatra::Application
