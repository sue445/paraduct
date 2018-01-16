source "https://rubygems.org"

# Specify your gem's dependencies in paraduct.gemspec
gemspec

if Gem::Version.create(RUBY_VERSION) < Gem::Version.create("2.2.2")
  gem "activesupport", "< 5.0.0"
end

if Gem::Version.create(RUBY_VERSION) < Gem::Version.create("2.2.0")
  group :development do
    # NOTE: byebug 9.1.0+ requires ruby 2.2.0+
    gem "byebug", "< 9.1.0"
  end
end
