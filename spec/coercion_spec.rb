#!/usr/bin/env ruby

require_relative "./spec_helper.rb"
require_relative File.dirname(File.dirname(__FILE__)) + "/lib/rack/param.rb"

describe Rack::Param do
  before :each do
    @p = {
      :date => "2014/8/4",
      :time => "12:00",
      :array => "asdf,asdf,asdf",
      :datetime => "2012-02-09 20:05:33",
      :hash => "key:value,this:that,foo:bar",
      :true => "true",
      :t => "t",
      :yes => "yes",
      :y => "y",
      :one => "1",
      :integer => "42",
      :float => "420.42",
      :string => "foo bar baz",
      :should_fail => "asdfasdf"
    }
    @e = env @p
    @r = Rack::Request.new @e
  end
  
  context "when coercing types" do
    it "parses a Date" do
      @r.param :date, Date
      
     # expect(@r.parameter_errors).to be_empty
      expect(@r.params["date"]).to eq(Date.new(2014, 8, 4))
    end
    
    it "parses a Time" do
      @r.param :time, Time
      
   #   expect(@r.parameter_errors).to be_empty
      expect(@r.params["time"].to_i).to eq(1407340800)
    end
    
    it "parses a DateTime" do
      @r.param :datetime, DateTime
      
    #  expect(@r.parameter_errors).to be_empty
      expect(@r.params["datetime"].to_s).to eq("2012-02-09T20:05:33+00:00")
    end
    
    it "parses an Array" do
      @r.param :array, Array
      
    #  expect(@r.parameter_errors).to be_empty
      expect(@r.params["array"]).to eq(["asdf", "asdf", "asdf"])
    end
    
    it "parses a Hash" do
      @r.param :hash, Hash
      
     # expect(@r.parameter_errors).to be_empty
      expect(@r.params["hash"]).to eq({"key" => "value", "this" => "that", "foo" => "bar"})
    end
    
    it "coerces a Boolean" do
      @r.param :true, Boolean
      @r.param :t, Boolean
      @r.param :yes, Boolean
      @r.param :y, Boolean
      @r.param :one, Boolean
      
    #  expect(@r.parameter_errors).to be_empty
      expect(@r.params["true"]).to eq(true)
      expect(@r.params["t"]).to eq(true)
      expect(@r.params["yes"]).to eq(true)
      expect(@r.params["y"]).to eq(true)
      expect(@r.params["one"]).to eq(true)
    end
    
    it "coerces an Integer" do
      @r.param :integer, Integer
      
   #   expect(@r.parameter_errors).to be_empty
      expect(@r.params["integer"]).to eq(42)
    end
    
    it "coerces a Float" do
      @r.param :float, Float
      
     # expect(@r.parameter_errors).to be_empty
      expect(@r.params["float"]).to eq(420.42)
    end
    
    it "\"coerces\" a String" do
      @r.param :string, String
      
     # expect(@r.parameter_errors).to be_empty
      expect(@r.params["string"]).to eq("foo bar baz")
    end
    
    it "errors out on unrecognized types" do
      @r.param :should_fail, Regexp
    end
  end
end