require 'bundler'
Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new

task :default do
  if Dir["spec/dummy"].empty?
    Rake::Task[:test_app].invoke
    Dir.chdir("../../")
  end
  Rake::Task[:spec].invoke
end

desc "Generates a dummy app for testing"
task :test_app do
  ENV['LIB_NAME'] = 'solidus_gateway'
  ENV["RAILS_ENV"] = 'test'

  require 'solidus_gateway'
  unless defined?(Solidus::InstallGenerator)
    require 'generators/solidus/install/install_generator'
  end
  require 'generators/spree/dummy/dummy_generator'

  # We inline common:test_app (rather than invoking it) for two Rails 8 reasons:
  #   1. sprockets-rails 3.5 aborts boot with ManifestNeededError unless
  #      app/assets/config/manifest.js exists before the dummy app loads
  #      (mirrors solidusio/solidus#3379, solidusio/solidus#6327). We seed it
  #      between dummy generation and the first bin/rails boot below.
  #   2. db:drop db:create db:migrate chained in one bin/rails process leaves
  #      the sqlite schema empty on Rails 8 (the schema cache makes db:migrate a
  #      no-op); we split them into separate processes.
  Spree::DummyGenerator.start ["--lib_name=#{ENV['LIB_NAME']}", "--quiet"]

  manifest = File.join("spec", "dummy", "app", "assets", "config", "manifest.js")
  unless File.exist?(manifest)
    FileUtils.mkdir_p(File.dirname(manifest))
    File.write(manifest, "//= link_tree ../images\n//= link_directory ../stylesheets .css\n")
  end

  Solidus::InstallGenerator.start ["--lib_name=#{ENV['LIB_NAME']}", "--auto-accept", "--with-authentication=false", "--payment-method=none", "--migrate=false", "--seed=false", "--sample=false", "--quiet", "--user_class=Spree::LegacyUser"]

  puts "Setting up dummy database..."
  Dir.chdir("spec/dummy") do
    sh "bin/rails db:environment:set RAILS_ENV=test"
    sh "bin/rails db:drop RAILS_ENV=test"
    sh "bin/rails db:create RAILS_ENV=test"
    sh "bin/rails db:migrate VERBOSE=false RAILS_ENV=test"
  end
end
