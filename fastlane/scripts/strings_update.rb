#!/usr/bin/env ruby
# encoding: utf-8

require 'rubygems'
require 'erb'
require 'fileutils'
require 'micro-optparse'
gem 'google_drive', '>=2.0.0'
require 'google_drive'
require 'byebug'

require_relative 'helpers/String'
require_relative 'helpers/Term'

APP_I18N_PATH = "Ambatana/res/i18n"
LGRESOURCES_I18N_PATH = "modules/LGResources/LGResources/Assets/i18n"
LGRESOURCES_LOCALIZED_STRINGS_PATH = "modules/LGResources/LGResources/Classes"

# Moves a folder
  # Params:
  # +src+:: folder tobe moved
  # +dst+:: new path where to move the folder to
def move_with_path(src, dst)
  FileUtils.mkdir_p(File.dirname(dst))
  if File.dirname(src) != File.dirname(dst)
    FileUtils.cp(src, dst)
    FileUtils.rm(src)
  end
end

def show_error(error_string)
  puts 'Error!'.red
  puts error_string
  exit 1
end

# Given a template creates a new file
  # Params:
  # +template_name+:: a .erb file template
  # +target_directory+:: folder where the new file will be created
  # +generated_file_name+:: name of the new file
def process_template(template_name, target_directory, generated_file_name)
  input_file = File.open("#{File.dirname(__FILE__)}/templates/"+template_name, "rb")
  template = input_file.read
  input_file.close
  renderer = ERB.new(template)
  output = renderer.result().chop #Chop to remove last line jump
  output_file = File.new(generated_file_name, "w")
  output_file.write(output)
  output_file.close
  move_with_path(generated_file_name, target_directory+generated_file_name)
end

# Generation for iOS

# Creates a new localized strings file for a given language
  # Params:
  # +language+:: the language to localize
  # +target_directory+:: folder where the new file will be created
def generate_ios(language, target_directory)
  @current_lang = language
  process_template 'ios_localizable.erb', target_directory, "Localizable.strings"

  # Check wrong generation
  if File.zero?(target_directory+"Localizable.strings")
    puts 'Wrong Localizable.strings generation!'.red
    exit 1
  end
end

# Creates a LGLocalizedString.swift file with the keys to access the translated string
  # Params:
  # +target_directory+:: folder where the file will be created
def generate_ios_constants(target_directory)
  process_template 'ios_localized_swift.erb', target_directory, 'LGLocalizedString.swift'
  puts ' > '+'LGLocalizedString.swift'.yellow
end

#Prints on screen all the unused keys and also marks that keys on spreadsheet as unused
def check_unused_ios(worksheet, from_row, to_row, target_directory, mark, remove)
  if(mark) 
    puts "\nUNUSED IOS KEYS:"  
  end
  if(remove)
    puts "\nRemoving keys:"
  end
  for row in from_row..to_row
    key = worksheet[row, 1]
    unless key.blank?
      term = Term.new(key)
      if term.restriction == 'i' || term.restriction == nil
        if !term.is_comment?
          result = (`grep -rnw './Ambatana/src' -e #{term.keyword_constant_swift} | wc -l`).strip() #find_text_on_ios_files(target_directory,term.keyword_iphone_constant)
          if(result == "1")
            puts term.keyword_constant_swift
            if(mark)
              #modifiying key on spreadsheet by prepending [u] to mark key as unused
              worksheet[row, 1] = '[u]'+key
              worksheet.save()
            end
            if(remove)
              worksheet.delete_rows(row, 1)
              worksheet.save()
            end
          end
        else
          puts "\n==> Group:"
        end
      end
    end
  end
end


def wti_push(ios_path)
  puts "Updating base Localizable.strings on wti"
  generate_valids()
  system "wti push -c #{ios_path}.wti"
end

def wti_pull(ios_path)
  puts "Executing LG wti pull script for 'Localizable.strings'"
  system "ruby #{File.dirname(__FILE__)}/helpers/wti.rb -r Localizable.strings -p #{LGRESOURCES_I18N_PATH}"
  puts "Executing LG wti pull script for 'InfoPlist.strings'"
  system "ruby #{File.dirname(__FILE__)}/helpers/wti.rb -r InfoPlist.strings -p #{APP_I18N_PATH}"
end

def drive_pull(ios_path)
  generate_all()
  generate_ios_constants("#{ios_path}#{LGRESOURCES_LOCALIZED_STRINGS_PATH}/")
  system "cp Localizable.strings #{ios_path}#{LGRESOURCES_I18N_PATH}/Base.lproj/Localizable.strings"
  system "cp Localizable.strings #{ios_path}#{LGRESOURCES_I18N_PATH}/en.lproj/Localizable.strings"
  system "rm Localizable.strings"
end

def generate_valids()
  @terms = @valid_terms
  generate_ios "base", "./"
end

def generate_all()
  @terms = @all_terms
  generate_ios "base", "./"
