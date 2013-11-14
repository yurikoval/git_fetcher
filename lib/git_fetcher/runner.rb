module GitFetcher
  module Runner
    def self.execute(cmd_arg = '.', *args)
      case cmd_arg
      when /^\-+h/
        send('help', *args)
      when /^\-+p/
        send('fetch', true, *args)
      else
        send('fetch', false, cmd_arg)
      end
    end

    def self.is_git_repo
      %x[git rev-parse 2>&1]
      $?.exitstatus == 0
    end

    def self.current_branch_name
      branch_name = %x[git symbolic-ref -q HEAD].chomp
      branch_name.slice!("refs/heads/")
      branch_name
    end

    def self.fetch(perform_stash_rebase = false, *args)
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

      failed_rebase_repos = []
      failed_stash_pop_repos = []
      repos.each do |d|
        repo_to_update = File.join(dir_to_scan, d)
        Dir.chdir repo_to_update
        if is_git_repo
          puts perform_stash_rebase ? "Updating #{d} and performing stash + pull/rebase on #{current_branch_name}." : "Updating #{d}."
          %x[git remote update]
          if perform_stash_rebase
            %x[git diff --exit-code]
            has_diff = $?.exitstatus != 0

            %x[git diff --exit-code]
            has_diff_cached = $?.exitstatus != 0

            %x[git stash 2>&1] if (has_diff || has_diff_cached)
            %x[git pull --rebase 2>&1]
            if $?.exitstatus == 0
              if (has_diff || has_diff_cached)
                %x[git stash pop 2>&1]
                unless $?.exitstatus == 0
                  failed_stash_pop_repos << [d, current_branch_name]
                  puts "Failed to stash pop #{d} on #{current_branch_name}."
                end
              end
            else
              failed_rebase_repos << [d, current_branch_name]
              puts "Failed to rebase #{d} on #{current_branch_name}."
            end
          end
        end
      end

      if perform_stash_rebase && failed_rebase_repos.any?
        puts ""
        puts "Failed to rebase:"
        failed_rebase_repos.each do |repo|
          puts "  #{repo[0]} on #{repo[1]}"
        end
      end
      if perform_stash_rebase && failed_stash_pop_repos.any?
        puts ""
        puts "Failed to stash pop:"
        failed_stash_pop_repos.each do |repo|
          puts "  #{repo[0]} on #{repo[1]}"
        end
      end
    end

    def self.help
      puts <<-HELP
git-fetcher #{VERSION} is installed.

  Usage:
          git-fetcher [OPTION] [DIRECTORY]

git-fetcher will crawl through your directory and find any repos and perform a fetch on all remote sources.

    -h    Display this help.
    -p    Perform `git stash` followed by `git pull --rebase` with `git stash pop` after updating all remote sources.

      HELP
    end
  end

end
