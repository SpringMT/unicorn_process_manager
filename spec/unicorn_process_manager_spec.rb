#!/usr/bin/env ruby
# encoding: UTF-8

require File.dirname(__FILE__) + '/spec_helper'

describe UnicornProcessManager do
  context :new do
    subject {UnicornProcessManager.new("test", "/home/hoge", 60, 3000)}
    it {should be_true}
  end
  context :usage do
    subject {UnicornProcessManager.new("test", "/home/hoge", nil, nil).usage}
    it {should be_true}
  end
end



