#/usr/bin/env ruby

require "rack"
require "time"
require "date"

Boolean = Class.new TrueClass # giant hack

module Rack
  ParameterError = Class.new StandardError
  
  class ::String
    def truthy?; (/^(true|t|yes|y|1|on)$/ =~ downcase) != nil; end
    def falsey?; (/^(false|f|no|n|0|off)$/ =~ downcase) != nil; end
  end
  
  class Rule
    def self.rule message, &block; new message, &block; end
    
    def initialize message, &block
      @blk = block
      @msg = message
    end
    
    def validate! param, val, emsg=nil
      raise ParameterError, (emsg || @msg).sub('$',"`#{param}`").sub('#',"`#{val}`") unless @blk.call(param, val)
    end
  end
  
  class Request
    alias_method :raw_params, :params
    def params; @processed_parameters ||= {}; end
    
    def param name, type, opts={}
			name = name.to_s
      opts = Hash[opts.map { |k,v| [k.to_sym,v] }]

      if raw_params.member? name
        v = raw_params[name] || params[name]
        
        if !v.is_a?(type) && ((opts.member?(:coerce) && opts[:coerce]) || !opts.member?(:coerce))
          begin
            v = self.class.coercers[type].call type, v
          rescue StandardError
            raise ParameterError, "Parameter `#{name}` is not a valid #{type}."
          end
        end
        
        # will raise an error on an invalid param
        opts.select { |k,_| self.class.rules.member? k }
            .each { |k,arg| self.class.rules[k].validate! v, arg, opts[:error_message] }
        
        v = opts[:transform].to_proc.call v if opts.member?(:transform)
        params[name] = v
      else
        raise ParameterError, "Parameter #{name} is required." if opts.member?(:required) && opts[:required] && !opts.member?(:default)
        params[name] = opts[:default]
      end
    end
    
    def self.coercers
      @coercers ||= {
        Date     => lambda { |t,v| Date.parse v },
        Time     => lambda { |t,v| Time.parse v },
        DateTime => lambda { |t,v| DateTime.parse v },
        Array    => lambda { |t,v| v.split(',') },
        Hash     => lambda { |t,v| Hash[v.split(',').map { |c| c.split ':', 2 }] },
        Boolean  => lambda { |t,v| v.falsey? ? false : (v.truthy? ? true : raise(StandardError)) }
      }
      @coercers.default_proc = lambda { |h, k| h[k] = lambda { |t,v| method(t.to_s.to_sym).call v } }
      @coercers
    end
    
    def self.rules
      @rules ||= {
        :blank        => Rule.rule("$ cannot be blank.")                   { |p,v| v == (p.empty? rescue false) },
        :greater_than => Rule.rule("$ can't be less than #.")              { |p,v| p > v },
        :less_than    => Rule.rule("$ can't be greater than #.")           { |p,v| p < v },
        :min          => Rule.rule("$ can't be less than #.")              { |p,v| p >= v },
        :max          => Rule.rule("$ can't be greater than #.")           { |p,v| p <= v },
        :length       => Rule.rule("$ can't be longer or shorter than #.") { |p,v| p.length == v },
        :min_length   => Rule.rule("$ must be longer than #.")             { |p,v| p.length >= v },
        :max_length   => Rule.rule("$ must be shorter than #.")            { |p,v| p.length <= v },
        :in           => Rule.rule("$ must be included in #.")             { |p,v| v.include? p },
        :contains     => Rule.rule("$ must include #")                     { |p,v| p.include? v },
        :regex        => Rule.rule("$ failed validation.")                 { |p,v| v.match(p) rescue false },
        :validator    => Rule.rule("$ failed validation.")                 { |p,v| v.call p }
      }
    end
  end
end
