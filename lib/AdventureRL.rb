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
    settings: ROOT.join('../default_settings.yml')
  }

  require DIR[:src].join     'version'
  require DIR[:misc].join    'extensions'
  require DIR[:helpers].join 'Error'
  require DIR[:helpers].join 'MethodHelper'
  require DIR[:helpers].join 'PipeMethods'
  require DIR[:src].join     'Settings'
  require DIR[:src].join     'Window'
  require DIR[:src].join     'Deltatime'
  require DIR[:src].join     'TimingHandler'
  require DIR[:src].join     'Point'
  require DIR[:src].join     'Mask'
  require DIR[:src].join     'FileGroup'
  require DIR[:src].join     'FileGroupPlayer'
  require DIR[:src].join     'Clip'
  require DIR[:src].join     'ClipPlayer'
  require DIR[:src].join     'Audio'
  require DIR[:src].join     'AudioPlayer'
  require DIR[:src].join     'Rectangle'

  # Default gem settings defined in <tt>default_settings.yml</tt>.
  DEFAULT_SETTINGS = Settings.new DIR[:settings]
end