end

# Parsing and commandline checks

options = Parser.new do |p|
  p.banner = 'Strings-update'
  p.version = '0.1'
  p.option :spreadsheet, 'Spreadsheet containing the localization info', :default => 'LetGo'
  p.option :output_ios, 'Path to the iOS project directory', :default => './', :short => 'i'
  p.option :keep_keys, 'Whether to maintain original keys or not', :default => true, :short => 'k'
  p.option :check_unused, 'Whether to check unused keys on project', :default => false , :short => 'c'
  p.option :check_unused_mark, 'If checking keys -> mark them on spreadsheet prepending [u]', :default => false , :short => 'm'
  p.option :check_unused_remove, 'If checking keys -> remove them from spreadsheet', :default => false , :short => 'r'
end.process!

ios_path = options[:output_ios]
spreadsheet = options[:spreadsheet]
check_unused = options[:check_unused]
check_unused_mark = options[:check_unused_mark]
check_unused_remove = options[:check_unused_remove]
keep_keys = options[:keep_keys]

# Get the spreadsheet from Google Drive
puts 'Logging in to Google Drive. After accepting permissions in the given url paste code below'

begin 
  session = GoogleDrive.saved_session(ENV["STRINGS_CREDENTIALS_PATH"], nil, ENV["STRINGS_CLIENT_ID"], ENV["STRINGS_CLIENT_SECRET"])
rescue
  show_error 'Couldn\'t access Google Drive. Check your credentials!'
  exit -1
end

# Recover our spreadsheets
puts 'Logged.'.cyan
puts "Searching for #{spreadsheet}..."
matching_spreadsheets = []

session.spreadsheets.each do |s|
  matching_spreadsheets << s if s.title.downcase.include?(spreadsheet.downcase) && s.title.include?('[Localizables]')
end

if matching_spreadsheets.count > 1
  puts 'Found:'.cyan
  matching_spreadsheets.each { |ms| puts ms.title.red }
  show_error 'More than one match found. You have to be more specific!'
elsif matching_spreadsheets.count == 0
  show_error "Unable to find any spreadsheet matching your criteria: #{spreadsheet}"
end

found_spreadsheet = matching_spreadsheets[0]
puts "Found one match: #{found_spreadsheet.title}".cyan

# Processing the spreadsheet

puts "Processing #{found_spreadsheet.title}..."
worksheet = found_spreadsheet.worksheets[0]
show_error 'Unable to retrieve the first worksheet from the spreadsheet' if worksheet.nil?

first_valid_row_index = nil
last_valid_row_index = nil

for row in 1..worksheet.max_rows
  first_valid_row_index = row if worksheet[row, 1].downcase == '[key]'
  last_valid_row_index = row if worksheet[row, 1].downcase == '[end]'
end

show_error 'Invalid format: Could not find any [key] keyword in the A column of the first worksheet' if first_valid_row_index.nil?
show_error 'Invalid format: Could not find any [end] keyword in the A column of the first worksheet' if last_valid_row_index.nil?
show_error 'Invalid format: [end] must not be before [key] in the A column' if first_valid_row_index > last_valid_row_index

key_comments = -1
key_valids = -1
key_base = -1

for column in 2..worksheet.max_cols
  col_text = worksheet[first_valid_row_index, column]
  if col_text.downcase == '[comments]' 
    key_comments = column
  elsif col_text.downcase == '[x]'
    key_valids = column
  elsif col_text.downcase.gsub('*','') == 'base'
    key_base = column
  end
end

show_error 'Invalid format: Could not find any base column on the spreadsheet' if key_base == -1

puts 'Building terminology in memory...'

@terms = []
@valid_terms = []
@all_terms = []
first_term_row = first_valid_row_index+1
last_term_row = last_valid_row_index-1

for row in first_term_row..last_term_row
  key = worksheet[row, 1]
  unless key.blank?
    term_comment = nil
    term_comment = worksheet[row, key_comments] unless key_comments == -1
    term = Term.new(key,term_comment,keep_keys)
    term_text = worksheet[row, key_base]
    term.store_value("base", term_text)

    if(term_text.blank?)
      puts "Warning: Missing ".red+"base".cyan+" for #{key}".red
    end

    if key_valids != -1
      @valid_terms << term unless worksheet[row, key_valids].downcase != 'x'
    end
    @all_terms << term
  end
end

puts 'Loaded.'.cyan

puts 'Uploading valid strings to wti...'.cyan
wti_push(ios_path)
puts 'Updating translations from wti...'.cyan
wti_pull(ios_path)
puts 'Adding not-yet validated terms to base and localizables...'.cyan
drive_pull(ios_path)

puts 'Done! - Locale generation went smoothly :)'.green

if(check_unused || check_unused_remove)
  puts 'Checking unused strings'
  check_unused_ios(worksheet, first_term_row, last_term_row, ios_path, check_unused_mark, check_unused_remove)
end



