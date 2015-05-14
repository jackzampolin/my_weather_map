# Set up gems listed in the Gemfile.
# See: http://gembundler.com/bundler_setup.html
#      http://stackoverflow.com/questions/7243486/why-do-you-need-require-bundler-setup
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])

# Require gems we care about
require 'rubygems'
require 'uri'
require 'pathname'
require 'pg'
require 'active_record'
require 'logger'
require 'pry'
require 'json'
require 'unirest'
require 'dotenv'
Dotenv.load if #ENV["RACK_ENV"] == test || ENV["RACK_ENV"] == development
require 'sinatra'
require "sinatra/reloader" if development?
require 'erb'

# Some helper constants for path-centric logic
APP_ROOT = Pathname.new(File.expand_path('../../', __FILE__))
APP_NAME = APP_ROOT.basename.to_s

configure do
  # By default, Sinatra assumes that the root is the file that calls the configure block.
  # Since this is not the case for us, we set it manually.
  set :root, APP_ROOT.to_path
  # See: http://www.sinatrarb.com/faq.html#sessions
  enable :sessions
  set :session_secret, ENV['SESSION_SECRET'] || 'this is a secret shhhhh'

  # Set the views to
  set :views, File.join(Sinatra::Application.root, "app", "views")
end

# Set up the controllers and helpers
Dir[APP_ROOT.join('app', 'controllers', '*.rb')].each { |file| require file }
Dir[APP_ROOT.join('app', 'helpers', '*.rb')].each { |file| require file }

# Set up the database and models
require APP_ROOT.join('config', 'database')

