
require "peddler"

# https://github.com/hakanensari/peddler

namespace :mws do
	task :get_products => :environment do
		puts "Getting products..."
    MwsWorker.perform_later
	end
end
