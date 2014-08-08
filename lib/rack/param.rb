#/usr/bin/env ruby

require "rack"
require "time"
require "date"

Boolean = "Boolean" # A boldfaced hack

module Rack
  class Request
    attr_reader :parameter_errors, :valid_parameters
    
    def param name, type, opts={}
			_name = name.to_s
      @valid_params ||= {}
      @parameter_errors ||= []
      
      p = Rack::Param::Parameter.new(
        :name => _name,
        :value => params.delete(_name),
        :type => type,
        :conditions => opts
      )
      
      if p.valid?
        params[_name] = p.value
        @valid_params[name] = p.value
      else
        @parameter_errors ||= []
        @parameter_errors.push(*p.errors)
      end
    end
    
    def param_error &block
      @param_err_block = block
    end
    
    def handle_errors(&block)
      block.call(@parameter_errors) if @parameter_errors.count > 0
    end
  end
  
  module Param
    ParameterError = Struct.new :message
    
    TRUE_REGEX = /(true|t|yes|y|1)$/i
    FALSE_REGEX = /(false|f|no|n|0)$/i
    
    class Rule
      def initialize message, &block
        @block = block
        @message = message
      end
      
      class << self
        def [] message, &block
          new message, &block
        end
        
        alias_method :rule, :[]
      end

      def validate param, value
        return @message.sub("$",param.to_s).sub("#",value.to_s) unless @block.call(param,value)
      end
    end
    
    class Parameter
      attr_reader :errors, :value
      
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
        @errors = process(_opts)
      end

      def valid?
        @errors.count == 0
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
        return [] if default?
        return (required? ? ["Failed to process #{@name} because it's nil."] : []) if nil?

        unless @value.class == @type
          begin
            @value = case @type.to_s.downcase.to_sym
              when :date then Date.parse @value
              when :time then Time.parse @value
              when :datetime then DateTime.parse @value
              when :array then @value.split(@delimiter)
              when :hash then Hash[@value.split(@delimiter).map { |c| c.split @separator, 2 }]
              when :boolean then (FALSE_REGEX.match(@value) ? false : (TRUE_REGEX.match(@value) ? true : raise(StandardError)))
              else method(@type.to_s.to_sym).call @value end
          rescue StandardError => e
            raise e
            return ["Failed to coerce #{@name} into a#{@type.to_s.match(/^[aeiouAEIOU]/) ? "n" : ""} #{@type.to_s}"]
          end
        end
        
        v_errs = opts.map { |k,v| rules[k].validate(@value, v) }.compact
        
        return v_errs if v_errs.count > 0
        
        @value = @transform.to_proc.call @value if @transform
        
        []
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
