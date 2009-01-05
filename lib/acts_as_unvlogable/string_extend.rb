
class String
  def query_param(param_name)
    raise ArgumentError.new("param name can't be nil") if param_name.blank?
    uri = URI.parse(self)
    (CGI::parse(uri.query)[param_name].to_s if uri.query) || nil
  end
end