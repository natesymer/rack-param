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
      @r.param :not_a_param, String, :required => true
      @r.param :required, String, :required => true
      
      expect(@r.parameter_errors.count).to eq(1)
      expect(@r.params["required"]).to eq("This is very important data")
    end
    
    it "checks a parameter based on :blank" do
      @r.param :blank, String, :blank => true
      @r.param :string, String, :blank => false
      
      expect(@r.parameter_errors).to be_empty
    end
    
    it "checks a parameter based on :greater_than" do
      @r.param :int_six, Integer, :greater_than => 5
      
      expect(@r.parameter_errors).to be_empty
    end
    
    it "checks a parameter based on :less_than" do
      @r.param :int_three, Integer, :less_than => 4
      
      expect(@r.parameter_errors).to be_empty
    end
    
    it "checks a parameter based on :min" do
      
      expect(@r.parameter_errors).to be_empty
    end
    
    it "checks a parameter based on :max" do
      
      expect(@r.parameter_errors).to be_empty
    end
    
    it "checks a parameter based on :length" do
      
      expect(@r.parameter_errors).to be_empty
    end
    
    it "checks a parameter based on :min_length" do
      
      expect(@r.parameter_errors).to be_empty
    end
    
    it "checks a parameter based on :max_length" do
      
      expect(@r.parameter_errors).to be_empty
    end
    
    it "checks a parameter based on :in" do
      
      expect(@r.parameter_errors).to be_empty
    end
    
    it "checks a parameter based on :contains" do
      
      expect(@r.parameter_errors).to be_empty
    end
    
    it "checks a parameter based on :regex" do
      
      expect(@r.parameter_errors).to be_empty
    end
    
    it "checks a parameter based on :validator" do
      
      expect(@r.parameter_errors).to be_empty
    end
  end
end