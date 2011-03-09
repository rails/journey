require 'uri'

module Rack
  class Router
    class Utils
      # Normalizes URI path.
      #
      # Strips off trailing slash and ensures there is a leading slash.
      #
      #   normalize_path("/foo")  # => "/foo"
      #   normalize_path("/foo/") # => "/foo"
      #   normalize_path("foo")   # => "/foo"
      #   normalize_path("")      # => "/"
      def self.normalize_path(path)
        path = "/#{path}"
        path.squeeze!('/')
        path.sub!(%r{/+\Z}, '')
        path = '/' if path == ''
        path
      end
    end
  end
end
