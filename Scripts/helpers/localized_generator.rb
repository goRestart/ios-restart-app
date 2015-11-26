#!/usr/bin/env ruby
# encoding: utf-8

require 'erb'
require 'fileutils'
require 'micro-optparse'
require 'colorize'
require_relative 'string'
require_relative 'localekey'

def add_key(terms, key)
  #searching for same key
  term = LocaleKey.new(key)
  found = false
  terms.each do |theTerm|
    if theTerm.keyword == term.keyword
      term = theTerm
      found = true
      break
    end
  end

  #if key not found create new one
  if !found
    terms << term
  end

end

def generate_ios_constants(target_directory)
  input_file = File.open("#{File.dirname(__FILE__)}/../templates/ios_localized_swift.erb", "rb")
  template = input_file.read
  input_file.close
  renderer = ERB.new(template)
  output = renderer.result()
  output_file = File.new('LGLocalizedString.swift', "w")
  output_file.write(output)
  output_file.close
  copy_with_path('LGLocalizedString.swift', target_directory+'LGLocalizedString.swift')
  FileUtils.rm('LGLocalizedString.swift')

  puts ' > '+'LGLocalizedString.swift'.yellow
end

# Parsing and commandline checks

show_error 'No parameters specified. Use the flag --help to see them all.' unless ARGV.size > 0

options = Parser.new do |p|
  p.banner = 'localized-generator (c) 2015 Ambatana <eli.kohen@letgo.com>'
  p.version = '1.0'
  p.option :source, 'Localizable source path', :default => '', :short => 's'
  p.option :destination, "Constants file destination dir", :default => '', :short => 'd'
end.process!

source_path = options[:source]
destination_path = options[:destination]

show_error 'You must provide a Source path' if source_path.blank?
show_error 'You must provide a Destination path' if destination_path.blank?

puts "Generating Localized Strings constants".white.on_green

#Reading data
@keys = []
read_from_ios(source_path, @keys)

generate_ios_constants destination_path

