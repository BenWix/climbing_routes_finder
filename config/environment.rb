require 'bundler'
Bundler.require 

require 'pry'
require 'dotenv'
require 'net/http'
require 'open-uri'
require 'json'

Dotenv.load



require_relative '../lib/location'
require_relative '../lib/api'
require_relative '../lib/route'
require_relative '../lib/cli'
