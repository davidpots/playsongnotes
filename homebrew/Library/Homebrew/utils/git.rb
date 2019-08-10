# frozen_string_literal: true

require "open3"

module Git
  module_function

  def last_revision_commit_of_file(repo, file, before_commit: nil)
    args = if before_commit.nil?
      ["--skip=1"]
    else
      [before_commit.split("..").first]
    end

    out, = Open3.capture3(
      HOMEBREW_SHIMS_PATH/"scm/git", "-C", repo,
      "log", "--format=%h", "--abbrev=7", "--max-count=1",
      *args, "--", file
    )
    out.chomp
  end

  def last_revision_commit_of_files(repo, files, before_commit: nil)
    args = if before_commit.nil?
      ["--skip=1"]
    else
      [before_commit.split("..").first]
    end

    # git log output format:
    #   <commit_hash>
    #   <file_path1>
    #   <file_path2>
    #   ...
    # return [<commit_hash>, [file_path1, file_path2, ...]]
    out, = Open3.capture3(
      HOMEBREW_SHIMS_PATH/"scm/git", "-C", repo, "log",
      "--pretty=format:%h", "--abbrev=7", "--max-count=1",
      "--diff-filter=d", "--name-only", *args, "--", *files
    )
    rev, *paths = out.chomp.split(/\n/).reject(&:empty?)
    [rev, paths]
  end

  def last_revision_of_file(repo, file, before_commit: nil)
    relative_file = Pathname(file).relative_path_from(repo)

    commit_hash = last_revision_commit_of_file(repo, relative_file, before_commit: before_commit)
    out, = Open3.capture3(
      HOMEBREW_SHIMS_PATH/"scm/git", "-C", repo,
      "show", "#{commit_hash}:#{relative_file}"
    )
    out
  end
end

module Utils
  def self.git_available?
    @git_available ||= quiet_system HOMEBREW_SHIMS_PATH/"scm/git", "--version"
  end

  def self.git_path
    return unless git_available?

    @git_path ||= Utils.popen_read(
      HOMEBREW_SHIMS_PATH/"scm/git", "--homebrew=print-path"
    ).chomp.presence
  end

  def self.git_version
    return unless git_available?

    @git_version ||= Utils.popen_read(
      HOMEBREW_SHIMS_PATH/"scm/git", "--version"
    ).chomp[/git version (\d+(?:\.\d+)*)/, 1]
  end

  def self.ensure_git_installed!
    return if git_available?

    # we cannot install brewed git if homebrew/core is unavailable.
    if CoreTap.instance.installed?
      begin
        oh1 "Installing #{Formatter.identifier("git")}"
        safe_system HOMEBREW_BREW_FILE, "install", "git"
      rescue
        raise "Git is unavailable"
      end
    end

    raise "Git is unavailable" unless git_available?
  end

  def self.clear_git_available_cache
    @git_available = nil
    @git_path = nil
    @git_version = nil
  end

  def self.git_remote_exists?(url)
    return true unless git_available?

    quiet_system "git", "ls-remote", url
  end
end
