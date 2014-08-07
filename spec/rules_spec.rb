#!/usr/bin/env ruby

require_relative "./spec_helper.rb"

describe Rack::Param, "Rack::Request#param" do
  before :each do
    @p = {
      :int_three => "3",
      :int_six => "6",
      :string => "mary had a little lamb",
      :callback_url => "http://www.example.com/",
      :blank => "",
      :required => "This is very important data"
    }
    @e = env @p
    @r = Rack::Request.new @e
  end
  
  context "when given rules" do
    it "checks a parameter based on :required" do
      
    end
    
    it "checks a parameter based on :blank" do
      
    end
    
    it "checks a parameter based on :greater_than" do
      
    end
    
    it "checks a parameter based on :less_than" do
      
    end
    
    it "checks a parameter based on :min" do
      
    end
    
    it "checks a parameter based on :max" do
      
    end
    
    it "checks a parameter based on :length" do
      
    end
    
    it "checks a parameter based on :min_length" do
      
    end
    
    it "checks a parameter based on :max_length" do
      
    end
    
    it "checks a parameter based on :in" do
      
    end
    
    it "checks a parameter based on :contains" do
      
    end
    
    it "checks a parameter based on :regex" do
      
    end
    
    it "checks a parameter based on :validator" do
      
    end
  end
end