#!/usr/bin/env ruby
# encoding: UTF-8

require File.dirname(__FILE__) + '/spec_helper'

describe UnicornProcessManager do
  context :new do
    subject {UnicornProcessManager.new("test", "/home/hoge")}
    it {should be_true}
  end
  context :usage do
    subject {UnicornProcessManager.new("test", "/home/hoge").usage}
    it {should be_true}
  end
end



