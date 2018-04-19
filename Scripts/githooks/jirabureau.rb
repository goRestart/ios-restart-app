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
		def initialize(url, transition) 
			@url = url
			@transition = transition
		end

		def transition
			@transition
		end
	
		def url
			@url
		end
	end

	class VersionNotAvailable < StandardError
		def initialize(version)
			@version = version
		end

		def version
			@version
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

	def transition_name(transition_id) 
		if transition_id == TRANSITIONS::START_DOING then return 'START DOING'
		elsif transition_id == TRANSITIONS::REQUEST_REVIEW then return 'REQUESTING REVIEW'
		elsif transition_id == TRANSITIONS::MERGE then return 'MERGED'
		else return 'OTHER'
		end
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
        	raise Exceptions::TransitionNotAvailable(url, transition_id) if issue_transition.save('transition' => {'id' => transition_id}) 
	end	
	
	def start_doing(issue, issue_id) 
		transition(issue, issue_id, TRANSITIONS::START_DOING)
	end

	def start_reviewing(issue, issue_id)
		transition(issue, issue_id, TRANSITIONS::REQUEST_REVIEW)
	end
	
	def mark_as_done(issue, issue_id)
        	transition(issue, TRANSITIONS::MERGE)
	end

	def start_testing(issue, issue_id) 
		transition(issue, TRANSITIONS::START_TESTING)
	end

	def compare(version1, version2) 
		splitted1 = version1.split('.').map {|n| Integer(n) }
		splitted2 = version2.split('.').map {|n| Integer(n) }

		if (splitted1[0] > splitted2[0]) then return true end
		if (splitted1[0] < splitted2[0]) then return false end
		if (splitted1[1] > splitted2[1]) then return true end
		if (splitted1[1] < splitted2[1]) then return false end
		if (splitted1[2] >= splitted2[2]) then return true end
		return false	
	end

	def next_unreleased_version(project)
		valid_versions = project.versions.select { |v| v.name[/([0-9]+)\.([0-9]+)\.([0-9]+)/]  }
		return valid_versions.select { |version| version.released == false }.first 
	end

	def tag_next_version(issue, issue_id)
		project = @@client.Project.find('ABIOS')
		next_version = next_unreleased_version(project)
		tag(issue, issue_id, next_version)
	end

	def tag(issue, issue_id, version) 
		raise Exceptions::VersionNotAvailable(version) if issue.save({ "fields" => { "fixVersions"  => [version] } })
	end

	def force_mark_as_done(issue, issue_id)
		available_transitions = @@client.Transition.all(:issue => issue)
		is_being_done = available_transitions.map { |issue| issue.id  }.include? TRANSITIONS::REQUEST_REVIEW
		if !is_being_done
		then
			start_doing(issue)
		end
		start_reviewing(issue)
		mark_as_done(issue,issue_id)
	end
end	
