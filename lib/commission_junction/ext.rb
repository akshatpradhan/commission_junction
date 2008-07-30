
Array.class_eval do
  def to_hash
    self.inject({}) do |hash, pair|
      hash[pair[0]] = pair[1]
      hash
    end
  end
end

Object.class_eval do
  def instance_variables_hash
    instance_variables.inject({}) do |hash, name| 
      hash[name.gsub("@", "")] = instance_variable_get(name)
      hash
    end
  end
  alias :to_hash :instance_variables_hash
end

SOAP::Mapping::Object.class_eval do
  def to_hash
    __xmlele.map do |qname, value| 
      value = if value.is_a? SOAP::Mapping::Object
                value.to_hash
              elsif value.is_a? Array
                value.map {|v| v.is_a?(SOAP::Mapping::Object) ? v.to_hash : v }
              else
                value
              end
      [qname.name, value] 
    end.to_hash
  end
end
