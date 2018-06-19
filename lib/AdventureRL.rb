require 'gosu'
require 'pathname'
require 'yaml'

module AdventureRL
  entry = Pathname.new(__FILE__).realpath
  ROOT  = entry.dirname
  DIR   = {
    entry:    entry,
    src:      ROOT.join('AdventureRL'),
    helpers:  ROOT.join('AdventureRL/Helpers'),
    misc:     ROOT.join('AdventureRL/misc'),
    settings: ROOT.join('../default_settings.yml')
  }

  require DIR[:src].join     'version'
  require DIR[:misc].join    'extensions'
  require DIR[:helpers].join 'Error'
  require DIR[:helpers].join 'Method'
  require DIR[:src].join     'Settings'
  require DIR[:src].join     'Window'

  DEFAULT_SETTINGS = Settings.new DIR[:settings]
end
