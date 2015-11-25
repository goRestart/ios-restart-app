#!/usr/bin/env ruby

# WTI files format is:
#   Base:           <filename>.strings
#   With Locale:    <filename>.<locale>.strings, where locale can be like "it" or "it-IT"

require 'colorize'
require 'fileutils'
require 'find'
require 'web_translate_it'
require 'micro-optparse'

require_relative 'helpers/LocalizableFile'

# Command line arguments

options = Parser.new do |p|
  p.banner = 'Wti script (c) 2015 Ambatana <albert@letgo.com>'
  p.version = '1.0'
  p.option :wtifile, ".Wti file path", :default => '.wti'
  p.option :i18n, 'i18n path', :default => 'Ambatana/res/i18n'
  p.option :localesuffix, "Locale folder suffix", :default => '.lproj'
  p.option :basemapping, "Language to base mapping", :default => 'en'
  p.option :printwrong, "Print missing or wrong keys", :default => true
  p.option :localizedgen, "Localized generator path", :default => 'Scripts'
  p.option :localizedconst, "Localized constants path", :default => 'Ambatana/src/Constants/'
end.process!

########################################## CONSTANTS ##########################################

wti_path = options[:wtifile]
i18n_path = options[:i18n]   # "../Ambatana/res/i18n"
locale_folder_suffix = options[:localesuffix]      # ".lproj"
mapping_base_to = options[:basemapping] # "en"
should_print_missing_or_wrong_keys = options[:printwrong]   # true
localized_gen_path = options[:localizedgen]
localized_const_path = options[:localizedconst]

########################################### METHODS ###########################################

def find_locales_in_xcode(i18n_path, locale_folder_suffix)
    locales_in_xcode = []
    Dir.glob("#{i18n_path}/*#{locale_folder_suffix}") { |dir|
        locale = dir.split("/").last.split(".")[0]
        locales_in_xcode.push(locale)
    }
    locales_in_xcode
end

def find_base_locales_filenames()
    base_locales_filenames = []
    Dir.glob("*.strings") { |filename|
        if filename.split(".").size == 2
            base_locales_filenames.push(filename)
        end
    }
    base_locales_filenames
end

def find_base_localizable_file(filename, base_localizable_files)
    found = nil
    base_localizable_files.each { |base_localizable_file|
        if base_localizable_file.filename == filename
            found = base_localizable_file
        end
    }
    found
    
end

def find_wti_locale_identifiers()
    wti_locale_ids = []
    Dir.glob("*.strings") { |filename|
        filename_splitted = filename.split(".")
        if filename_splitted.size >= 3
            locale_id = filename_splitted[1]
            wti_locale_ids.push(locale_id)
        end
    }
    wti_locale_ids.uniq!
end

def move_file(source, destination)
    puts "Moving #{source} to #{destination}"
    FileUtils.mv(source, destination)
end

def copy_file(source, destination)
    puts "Copying #{source} to #{destination}"
    FileUtils.cp(source, destination)
end

def print_main_info(str)
    puts "[WTI] #{str}".white.on_green
end

def print_main_warning(str)
    puts "[WTI] #{str}".black.on_yellow
end

def print_array(array)
    print array
    puts
end

########################################## VARIABLES ##########################################

non_processed_locales = []                      # Locales in xcode proj that have not been processed
base_filenames = []                             # Base localizable file names
base_localizable_files = []                     # Base LocalizableFile
wti_locale_ids = []                             # Locale identifiers from WTI
xcode_locale_id_to_wti_locale_id = Hash.new     # Maps a Xcode locale id to a WTI locale id
warnings = []                                   # Warnings to be aware of

############################################ MAIN #############################################

print_main_info("Started!")

# Create a list of available locales in the Xcode project
locales_in_xcode = find_locales_in_xcode(i18n_path, locale_folder_suffix)

print_main_info("Available locales in the Xcode project:")
print_array(locales_in_xcode)

# Copy project locales to non-processed
non_processed_locales = locales_in_xcode.dup

# Pull all translations from WTI
print_main_info("Pulling from WTI")
system "wti pull -c #{wti_path}"

# Find Base localizable files
base_filenames = find_base_locales_filenames()

# Build up Base LocalizableFiles, copy it to mapping_base_to & move the actual files to i18n Base folder
print_main_info("Moving 'Base' localizable files")

base_filenames.each { | base_filename |
    file = File.open(base_filename, "r")
    base_localizable_file = LocalizableFile.new(base_filename, "Base", file)
    base_localizable_files.push(base_localizable_file)
    
    destination = "#{i18n_path}/#{mapping_base_to}#{locale_folder_suffix}/#{base_filename}"
    copy_file(base_filename, destination)
    
    non_processed_locales -= [mapping_base_to]
    
    destination = "#{i18n_path}/Base#{locale_folder_suffix}/#{base_filename}"
    move_file(base_filename, destination)
    
    non_processed_locales -= ["Base"]
}

