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
Hash.include AdventureRL::Extensions::HashExtension

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
Array.include AdventureRL::Extensions::ArrayExtension

module AdventureRL::Extensions::RangeExtension
  def sample
    return self.to_a.sample
  end
end
Range.include AdventureRL::Extensions::RangeExtension

module AdventureRL::Extensions::StringAndSymbolExtension
  def upper?
    return self == self.upcase
  end
  def lower?
    return self == self.downcase
  end
end
String.include AdventureRL::Extensions::StringAndSymbolExtension
Symbol.include AdventureRL::Extensions::StringAndSymbolExtension

module AdventureRL::Extensions::IntegerAndFloatExtension
  def sign
    return self / self.abs
  end
end
Integer.include AdventureRL::Extensions::IntegerAndFloatExtension
Float.include AdventureRL::Extensions::IntegerAndFloatExtension
