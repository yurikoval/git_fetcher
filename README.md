= git_fetcher

  [http://blog.yurikoval.com/git_fetcher](http://blog.yurikoval.com/git_fetcher)

== Installation

    gem install git_fetcher

== Usage

    git-fetcher /path/to/your/development/directory

This will fetch from all remote sources for git repos in that directory. Essentially the same as going into every directory and running `git remote update` or `git fetch --all`.

== Contributing to git_fetcher

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

== Copyright

Copyright (c) 2013 Yuri Kovalov. MIT License
