module AdventureRL
  module Helpers
    module Error
      PADDING = '  '

      def self.error *messages
        message = messages.join ?\n
        message.gsub! /^/, PADDING
        abort([
          "#{DIR[:entry].to_s} Error:",
          message,
          "#{PADDING}Exitting."
        ].join(?\n))
      end

      private

      def error *messages
        Error.error *messages
      end
    end
  end
end
