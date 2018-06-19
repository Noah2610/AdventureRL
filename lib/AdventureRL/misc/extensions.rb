module AdventureRL::HashExtension
	def keys_to_sym
		return self.map do |key, val|
			new_val = val
			new_val = val.keys_to_sym  if (val.is_a? Hash)
			new_key = key
			new_key = key.to_sym       if (key.is_a? String)
			next [new_key, new_val]
		end .to_h
	end
end
class Hash
	include AdventureRL::HashExtension
end
