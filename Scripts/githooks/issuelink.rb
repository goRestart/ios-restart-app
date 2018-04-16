#!/usr/bin/env ruby
# encoding: utf-8

require 'rubygems'
require 'pp'
require 'jira-ruby'
require 'yaml'
require 'colorize'
require_relative './jirabureau.rb'


bureau = JiraBureau.new('ios-automation@letgo.com', 'Ambatana2015')
issue_id = 'ABIOS-3823'
issue = bureau.fetchIssue(issue_id)


puts bureau.issueLink(issue_id)
puts issue.fields["project"]
