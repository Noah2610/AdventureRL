module AdventureRL
	class Settings
		include AdventureRL::ErrorHelper
		attr_reader :content

		def initialize file
			@file = Pathname.new file
			validate_file_exists
			@content = get_file_content.keys_to_sym
		end

		def get *keys
			current_content = @content
			keys.each do |key|
				key = key.to_sym  if (key.is_a? String)
				if (current_content.is_a?(Hash) && current_content[key])
					current_content = current_content[key]
				else
					current_content = nil
					break
				end
			end
			return current_content
		end

		private

		def validate_file_exists file = @file
			error "File does not exist: '#{file.to_path}'"  unless (file.file?)
		end

		def get_file_content file = @file
			begin
				return YAML.load_file(file.to_path) || {}
			rescue
				error "Couldn't load settings file: '#{file.to_path}'", 'Is it a valid YAML file?'
			end
		end
	end
end
