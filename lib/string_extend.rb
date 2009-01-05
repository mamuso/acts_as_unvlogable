# This removes the activesupport dependency

class String
  def blank?
    respond_to?(:empty?) ? empty? : !self
  end
  
  def camelize(first_letter_in_uppercase = true)
     if first_letter_in_uppercase
       self.to_s.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
     else
       self.first + camelize(self)[1..-1]
     end
   end
  
  def constantize
    camel_cased_word = self
    unless /\A(?:::)?([A-Z]\w*(?:::[A-Z]\w*)*)\z/ =~ camel_cased_word
      raise NameError, "#{camel_cased_word.inspect} is not a valid constant name!"
    end

    Object.module_eval("::#{$1}", __FILE__, __LINE__)
  end
end