# encoding: utf-8

begin
  require 'rubygems/version' # newer rubygems use this
rescue LoadError
  require 'gem/version' # older rubygems use this
end

module SwissMatch
  class Street

    # The version of the swissmatch-street gem.
    Version = Gem::Version.new("0.0.1")
  end
end