# Move or generate other localizable files
print_main_info("Generating 'other' localizable files")

# Find the WTI locale identifiers and map them againts Xcode locale ids
wti_locale_ids = find_wti_locale_identifiers()

wti_locale_ids.each { |wti_locale_id|
    if non_processed_locales.include? wti_locale_id
        xcode_locale_id_to_wti_locale_id[wti_locale_id] = wti_locale_id
    else
        wti_locale_id_splitted = wti_locale_id.split("-")
        locale_wo_country = wti_locale_id_splitted[0]
        
        if non_processed_locales.include? locale_wo_country
            xcode_locale_id_to_wti_locale_id[locale_wo_country] = wti_locale_id
        end
    end
}

# > Special case: Portuguese (Brazil): http://stackoverflow.com/questions/26410021/ios8-regional-localization-e-g-pt-br?rq=1
xcode_locale_id_to_wti_locale_id["pt"] = "pt-BR"

# For each base file
base_filenames.each { | base_filename |
    base_filename_splitted = base_filename.split(".")
    
    # Find the localizable file
    base_localizable_file = find_base_localizable_file(base_filename, base_localizable_files)
    
    # For each Xcode locale id
    xcode_locale_id_to_wti_locale_id.keys.sort.each { |xcode_locale_id|
        
        destination = "#{i18n_path}/#{xcode_locale_id}#{locale_folder_suffix}/#{base_filename}"
        
        # Look for the WTI file
        wti_locale_id = xcode_locale_id_to_wti_locale_id[xcode_locale_id]
        wti_filename = [base_filename_splitted[0],wti_locale_id,base_filename_splitted[1]].join(".")
        
        # If file exists, do the checks
        if File.exist?(wti_filename)
            file = File.open(wti_filename, "r")
            localizable_file = LocalizableFile.new(wti_filename, xcode_locale_id, file)
            
            # Try to add missing or wrong keys from base
            added_keys = localizable_file.add_missing_or_wrong_key_values_from(base_localizable_file)
            
            # If not empty add a warning
            unless added_keys.empty?
                warning = "- #{wti_filename} has missing or wrong values"
                if should_print_missing_or_wrong_keys
                    added_keys.each { |added_key|
                        warning << "\n\t> #{added_key}"
                    }
                end
                
                warnings << warning
            end
            
            # Export the file
            localizable_file.export(destination)
            
            # Erase the file, but "Special case: Portuguese (Brazil)"
            if xcode_locale_id != "pt" # As the keys are alphabetically sorted, it will be the first occurrence for the pt-BR
                FileUtils.rm(wti_filename)
            end
            
            puts "'#{wti_filename}' generated into '#{destination}'"
            
        # Else (doesn't exist), then copy the Base file
        else
            # Add a warning
            warnings << "- #{wti_filename} doesn't exist. Copied from #{base_filename}"
            
            # Export the base file
            base_localizable_file.export(destination)
            
            puts "'#{wti_filename}' generated into '#{destination}' from 'Base' #{base_filename}"
        end
        
        non_processed_locales -= [xcode_locale_id]
    }
}

# Non-processed files are copied from Base
base_filenames.each { | base_filename |
    base_filename_splitted = base_filename.split(".")
    
    # Find the localizable file
    base_localizable_file = find_base_localizable_file(base_filename, base_localizable_files)
    
    # For each non-processed locale
    non_processed_locales.each { |non_processed_locale|
        
        destination = "#{i18n_path}/#{non_processed_locale}#{locale_folder_suffix}/#{base_filename}"
        
        # Add a warning
        warnings << "- '#{non_processed_locale}' doesn't exist. Copied from #{base_filename}"
        
        # Export the base file
        base_localizable_file.export(destination)
        
        puts "'#{non_processed_locale}' generated into '#{destination}' from 'Base' #{base_filename}"
    }
}

# Erase other .strings files not included in xcode proj
Dir.glob("*.strings") { |filename|
    FileUtils.rm(filename)
    
    # Add a warning
    warnings << "- '#{filename}' erased, as it's not included in Xcode project"
}


# Print the issues
print_main_warning("Issues (#{warnings.size}):")
warnings.each { |warning|
    puts "   #{warning}"
}

system("ruby", "#{localized_gen_path}/localized_generator.rb", "-s", "#{i18n_path}/Base.lproj/Localizable.strings", "-d", "#{localized_const_path}")

print_main_info("Finished")