source "https://rubygems.org"

# Solidus 2.11.16 + Rails 8 compat + state_machines <0.10 pin; works on BOTH 7.2 and 8.0 axes.
gem "solidus", git: "https://github.com/Printavo/solidus.git", branch: "rails-8.0-support"

gem "rails-controller-testing", group: :test

# Rails version is supplied per axis via RAILS_VERSION so we can verify 7.2 and 8.0 from one Gemfile.
gem "rails", ENV["RAILS_VERSION"], require: false

if ENV["DB"] == "mysql"
  gem "mysql2", "~> 0.4.10"
else
  gem "pg", "> 0.21"
end

group :development, :test do
  gem "byebug"
  gem "ffaker"
  gem "pry-rails"
  gem "rubocop"

  # rspec-rails 8.x removed fixture_path=; the solidus testing_support stack still relies on it.
  gem "rspec-rails", "~> 7.1"
  # factory_bot 4.x resolves to 4.11.1 (matches the in-tree factory definitions); keep off 5/6.
  gem "factory_bot", "~> 4.11"
  gem "database_cleaner", "~> 2.0"
  gem "sprockets", "~> 4"

  # Ruby 3.4 extracted these from stdlib; factory_bot 4.x requires observer, others surface as LoadErrors.
  gem "observer"
  gem "mutex_m"
  gem "benchmark"
end

gemspec
