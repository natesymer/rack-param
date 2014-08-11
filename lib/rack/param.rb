#/usr/bin/env ruby

require "rack"
require "time"
require "date"

Boolean = "Boolean" # A boldfaced hack

module Rack
  class Request
    ParameterError = Class.new StandardError
    
    def param name, type, opts={}
      @processed_params = nil # Make params() recalculate valid parameters
      @valid_params ||= []
			_name = name.to_s
      
      p = Rack::Param::Parameter.new(
        :name => _name,
        :value => params.delete(_name),
        :type => type,
        :conditions => opts
      )
      
      raise ParameterError, p.error unless p.valid?
      
      params[_name] = p.value
      @valid_params << name
    end
    
    alias_method :params_original, :params
    
    def params
      if @processed_params.nil?
        s = params_original()
        @processed_params = s.select { |k,v| @valid_params.include? k }
      end
      @processed_params
    end
  end
  
  module Param
    class String
      def truthy?
        /^(true|t|yes|y|1|on)$/ =~ dowcase
      end
      
      def falsey?
        /^(false|f|no|n|0|off)$/ =~ downcase
      end
    end
    
    class Rule
      def initialize message, &block
        @block = block
        @message = message
      end
      
      def self.rule message, &block
        new message, &block
      end

      def validate param, value
        return @message.sub("$",param.to_s).sub("#",value.to_s) unless @block.call(param,value)
      end
    end
    
    class Parameter
      attr_reader :error, :value
      
      def initialize(opts={})
				_opts = opts.dup
        _opts.merge!(_opts.delete(:conditions))
				@default = _opts.delete :default
				@required = _opts.delete :required
				@transform = _opts.delete :transform
				@delimiter = _opts.delete(:delimiter) || ","
				@separator = _opts.delete(:separator) || ":"
        @name = _opts.delete :name
        @type = _opts.delete :type
        @value = _opts.delete(:value) || @default
        @error = process(_opts) unless default?
      end

      def valid?
        @error.nil?# || @error.empty?
      end
      
			def default?
				@default == @value && !@value.nil?
			end
			
			def required?
				@required
			end
			
      def nil?
        @value.nil?
      end

      def process opts
        return "Parameter #{@name} is required." if @value.nil? && required?
        
        unless @value.class == @type
          begin
            @value = case @type.to_s.downcase.to_sym
              when :date then Date.parse @value
              when :time then Time.parse @value
              when :datetime then DateTime.parse @value
              when :array then @value.split(@delimiter)
              when :hash then Hash[@value.split(@delimiter).map { |c| c.split @separator, 2 }]
              when :boolean then (@value.falsey? ? false : @value.truthy? ? true : raise(StandardError))
              else method(@type.to_s.to_sym).call @value end
          rescue StandardError => e
            puts e.message
            return "Failed to coerce #{@name} into a#{@type.to_s.match(/^[aeiouAEIOU]/) ? "n" : ""} #{@type.to_s}"
          end
        end
        
        validate_error = opts.detect { |k,v| rules[k].validate @value, v }
        return validate_error unless validate_error.nil?
        
        @value = @transform.to_proc.call @value if @transform
        nil
      end
      
      def rules
        @rules ||= {}
        if @rules.empty?
          @rules[:blank] = Rule.rule("$ cannot be blank.") { |p,v| v == (p.empty? rescue false) }
          @rules[:greater_than] = Rule.rule("$ can't be less than #.") { |p,v| p > v }
          @rules[:less_than] = Rule.rule("$ can't be greater than #.") { |p,v| p < v }
          @rules[:min] = Rule.rule("$ can't be less than #.") { |p,v| p >= v }
          @rules[:max] = Rule.rule("$ can't be greater than #.") { |p,v| p <= v }
          @rules[:length] = Rule.rule("$ can't be longer or shorter than #.") { |p,v| p.length == v }
          @rules[:min_length] = Rule.rule("$ must be longer than #.") { |p,v| p.length >= v }
          @rules[:max_length] = Rule.rule("$ must be shorter than #.") { |p,v| p.length <= v }
          @rules[:in] = Rule.rule("$ must be included in #.") { |p,v| v.include? p }
          @rules[:contains] = Rule.rule("$ must include #") { |p,v| p.include? v }
          @rules[:regex] = Rule.rule("$ failed validation.") { |p,v| v.match p }
          @rules[:validator] = Rule.rule("$ failed validation.") { |p,v| v.call p }
        end
        @rules
      end
    end
  end
end
