# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)
ENV['SECRET_KEY_BASE'] ||= "6c9cbd9a77d8bb338b871100d4fdefe81103c2385b2ffd320c73a0d468625b4998444e59d192a938344a783b95f1190129611bddce2a075dcc4447e358253914"
require 'bundler/setup' if File.exist?(ENV['BUNDLE_GEMFILE'])
