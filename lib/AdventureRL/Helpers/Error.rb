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
          "#{PADDING}Exiting."
        ].join(?\n))
      end

      def self.error_no_file file
        filepath = file
        filepath = file.to_path  if (file.is_a? Pathname)
        error "File does not exist, or is a directory:", "  '#{filepath}'"
      end

      def self.error_no_directory directory
        dirpath = directory
        dirpath = directory.to_path  if (directory.is_a? Pathname)
        error "Directory does not exist, or is a file:", "  '#{dirpath}'"
      end

      def self.file_exists? file
        return false  unless (file)
        return File.file? file
      end

      def self.directory_exists? directory
        return false  unless (directory)
        return File.directory? directory
      end

      private

      def error *messages
        AdventureRL::Helpers::Error.error *messages
      end

      def error_no_file file
        AdventureRL::Helpers::Error.error_no_file file
      end

      def error_no_directory directory
        AdventureRL::Helpers::Error.error_no_directory directory
      end

      def file_exists? file
        return AdventureRL::Helpers::Error.file_exists? file
      end

      def directory_exists? directory
        return AdventureRL::Helpers::Error.directory_exists? directory
      end
    end
  end
end
