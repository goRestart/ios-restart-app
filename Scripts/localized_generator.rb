#!/usr/bin/env ruby
# encoding: utf-8

require 'erb'
require 'fileutils'
require 'micro-optparse'
require 'colorize'
require_relative 'helpers/string'

class LocaleKey

  # type represends system type (1 = Android, 2 = iPhone)
  #
  def initialize(keyword)
    @keyword = keyword
  end

  def keyword
    @keyword
  end

  def keyword_constant_swift
    @keyword.space_to_underscore.strip_tag.camel_case.uncapitalize
  end

end

def show_error(error_string)
  puts 'Error!'.red
  puts error_string
  exit
end

def copy_with_path(src, dst)
  FileUtils.mkdir_p(File.dirname(dst))
  FileUtils.cp(src, dst)
end

def read_from_ios(file, terms)
  puts "Parsing filename : #{file}"

  f = nil
  begin
    f = File.open(file, "r") 
  rescue Exception => e
    puts "File not found"
    return
  end

  current_comment = nil
  f.each_line do |line|
    if line.start_with?("\"")
      uglyKey = line.split("=", 2).first
      key = uglyKey[/\"(.*?)\"/m, 1]
      # puts "Key #{key}"
      add_key(terms, key)
    end
  end
end

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
  input_file = File.open("#{File.dirname(__FILE__)}/templates/ios_localized_swift.erb", "rb")
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


