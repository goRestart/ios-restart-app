require 'fileutils'

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