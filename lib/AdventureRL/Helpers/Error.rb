module AdventureRL
  module Helpers
    module Error
      PADDING = '  '

      private

      def error *messages
        message = messages.join ?\n
        message.gsub! /^/, PADDING
        abort([
          "#{DIR[:entry].to_s} Error:",
          message,
          "#{PADDING}Exitting."
        ].join(?\n))
      end
    end
  end
end
