module GitFetcher
  module Runner
    def self.execute(cmd_arg = '.', *args)
      if cmd_arg.match /^\-+h/
        send('help', *args)
      else
        send('fetch', cmd_arg)
      end
    end

    def self.is_git_repo
      %x[git rev-parse 2>&1]
      $?.exitstatus == 0
    end

    def self.fetch(*args)
      dir_to_scan = if args[0]
        if args[0] !~ /^\//
          File.join(Dir.pwd, args[0])
        else
          args[0]
        end
      else
        Dir.pwd
      end

      repos = Dir.entries(dir_to_scan).select {|f| File.directory?(File.join(dir_to_scan, f)) && !f.match(/^\.+$/) }

      repos.each do |d|
        repo_to_update = File.join(dir_to_scan, d)
        Dir.chdir repo_to_update
        if is_git_repo
          puts "Updating #{d}."
          %x[git remote update]
        end
      end
    end

    def self.help
      puts <<-HELP
git-fetcher #{VERSION} is installed.

  Usage:
          git-fetcher [DIRECTORY]

git-fetcher will crawl through your directory and find any repos and perform a fetch on all remote sources.
      HELP
    end
  end

end
