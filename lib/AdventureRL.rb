require 'gosu'
require 'pathname'
require 'yaml'

module AdventureRL
  entry = Pathname.new(__FILE__).realpath
  # The root directory of the gem. Used for requiring ruby files.
  ROOT  = entry.dirname
  # A constant containing a bunch of directories or files.
  DIR   = {
    entry:    entry,
    src:      ROOT.join('AdventureRL'),
    helpers:  ROOT.join('AdventureRL/Helpers'),
    misc:     ROOT.join('AdventureRL/misc'),
    settings: ROOT.join('default_settings.yml')
  }

  require DIR[:misc].join 'require_files'

  # Default gem settings defined in <tt>default_settings.yml</tt>.
  DEFAULT_SETTINGS = Settings.new DIR[:settings]
end