# Station Coords from here: http://www.wunderground.com/weatherstation/overview.asp
SF_STATIONS = [{ 'pws_id' => 'KCASANFR34', 'lat' => 37.749 , 'lng' => -122.453 },{ 'pws_id' => 'KCASANFR48', 'lat' => 37.745 , 'lng' => -122.467 },{ 'pws_id' => 'KCASANFR4', 'lat' => 37.771 , 'lng' => -122.424 },{ 'pws_id' => 'KCASANFR58', 'lat' => 37.773 , 'lng' => -122.418 },{ 'pws_id' => 'KCASANFR70', 'lat' => 37.732 , 'lng' => -122.443 },{ 'pws_id' => 'KPCASANF2', 'lat' => 37.759 , 'lng' => -122.430 },{ 'pws_id' => 'KCASANFR79', 'lat' => 37.754 , 'lng' => -122.412 },{ 'pws_id' => 'KCASANFR73', 'lat' => 37.742 , 'lng' => -122.434 },{ 'pws_id' => 'KCASANFR97', 'lat' => 37.779 , 'lng' => -122.485 },{ 'pws_id' => 'KCASANFR99', 'lat' => 37.775 , 'lng' => -122.510 },{ 'pws_id' => 'KCASANFR100', 'lat' => 37.711 , 'lng' => -122.477 },{ 'pws_id' => 'KCASANFR107', 'lat' => 37.772  , 'lng' => -122.511 },{ 'pws_id' => 'KCASANFR102', 'lat' => 37.794 , 'lng' => -122.399 },{ 'pws_id' => 'KCASANFR114', 'lat' => 37.760 , 'lng' => -122.432 },{ 'pws_id' => 'KCASANFR135', 'lat' => 37.730 , 'lng' => -122.418 },{ 'pws_id' => 'KCASANFR460', 'lat' => 37.744 , 'lng' => -122.409 },{ 'pws_id' => 'KCASANFR138', 'lat' => 37.759 , 'lng' => -122.437 },{ 'pws_id' => 'KCASANFR142', 'lat' => 37.766 , 'lng' => -122.423 },{ 'pws_id' => 'KCASANFR148', 'lat' => 37.802 , 'lng' => -122.451 },{ 'pws_id' => 'KCASANFR149', 'lat' => 37.732 , 'lng' => -122.443 },{ 'pws_id' => 'KCASANFR155', 'lat' => 37.787 , 'lng' => -122.442 },{ 'pws_id' => 'KCASANFR156', 'lat' => 37.765 , 'lng' => -122.462 },{ 'pws_id' => 'KCASANFR159', 'lat' => 37.749 , 'lng' => -122.409 },{ 'pws_id' => 'KCASANFR161', 'lat' => 37.729 , 'lng' => -122.459 },{ 'pws_id' => 'KCASANFR166', 'lat' => 37.789 , 'lng' => -122.441 },{ 'pws_id' => 'KCASANFR165', 'lat' => 37.710 , 'lng' => -122.439 },{ 'pws_id' => 'KCASANFR169', 'lat' => 37.804 , 'lng' => -122.408 },{ 'pws_id' => 'KCASANFR231', 'lat' => 37.783 , 'lng' => -122.407 },{ 'pws_id' => 'KCASANFR232', 'lat' => 37.759 , 'lng' => -122.441 },{ 'pws_id' => 'KCASANFR236', 'lat' => 37.793 , 'lng' => -122.404 },{ 'pws_id' => 'KCASANFR244', 'lat' => 37.756 , 'lng' => -122.436 },{ 'pws_id' => 'KCASANFR259', 'lat' => 37.759 , 'lng' => -122.415 },{ 'pws_id' => 'KCASANFR260', 'lat' => 37.720 , 'lng' => -122.427 },{ 'pws_id' => 'KCASANFR284', 'lat' => 37.809 , 'lng' => -122.412 },{ 'pws_id' => 'KCASANFR286', 'lat' => 37.715 , 'lng' => -122.500 },{ 'pws_id' => 'KCASANFR291', 'lat' => 37.776 , 'lng' => -122.418 },{ 'pws_id' => 'KCASANFR296', 'lat' => 37.794 , 'lng' => -122.415 },{ 'pws_id' => 'KCASANFR302', 'lat' => 37.760 , 'lng' => -122.498 },{ 'pws_id' => 'KCASANFR306', 'lat' => 37.740 , 'lng' => -122.471 },{ 'pws_id' => 'KCASANFR309', 'lat' => 37.782 , 'lng' => -122.391 },{ 'pws_id' => 'KCASANFR314', 'lat' => 37.779 , 'lng' => -122.394 },{ 'pws_id' => 'KCASANFR317', 'lat' => 37.761 , 'lng' => -122.439 },{ 'pws_id' => 'KCASANFR318', 'lat' => 37.731 , 'lng' => -122.430 },{ 'pws_id' => 'KCASANFR319', 'lat' => 37.755 , 'lng' => -122.429 },{ 'pws_id' => 'KCASANFR323', 'lat' => 37.760 , 'lng' => -122.432 },{ 'pws_id' => 'KCASANFR324', 'lat' => 37.756 , 'lng' => -122.398 },{ 'pws_id' => 'KCASANFR326', 'lat' => 37.767 , 'lng' => -122.408 },{ 'pws_id' => 'KCASANFR327', 'lat' => 37.782 , 'lng' => -122.394 },{ 'pws_id' => 'KCASANFR382', 'lat' => 37.763 , 'lng' => -122.452 },{ 'pws_id' => 'KCASANFR345', 'lat' => 37.757 , 'lng' => -122.462 },{ 'pws_id' => 'KCASANFR346', 'lat' => 37.735 , 'lng' => -122.446 },{ 'pws_id' => 'KCASANFR348', 'lat' => 37.726 , 'lng' => -122.395 },{ 'pws_id' => 'KCASANFR431', 'lat' => 37.733 , 'lng' => -122.438 },{ 'pws_id' => 'KCASANFR350', 'lat' => 37.800 , 'lng' => -122.439 },{ 'pws_id' => 'KCASANFR352', 'lat' => 37.736 , 'lng' => -122.450 },{ 'pws_id' => 'KCASANFR354', 'lat' => 37.767 , 'lng' => -122.437 },{ 'pws_id' => 'KCASANFR359', 'lat' => 37.812 , 'lng' => -122.421 },{ 'pws_id' => 'KCASANFR361', 'lat' => 37.808 , 'lng' => -122.454 },{ 'pws_id' => 'KCASANFR363', 'lat' => 37.729 , 'lng' => -122.456 },{ 'pws_id' => 'KCASANFR365', 'lat' => 37.754 , 'lng' => -122.433 },{ 'pws_id' => 'KCASANFR366', 'lat' => 37.762 , 'lng' => -122.430 },{ 'pws_id' => 'KCASANFR367', 'lat' => 37.759 , 'lng' => -122.422 },{ 'pws_id' => 'KCASANFR371', 'lat' => 37.768 , 'lng' => -122.425 },{ 'pws_id' => 'KCASANFR373', 'lat' => 37.725 , 'lng' => -122.417 },{ 'pws_id' => 'KCASANFR374', 'lat' => 37.763 , 'lng' => -122.452 },{ 'pws_id' => 'KCASANFR376', 'lat' => 37.740 , 'lng' => -122.461 },{ 'pws_id' => 'KCASANFR384', 'lat' => 37.774 , 'lng' => -122.432 },{ 'pws_id' => 'KCASANFR385', 'lat' => 37.734 , 'lng' => -122.432 },{ 'pws_id' => 'KCASANFR394', 'lat' => 37.779 , 'lng' => -122.397 },{ 'pws_id' => 'KCASANFR396', 'lat' => 37.768 , 'lng' => -122.447 },{ 'pws_id' => 'KCASANFR398', 'lat' => 37.734 , 'lng' => -122.452 },{ 'pws_id' => 'KCASANFR400', 'lat' => 37.766 , 'lng' => -122.437 },{ 'pws_id' => 'KCASANFR404', 'lat' => 37.759 , 'lng' => -122.432 },{ 'pws_id' => 'KCASANFR409', 'lat' => 37.722 , 'lng' => -122.473 },{ 'pws_id' => 'KCASANFR415', 'lat' => 37.758 , 'lng' => -122.424 },{ 'pws_id' => 'KCASANFR424', 'lat' => 37.764 , 'lng' => -122.431 },{ 'pws_id' => 'KCASANFR438', 'lat' => 37.773 , 'lng' => -122.433 },{ 'pws_id' => 'KCASANFR441', 'lat' => 37.772 , 'lng' => -122.442 },{ 'pws_id' => 'KCASANFR447', 'lat' => 37.741 , 'lng' => -122.460 },{ 'pws_id' => 'KCASANFR451', 'lat' => 37.755 , 'lng' => -122.436 },{ 'pws_id' => 'KCASANFR453', 'lat' => 37.758 , 'lng' => -122.424 },{ 'pws_id' => 'KCASANFR459', 'lat' => 37.793 , 'lng' => -122.404 },{ 'pws_id' => 'KCASANFR461', 'lat' => 37.744 , 'lng' => -122.452 },{ 'pws_id' => 'KCASANFR467', 'lat' => 37.803 , 'lng' => -122.425 },{ 'pws_id' => 'KCASANFR470', 'lat' => 37.741 , 'lng' => -122.462 },{ 'pws_id' => 'KCASANFR474', 'lat' => 37.783 , 'lng' => -122.395 },{ 'pws_id' => 'KCASANFR476', 'lat' => 37.754 , 'lng' => -122.453 },{ 'pws_id' => 'KCASANFR479', 'lat' => 37.790 , 'lng' => -122.390 },{ 'pws_id' => 'KCASANFR482', 'lat' => 37.772 , 'lng' => -122.506 },{ 'pws_id' => 'KCASANFR483', 'lat' => 37.740 , 'lng' => -122.449 }]
