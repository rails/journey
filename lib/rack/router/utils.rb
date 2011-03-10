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

      RESERVED_PCHAR = ':@&=+$,;%'
      SAFE_PCHAR = "#{URI::REGEXP::PATTERN::UNRESERVED}#{RESERVED_PCHAR}"
      if RUBY_VERSION >= '1.9'
        UNSAFE_PCHAR = Regexp.new("[^#{SAFE_PCHAR}]", false).freeze
      else
        UNSAFE_PCHAR = Regexp.new("[^#{SAFE_PCHAR}]", false, 'N').freeze
      end

      Parser = URI.const_defined?(:Parser) ? URI::Parser.new : URI

      def self.escape_uri(uri)
        Parser.escape(uri.to_s)
      end
    end
  end
end
