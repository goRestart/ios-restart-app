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

	def implode(message)         
		puts message.red
          	abort()
  	end

	def fetch_issue(issue_id)
		return @@client.Issue.find(issue_id)
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
	
	def transition(issue, transition_id, success, failure)
        	issue_transition = issue.transitions.build
        	if issue_transition.save('transition' => {'id' => transition_id})
               	then puts success.green
                else 
			implode(failure)
        	end
	end	
	
	def start_doing(issue) 
		available_transitions = @@client.Transition.all(:issue => issue)
		can_move_to_doing = available_transitions.map { |issue| issue.id  }.include? TRANSITIONS::START_DOING
		if can_move_to_doing
		then 
			transition(issue, TRANSITIONS::START_DOING, 'Started doing ticket', 'Need backup cannot start doing this ticket!!')
		else
			implode("Sorry, I was not able to start doing this ticket")
		end
	end

	def start_reviewing(issue)
		available_transitions = @@client.Transition.all(:issue => issue)
		is_being_done = available_transitions.map { |issue| issue.id  }.include? TRANSITIONS::REQUEST_REVIEW
		if is_being_done
		then
			puts 'Requesting review'.green
			transition(issue, TRANSITIONS::REQUEST_REVIEW, 'Successfully requested review', 'Need backup reviewing!!')
		else
			implode("Sorry, I was not able to request review for this ticket")
		end
	end
	
	def mark_as_done(issue)
        	available_transitions = @@client.Transition.all(:issue => issue)
        	is_being_done = available_transitions.map { |issue| issue.id  }.include? TRANSITIONS::REQUEST_REVIEW
		if !is_being_done 
		then
			puts 'You should have moved your ticket to doing'.yellow
			puts "Nevermind. I'll do it for you"
        		mark_as_doing(issue)
		end
        	start_reviewing(issue)	
        	transition(issue, TRANSITIONS::MERGE, 'Successfully merged your ticket. Nothing to see here', 'Need backup mergin!!')
	end
end	
