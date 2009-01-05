# This removes the activesupport dependency

class Object
  def blank?
    respond_to?(:empty?) ? empty? : !self
  end
  
  def instance_values #:nodoc:
    instance_variables.inject({}) do |values, name|
      values[name.to_s[1..-1]] = instance_variable_get(name)
      values
    end
  end
end