# This file purely <tt>require</tt>s code files.
module AdventureRL
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
  require DIR[:src].join     'Layer'
  require DIR[:src].join     'FileGroup'
  require DIR[:src].join     'FileGroupPlayer'
  require DIR[:src].join     'Clip'
  require DIR[:src].join     'ClipPlayer'
  require DIR[:src].join     'Audio'
  require DIR[:src].join     'AudioPlayer'
  require DIR[:src].join     'Rectangle'
end