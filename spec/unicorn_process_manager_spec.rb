#!/usr/bin/env ruby
# encoding: UTF-8

require File.dirname(__FILE__) + '/spec_helper'

describe UnicornProcessManager do
  context :new do
    subject {UnicornProcessManager.new(app_env: "test", app_home: "/home/hoge", timeout: 60, port: 3000)}
    it {should be_true}
  end
  context :usage do
    subject {UnicornProcessManager.new(app_env: "test", app_home: "/home/hoge", timeout: nil, timeout: nil).usage}
    it {should be_true}
  end
end


