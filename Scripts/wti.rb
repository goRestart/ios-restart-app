#!/usr/bin/env ruby

# WTI files format is:
#   Base:           <filename>.strings
#   With Locale:    <filename>.<locale>.strings, where locale can be like "it" or "it-IT"

require 'colorize'
require 'fileutils'
require 'find'
require 'web_translate_it'

########################################## CONSTANTS ##########################################

i18n_path = "Ambatana/res/i18n"
locale_folder_suffix = ".lproj"
mapping_base_to = "en"
should_print_missing_or_wrong_keys = false

########################################### CLASSES ###########################################

class FormatSpecifiers
    attr_reader :specifiers
    def initialize(string)
        @specifiers = []
        
        matches = string.scan(/%(@|d|D|u|U|x|X|o|O|f|e|E|g|G|c|C|s|S|p|a|A|F|ld|lx|lu|zx)/)
        matches.each { |match|
            @specifiers.push(match[0])
        }
    end
    
    def empty?
        @specifiers.empty?
    end
    
    def ==(other)
    self.class == other.class && self.specifiers == other.specifiers
end

def to_s
    @specifiers.to_s
end
end

class LocalizableFile
    attr_reader :filename
    attr_reader :locale
    attr_reader :key_value
    attr_reader :key_format_specifiers
    
    def initialize(filename, locale, file=nil)
        @filename = filename
        @locale = locale
        @key_value = Hash.new
        @key_format_specifiers = Hash.new
        
        if file != nil
            # Filter the lines that are actual entries: "key" = "value";
            lines = File.readlines(file)
            
            regex = '^".+" = ".+";$'
            entries = lines.select { |line| line[/#{regex}/] }
            
            # Obtain key & value
            entries.each { |entry|
                if match = entry.match(/(^.*)(=)(.*)(;)/i)
                    key, eq, value = match.captures
                    add_key_value(key, value)
                end
            }
        end
    end
    
    def add_key_value(key, value)
        actual_key = key.strip
        actual_value = value.strip
        @key_value[actual_key] = actual_value
        
        format_specifiers = FormatSpecifiers.new(actual_value)
        unless format_specifiers.empty?
            @key_format_specifiers[actual_key] = format_specifiers
        end
    end
    
    def add_missing_or_wrong_key_values_from(another)
        added_keys = []
        
        # If doesn't have same key format specifiers, then keys should be replaced
        another.key_format_specifiers.keys.each { |key|
            
            #puts key
            specifiers = @key_format_specifiers[key]
            #puts specifiers
            #puts specifiers
            # If I do not have specifiers, then add the key
            if specifiers == nil
                added_keys.push(key)
                # Else if it doesn't have the same specifiers, then add the key
                elsif specifiers != another.key_format_specifiers[key]
                added_keys.push(key)
            end
        }
        
        # Add missing keys
        added_keys += another.key_value.keys - @key_value.keys
        
        # Add the key-values
        added_keys.each { |key|
            add_key_value(key, another.key_value[key])
        }
        
        added_keys.sort
    end
    
    def export(destination_path)
        lines = ""
        @key_value.keys.sort.each { |k| lines << "#{k} = #{@key_value[k]};\n" }
        File.open(destination_path, "wb") { |file| file.write(lines) }
    end
    
    def to_s
        "#{@filename} (#{@locale})\n\nKey-Value:\n#{@key_value.to_s}\n\nKeys with format specifiers:\n#{key_format_specifiers.to_s}"
    end
    
end

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
system 'wti pull'

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

# For each base file
base_filenames.each { | base_filename |
    base_filename_splitted = base_filename.split(".")
    
    # Find the localizable file
    base_localizable_file = find_base_localizable_file(base_filename, base_localizable_files)
    
    # For each Xcode locale id
    xcode_locale_id_to_wti_locale_id.keys.each { |xcode_locale_id|
        
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
            
            # Erase the file
            FileUtils.rm(wti_filename)
            
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

print_main_info("Finished")