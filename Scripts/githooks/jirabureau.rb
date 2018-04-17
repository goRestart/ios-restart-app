#!/usr/bin/env ruby
# encoding: utf-8

require 'rubygems'
require 'pp'
require 'jira-ruby'
require 'yaml'
require 'colorize'

module TRANSITIONS
	BACK_TO_WORK = '71'
	BACK_TO_TODO = '201'
	REJECT = '51'
	MARK_AS_DONE = '111'
	START_TESTING = '21'
	BLOCKED = '141'
	REQUEST_REVIEW = '171'
	MERGE = '181'
	START_DOING = '211'
end

module Exceptions
	class IssueNotFound < StandardError 
  		def url
    			@url
  		end
		def initialize(url)
			@url = url
		end
	end
	class TransitionNotAvailable < StandardError
		def initialize(url) 
			@url = url
		end

		def url
			@url
		end
	end
end

class JiraBureau

	@@client
 	
	@@site = 'https://ambatana.atlassian.net'

	def initialize(username, password)
		options = {
	        	:username => username,
              		:password => password,
              		:site     => @@site,
              		:context_path => '',
              		:auth_type          => :cookie,
              		:read_timeout => 120
            	}
		@@client = login(options)		
	end

	def login(options)
        	return JIRA::Client.new(options)
	end

	def fetch_issue(issue_id)
		url = issue_link(issue_id)
		begin
			issue = @@client.Issue.find(issue_id)
		rescue JIRA::HTTPError => ex
			raise Exceptions::IssueNotFound.new(url)
		end
		raise Exceptions::IssueNotFound.new(url) if issue.nil?
		return issue
	end
	
	def issue_link(issue_id)
		return @@site + '/browse/' + issue_id
	end 
	
	def list_available_transitions_for(issue) 
		puts 'Available transitions :)'
		puts ''
		available_transitions = @@client.Transition.all(:issue => issue)
		available_transitions.each {|ea| puts "#{ea.name} (id #{ea.id})" }
	end
	
	def transition(issue, issue_id, transition_id)
        	issue_transition = issue.transitions.build
		url = issue_link(issue_id)
        	raise Exceptions::TransitionNotAvailable(url) if issue_transition.save('transition' => {'id' => transition_id}) 
	end	
	
	def start_doing(issue, issue_id) 
		transition(issue, issue_id, TRANSITIONS::START_DOING)
	end

	def start_reviewing(issue, issue_id)
		transition(issue, issue_id, TRANSITIONS::REQUEST_REVIEW)
	end
	
	def mark_as_done(issue, issue_id)
		available_transitions = @@client.Transition.all(:issue => issue)
		is_being_done = available_transitions.map { |issue| issue.id  }.include? TRANSITIONS::REQUEST_REVIEW
		if !is_being_done 
		then
        		mark_as_doing(issue)
		end
        	start_reviewing(issue)	
        	transition(issue, TRANSITIONS::MERGE)
	end
end	
