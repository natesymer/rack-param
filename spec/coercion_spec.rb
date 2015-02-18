#!/usr/bin/env ruby

require_relative "./spec_helper.rb"

describe Rack::Parameter do
  before :all do
    @p = {
      :date => "2014/8/4",
      :time => "Thu Nov 29 14:33:20 GMT 2001",
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
      :should_fail => "asdfasdf",
      :dont_coerce => "1"
    }
  end
  
  context "when coercing types" do
    it "parses a Date" do
      @r.param :date, Date
      expect(@r.params["date"]).to eq(Date.new(2014, 8, 4))
    end
    
    it "parses a Time" do
      @r.param :time, Time
      expect(@r.params["time"].to_i).to eq(1007044400)
    end
    
    it "parses a DateTime" do
      @r.param :datetime, DateTime
      expect(@r.params["datetime"].to_s).to eq("2012-02-09T20:05:33+00:00")
    end
    
    it "parses an Array" do
      @r.param :array, Array
      expect(@r.params["array"]).to eq(["asdf", "asdf", "asdf"])
    end
    
    it "parses a Hash" do
      @r.param :hash, Hash
      expect(@r.params["hash"]).to eq({"key" => "value", "this" => "that", "foo" => "bar"})
    end
    
    it "coerces a Boolean" do
      @r.param :true, Boolean
      @r.param :t, Boolean
      @r.param :yes, Boolean
      @r.param :y, Boolean
      @r.param :one, Boolean
      
      expect(@r.params["true"]).to eq(true)
      expect(@r.params["t"]).to eq(true)
      expect(@r.params["yes"]).to eq(true)
      expect(@r.params["y"]).to eq(true)
      expect(@r.params["one"]).to eq(true)
    end
    
    it "coerces an Integer" do
      @r.param :integer, Integer
      expect(@r.params["integer"]).to eq(42)
    end
    
    it "coerces a Float" do
      @r.param :float, Float
      expect(@r.params["float"]).to eq(420.42)
    end
    
    it "\"coerces\" a String" do
      @r.param :string, String
      expect(@r.params["string"]).to eq("foo bar baz")
    end
    
    it "errors out on unrecognized types" do
      expect { @r.param :should_fail, Date }.to raise_error(Rack::ParameterError)
    end
    
    it "doesn't coerce when the coerce option is set to false" do
      @r.param :dont_coerce, Integer, :coerce => false
      expect(@r.params["dont_coerce"]).to eq(@p[:dont_coerce])
      expect(@r.params["dont_coerce"].class).to eq(String)
    end
  end
end