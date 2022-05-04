source "https://rubygems.org"
ruby RUBY_VERSION

# Hello! This is where you manage which Jekyll version is used to run.
# When you want to use a different version, change it below, save the
# file and run `bundle install`. Run Jekyll with `bundle exec`, like so:
#
#     bundle exec jekyll serve
#
# This will help ensure the proper Jekyll version is running.
# Happy Jekylling!
# gem "jekyll", "3.4.3"
gem "jekyll", ">= 3.6.3"
# gem "ffi", ">= 1.9.24"


# This is the default theme for new Jekyll sites. You may change this to anything you like.
# gem "minima", "~> 2.0"    // Disabled because I don't want know gem-based theme (DP / May 28 2017)

# If you want to use GitHub Pages, remove the "gem "jekyll"" above and
# uncomment the line below. To upgrade, run `bundle update github-pages`.
# gem "github-pages", group: :jekyll_plugins

# If you have any plugins, put them here!
group :jekyll_plugins do
   gem "jekyll-feed", "~> 0.6"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

# https://github.com/jekyll/jekyll-redirect-from
gem 'jekyll-redirect-from'
gem 'webrick'

# Adding this at the suggestion of this comment https://talk.jekyllrb.com/t/expected-end-of-string-but-found-id/4290/2
# ...so my local env will match what GH Pages expects, etc
# gem "github-pages", group: :jekyll_plugins
# –––> Removing it actually b/c of bundle update error - don't feel like dealing with that right now (May 4, 2022)
