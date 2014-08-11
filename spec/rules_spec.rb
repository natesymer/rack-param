#!/usr/bin/env ruby

require_relative "./spec_helper.rb"

describe Rack::Parameter do
  before :all do
    @p = {
      :int_three => "3",
      :int_six => "6",
      :string => "mary had a little lamb",
      :callback_url => "http://www.example.com/",
      :blank => "",
      :required => "This is very important data",
      :array => "one,two,three,four"
    }
  end
  
  context "when given rules" do
    it "checks a parameter based on :required" do
      expect { @r.param :not_a_param, String, :required => true }.to raise_error(Rack::ParameterError)
      expect { @r.param :required, String, :required => true }.to_not raise_error
    end
    
    it "checks a parameter based on :blank" do
      expect { @r.param :blank, String, :blank => true }.to_not raise_error
      expect { @r.param :string, String, :blank => false }.to_not raise_error
    end
    
    it "checks a parameter based on :greater_than" do
      expect { @r.param :int_six, Integer, :greater_than => 5 }.to_not raise_error
    end
    
    it "checks a parameter based on :less_than" do
      expect { @r.param :int_three, Integer, :less_than => 4 }.to_not raise_error
    end
    
    it "checks a parameter based on :min" do
      expect { @r.param :int_three, Integer, :min => 3 }.to_not raise_error
      expect { @r.param :int_three, Integer, :min => 4 }.to raise_error(Rack::ParameterError)
    end
    
    it "checks a parameter based on :max" do
      expect { @r.param :int_three, Integer, :max => 3 }.to_not raise_error
      expect { @r.param :int_three, Integer, :max => 2 }.to raise_error(Rack::ParameterError)
    end
    
    it "checks a parameter based on :length" do
      expect { @r.param :string, String, :length => 22 }.to_not raise_error
      expect { @r.param :string, String, :length => 10 }.to raise_error(Rack::ParameterError)
    end
    
    it "checks a parameter based on :min_length" do
      expect { @r.param :string, String, :min_length => 20 }.to_not raise_error
      expect { @r.param :string, String, :min_length => 30 }.to raise_error(Rack::ParameterError)
    end
    
    it "checks a parameter based on :max_length" do
      expect { @r.param :string, String, :max_length => 25 }.to_not raise_error
      expect { @r.param :string, String, :max_length => 20 }.to raise_error(Rack::ParameterError)
    end
    
    it "checks a parameter based on :in" do
      expect { @r.param :int_three, Integer, :in => [3] }.to_not raise_error
      expect { @r.param :int_three, Integer, :in => [] }.to raise_error(Rack::ParameterError)
    end
    
    it "checks a parameter based on :contains" do
      expect { @r.param :array, Array, :contains => "one" }.to_not raise_error
      expect { @r.param :array, Array, :contains => "three hundred" }.to raise_error(Rack::ParameterError)
    end
    
    it "checks a parameter based on :regex" do
      expect { @r.param :string, String, :regex => /^mary.+lamb$/ }.to_not raise_error
      expect { @r.param :string, String, :regex => /^bo.+peep$/ }.to raise_error(Rack::ParameterError)
    end
    
    it "checks a parameter based on :validator" do
      expect { @r.param :int_three, Integer, :validator => lambda { |p| p < 5 && p > 0 } }.to_not raise_error
      expect { @r.param :int_three, Integer, :validator => lambda { |p| p < 0 } }.to raise_error(Rack::ParameterError)
    end
  end
end