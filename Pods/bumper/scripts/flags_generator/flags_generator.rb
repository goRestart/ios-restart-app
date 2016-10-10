#!/usr/bin/env ruby
# encoding: utf-8

require 'rubygems'
require "json"
require 'erb'
require 'micro-optparse'

require_relative 'helpers/string'
require_relative 'helpers/flag'
require_relative 'helpers/flags'

def show_error(error_string)
  puts 'Error!'.red
  puts error_string
  exit -1
end

def generate_flags(destination_folder)
	puts "Writing on: #{destination_folder}".cyan
	input_file = File.open("#{File.dirname(__FILE__)}/templates/bumper_features.erb", "rb")
	template = input_file.read
	input_file.close
	renderer = ERB.new(template)
	output = renderer.result()
	output_file = File.new(destination_folder+"BumperFeatures.swift", "w")
	output_file.write(output)
	output_file.close
end


def read_flags(source_json)
	puts "Processing: #{source_json}".cyan

	file = File.open(source_json, "rb")
	json = file.read
	parsed = JSON.parse(json)

	show_error "Json root must be an array" unless parsed.kind_of?(Array)

	flagsArray = Array.new
	parsed.each do |jsonFlag|
		name = jsonFlag["name"]
		show_error "Flag needs to have a name" if name.nil? || name.empty?
		values = jsonFlag["values"]
		show_error "Flag #{name} needs to have values" if values.nil? || values.empty?
		show_error "Flag #{name} values needs to be an array of strings" unless values.kind_of?(Array)
		description = jsonFlag["description"]
		show_error "Flag #{name} needs to have a description value" if description.nil? || description.empty?
		flag = Flag.new(name, values, description)
		flag.print
		flagsArray << flag
	end 
	return Flags.new(flagsArray)
end

# Parsing and commandline checks

show_error 'No parameters specified. Use the flag --help to see them all.' unless ARGV.size > 0

options = Parser.new do |p|
  p.banner = 'flags_generator (c) 2016 Letgo <eli.kohen@letgo.com>'
  p.version = '0.1'
  p.option :source, 'Json definition source', :default => '', :short => 's'
  p.option :destination, 'Generated file destination folder', :default => '', :short => 'd'
end.process!

source_json = options[:source]
destination_folder = options[:destination]

show_error "File #{source_json} doesn't exist" unless File.file?(source_json)
show_error "Folder #{destination_folder} doesn't exist" unless File.exist?(destination_folder)

@flags = read_flags(source_json)
generate_flags(destination_folder)
