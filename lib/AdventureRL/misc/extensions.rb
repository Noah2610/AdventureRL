module AdventureRL::Extensions  end
module AdventureRL::Extensions::HashExtension
  def keys_to_sym
    return self.map do |key, val|
      new_val = val
      new_val = val.keys_to_sym  if (val.is_a? Hash)
      new_key = key
      new_key = key.to_sym       if (key.is_a? String)
      next [new_key, new_val]
    end .to_h
  end
  def sort_by_keys *keys
    keys.flatten!
    return self.sort_by do |key, val|
      next keys.index key
    end .to_h
  end
end
class Hash
  include AdventureRL::Extensions::HashExtension
end

module AdventureRL::Extensions::ArrayExtension
  def include_all? *vals
    return vals.all? do |val|
      next self.include? val
    end
  end
  def include_any? *vals
    return vals.any? do |val|
      next self.include? val
    end
  end
end
class Array
  include AdventureRL::Extensions::ArrayExtension
end

module AdventureRL::Extensions::RangeExtension
  def sample
    return self.to_a.sample
  end
end
class Range
  include AdventureRL::Extensions::RangeExtension
end
