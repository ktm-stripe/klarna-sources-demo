require 'rubygems'
require 'bundler'

Bundler.require(:default, ENV['APPLICATION_ENVIRONMENT'])

require_relative './main'
run KlarnaSourcesDemo
