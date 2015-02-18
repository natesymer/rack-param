#/usr/bin/env ruby

require "rack"
require "time"
require "date"

module Rack
  # see end of file
  class TrueClass
    def self.=== o
      return true if o == false
      super
    end
  end

  class FalseClass
    def self.=== o
      return true if o == false
      super
    end
  end
  
  ParameterError = Class.new StandardError
  
  class ::String
    def truthy?
      (/^(true|t|yes|y|1|on)$/ =~ downcase) != nil
    end

    def falsey?
      (/^(false|f|no|n|0|off)$/ =~ downcase) != nil
    end
  end
  
  class Request
    alias_method :raw_params, :params
    def params
      @processed_parameters ||= {}
    end
    
    def param name, type, opts={}
			name = name.to_s
      
      if raw_params.member? name
        p = Rack::Parameter.new(
          :name => name,
          :value => raw_params[name] || params[name],
          :type => type,
          :conditions => opts
        )
      
        raise ParameterError, p.error unless p.valid?
        params[name] = (opts.member?(:coerce) && opts[:coerce]) || !opts.member?(:coerce) ? p.value : raw_params[name]
      else
        raise ParameterError, "Parameter #{name} is required." if opts.member?(:required) && opts[:required]
        nil
      end
    end
  end
  
  class Parameter
    attr_reader :error, :value
    
    class Rule
      def initialize message, &block
        @block = block
        @message = message
      end
      
      def self.rule message, &block
        new message, &block
      end

      def validate param, value, error_msg=nil
        return (error_msg || @message).sub('$',"`#{param.to_s}`").sub('#',"`#{value.to_s}`") unless @block.call(param,value)
      end
    end
    
    def initialize(opts={})
      opts[:value].inspect
			_opts = Hash[opts.dup.map { |k,v| [k.to_sym,v] }]
      _opts.merge! _opts.delete(:conditions)
      @error_message = _opts.delete :error_message
			@default = _opts.delete :default
			@transform = _opts.delete :transform
			@delimiter = _opts.delete(:delimiter) || ","
			@separator = _opts.delete(:separator) || ":"
      @name = _opts.delete :name
      @type = _opts.delete :type
      @value = _opts.delete(:value) || @default
      @error = process(_opts) unless default?
    end

    def valid?
      @error.nil?
    end
    
		def default?
			@default == @value && !@value.nil?
		end
		
    def nil?
      @value.nil?
    end

    def process opts
      unless @value.class == @type || @value.nil?
        begin
          @value = case @type.to_s.downcase.to_sym
            when :date     then Date.parse @value
            when :time     then Time.parse @value
            when :datetime then DateTime.parse @value
            when :array    then @value.split(@delimiter)
            when :hash     then Hash[@value.split(@delimiter).map { |c| c.split @separator, 2 }]
            when :boolean  then (@value.falsey? ? false : @value.truthy? ? true : raise(StandardError))
            else                method(@type.to_s.to_sym).call @value end
        rescue StandardError => e
          return "Parameter `#{@name}` is not a valid #{@type.to_s}."
        end
      end
      
      validate_error = opts.select { |k,v| rules.member? k }.detect { |k,v| break rules[k].validate @value, v, @error_message }
      return validate_error unless validate_error.nil?
      
      @value = @transform.to_proc.call @value if @transform
      nil
    end
     
    def rules
      @rules ||= {
        :blank        => Rule.rule("$ cannot be blank.") { |p,v| v == (p.empty? rescue false) },
        :greater_than => Rule.rule("$ can't be less than #.") { |p,v| p > v },
        :less_than    => Rule.rule("$ can't be greater than #.") { |p,v| p < v },
        :min          => Rule.rule("$ can't be less than #.") { |p,v| p >= v },
        :max          => Rule.rule("$ can't be greater than #.") { |p,v| p <= v },
        :length       => Rule.rule("$ can't be longer or shorter than #.") { |p,v| p.length == v },
        :min_length   => Rule.rule("$ must be longer than #.") { |p,v| p.length >= v },
        :max_length   => Rule.rule("$ must be shorter than #.") { |p,v| p.length <= v },
        :in           => Rule.rule("$ must be included in #.") { |p,v| v.include? p },
        :contains     => Rule.rule("$ must include #") { |p,v| p.include? v },
        :regex        => Rule.rule("$ failed validation.") { |p,v| v.match(p) rescue false },
        :validator    => Rule.rule("$ failed validation.") { |p,v| v.call p }
      }
    end
  end
end

Boolean = Class.new Rack::TrueClass
