require "rack/param/version"

module Rack
  class Request
    attr_accessor :parameter_errors
    
    def param(name, type, opts={})
			_name = name.to_s
      @valid_params ||= []
      
      p = Rack::Param::Parameter.new(
        :name => _name,
        :value => params.delete(_name),
        :type => type,
        :opts => opts
      )
      
      if p.valid?
        params[_name] = p.value
      else
        @parameter_errors ||= []
        @parameter_errors.push(*p.errors)
      end
    end
    
    def handle_errors(&block)
      block.call(@parameter_errors) if @parameter_errors.count > 0
    end
  end
  
  module Param
    Boolean = TrueClass
    ParameterError = Struct.new :message
    
    TRUE_REGEX = /(true|t|yes|y|1)$/i
    FALSE_REGEX = /(false|f|no|n|0)$/i
    
    class Rule
      def initialize message, &block
        @block = block
      end
    
      def self.rule message, &block
        new &block
      end
    
      def validate param, value
        return message.sub("$",param).sub("#",value) if @block.call(param,value)
      end
    end
    
    class Parameter
      attr_reader :errors, :value
      
      def initialize(opts={})
				_opts = opts.dup
				@default = _opts.delete :default
				@required = _opts.delete :required
				@transform = _opts.delete :transform
				@delimiter = _opts.delete(:delimiter) || ","
				@separator = _opts.delete(:separator) || ":"
        @name = opts[:name]
        @type = opts[:type]
        @value = opts[:value] || @default
        @errors = process _opts
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
        return nil if default?
        return (required? ? ["Failed to process #{@name} because it's nil."] : nil) if nil?
        
        begin
          @value = case @type
            when Date then Date.parse @value
            when Time then Time.parse @value
            when DateTime then DateTime.parse @value
            when Array then Array @value.split(@delimiter)
            when Hash then Hash[@value.split(@delimiter).map { |c| c.split @separator }]
            when Boolean then (FALSE_REGEX.match(@value) ? false : (TRUE_REGEX.match(@value) ? true : raise StandardError, "Invalid boolean"))
            else
              method(@type.to_s.to_sym).call @value
            end
        rescue StandardError
          return ["Failed to coerce #{@name}"]
        end
        
        return [] if default?
        selected = all_rules.select { |k,v| opts.include? k }
        v_errs = opts.map { |k,v| selected[k].validate @value, v }.collect
        
        return v_errs if v_errs.count > 0
        
        @value = @transform.to_proc.call @value if @transform
        
        []
      end
      
      def all_rules
        @rules ||= {}
        if @rules.empty?
          @rules[:blank] = Rule.rule "$ cannot be blank." { |p, v| v && !(p.empty? rescue true) }
          @rules[:greater_than] = Rule.rule "$ can't be less than #." { |p,v| p > v }
          @rules[:less_than] = Rule.rule "$ can't be greater than #." { |p,v| p < v }
          @rules[:min] = Rule.rule "$ can't be less than #." { |p,v| p >= v }
          @rules[:max] = Rule.rule "$ can't be greater than #." { |p,v| p <= v }
          @rules[:length] = Rule.rule "$ can't be longer or shorter than #." { |p,v| p.length == v }
          @rules[:min_length] = Rule.rule "$ must be longer than #." { |p,v| p.length >= v }
          @rules[:max_length] = Rule.rule "$ must be shorter than #." { |p,v| p.length <= v }
          @rules[:in] = Rule.rule "$ must be within #." { |p,v| v.include? p }
          @rules[:regex] = Rule.rule "$ failed validation." { |p,v| v.match p }
          @rules[:validator] = Rule.rule "$ failed validation." { |p,v| v.call p }
        end
        @rules
      end
    end
  end
end
