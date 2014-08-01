#!/usr/bin/env ruby

require_relative "./spec_helper.rb"

describe "Rack::Param" do
  it "can parse parameters" do
    @r.param :foo, Integer, :required => true, :in => (1..5)
    @r.param :bar, Integer, :required => true, :in => 
    
    
    
    assert @r.params["foo"] == @foo
  end
end