#!/usr/bin/env ruby
# encoding: utf-8

require 'rubygems'
require 'erb'
require 'fileutils'
require 'micro-optparse'
gem 'google_drive', '>=1.0.0'
require 'google_drive'
require "google/api_client"
require "google/api_client/client_secrets"
require "google/api_client/auth/installed_app"

require_relative 'helpers/String'
require_relative 'helpers/Term'

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
  exit
end

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

def generate_ios(language, target_directory)
  @current_lang = language
  process_template 'ios_localizable.erb', target_directory, "Localizable.strings"

  # Check wrong generation
  if File.zero?(target_directory+"Localizable.strings")
    puts 'Wrong Localizable.strings generation!'.red
    exit 1
  end
end

#Prints on screen all the unused keys and also marks that keys on spreadsheet as unused
def check_unused_ios(worksheet, from_row, to_row, target_directory, mark)
  puts "\nUNUSED IOS KEYS:"
  for row in from_row..to_row
    key = worksheet[row, 1]
    unless key.blank?
      term = Term.new(key)
      if term.restriction == 'i' || term.restriction == nil
        if !term.is_comment?
          result = find_text_on_ios_files(target_directory,term.keyword_iphone_constant)
          if(result.length == 0)
            puts term.keyword_iphone_constant
            if(mark)
              #modifiying key on spreadsheet by prepending [u] to mark key as unused
              worksheet[row, 1] = '[u]'+key
            end
          end
        else
          puts "\n==> Group:"
        end
      end
    end
  end
  if(mark)
    worksheet.save()
  end
end

def find_text_on_ios_files(path,text)
  output = `find #{path} -type f -name *.m -exec grep -li \"#{text}\" {} +`
  output += `find #{path} -type f -name *.h ! -name *LocalizableConstants.h -exec grep -li \"#{text}\" {} +`
  return output
end

# Parsing and commandline checks

options = Parser.new do |p|
  p.banner = 'Strings-update (c) 2015 LetGo <eli.kohen@letgo.com>'
  p.version = '0.1'
  p.option :client, 'Client json path', :default => "#{File.dirname(__FILE__)}/drive-spreadsheet-secret.json", :short => 'u'
  p.option :spreadsheet, 'Spreadsheet containing the localization info', :default => 'LetGo'
  p.option :output_ios, 'Path to the iOS project directory', :default => './', :short => 'i'
  p.option :wti_upload, 'Enable wti push & pull', :default => true
  p.option :keep_keys, 'Whether to maintain original keys or not', :default => true, :short => 'k'
  p.option :check_unused, 'Whether to check unused keys on project', :default => false , :short => 'c'
  p.option :check_unused_mark, 'If checking keys -> mark them on spreadsheet prepending [u]', :default => false , :short => 'm'
end.process!

client_json_path = options[:client]
ios_path = options[:output_ios]
spreadsheet = options[:spreadsheet]
wti_upload = options[:wti_upload]
check_unused = options[:check_unused]
check_unused_mark = options[:check_unused_mark]
keep_keys = options[:keep_keys]

# Get the spreadsheet from Google Drive
puts 'Logging in to Google Drive...'

CREDENTIALS_PATH = Dir.home + '/.locgen/users.json'

def authorize(certificate)
  FileUtils.mkdir_p(File.dirname(CREDENTIALS_PATH))
  file_store = Google::APIClient::FileStore.new(CREDENTIALS_PATH)
  storage = Google::APIClient::Storage.new(file_store)

  auth = storage.authorize

  if auth.nil? || (auth.expired? && auth.refresh_token.nil?)
    client_secrets = Google::APIClient::ClientSecrets.load(certificate)
    flow = Google::APIClient::InstalledAppFlow.new(
      :client_id => client_secrets.client_id,
      :client_secret => client_secrets.client_secret,
      :scope => ['https://www.googleapis.com/auth/drive','https://spreadsheets.google.com/feeds/']
    )
    auth = flow.authorize(storage)
    puts "Credentials saved to #{CREDENTIALS_PATH}" unless auth.nil?
  end
  auth
end

client = Google::APIClient.new(
    :application_name => "Ztory Localizables",
    :application_version => "1.0"
  )
client.authorization = authorize(client_json_path)

access_token = client.authorization.access_token

begin
  # session = GoogleDrive.login(drive_user, drive_pass)
  session = GoogleDrive.login_with_oauth(access_token)
rescue
  show_error 'Couldn\'t access Google Drive. Check your credentials!'
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

puts 'Building terminology in memory...'

@terms = []
first_term_row = first_valid_row_index+1
last_term_row = last_valid_row_index-1

for row in first_term_row..last_term_row
  key = worksheet[row, 1]
  unless key.blank?
    term = Term.new(key,keep_keys)
    term_text = worksheet[row, 2]
    term.values.store "base", term_text

    if(term_text.blank?)
      puts "Warning: Missing ".red+"base".cyan+" for #{key}".red
    end

    @terms << term
  end
end

puts 'Loaded.'.cyan

puts 'Generating Localizable.base.strings file for ' + 'iOS'.red + '...'
generate_ios "base", "./"

if wti_upload
  puts "Updating base Localizable.strings on wti"
  system "wti push -c #{ios_path}.wti"

  puts "Executing LG wti pull script"
  system "ruby #{File.dirname(__FILE__)}/helpers/wti.rb -w #{ios_path}.wti -i #{ios_path}Ambatana/res/i18n -c #{ios_path}Ambatana/src/Constants/"
else
  #Just generate Localiables file
  system "ruby #{File.dirname(__FILE__)}/helpers/localized_generator.rb -s Localizable.strings -d #{ios_path}Ambatana/src/Constants/"
  system "rm Localizable.strings"
end


puts 'Done! - Locale generation went smoothly :)'.green

if(check_unused)
  puts 'Checking unused'
  if(has_ios)
    check_unused_ios(worksheet, first_term_row, last_term_row, ios_path, check_unused_mark)
  end
  if(has_android)
    check_unused_android(worksheet, first_term_row, last_term_row, android_path, check_unused_mark)
  end
end



