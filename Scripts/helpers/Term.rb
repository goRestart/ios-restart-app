class Term
  def initialize(keyword, keep_key = true)
    @keep_key = keep_key
    @keyword = keyword
    @values = Hash.new
  end

  def values
    @values
  end

  def values=(val)
    @values = val
  end

  def keyword
    @keyword
  end

  def is_comment?
    @keyword.downcase == '[comment]'
  end

  def restriction
    if @keyword.match /^[\[][a-z][\]]/
      @keyword[1]
    else
      nil
    end
  end

  def keyword_iphone
    if(@keep_key)
      return @keyword
    else
    '_'+@keyword.space_to_underscore.strip_tag.camel_case
    end
  end

  def keyword_iphone_constant
    'kLocale'+@keyword.space_to_underscore.strip_tag.camel_case
  end

  def keyword_iphone_constant_swift
    'sLocale'+@keyword.space_to_underscore.strip_tag.camel_case
  end

  def keyword_android
    if(@keep_key)
      return @keyword
    else
      @keyword.space_to_underscore.strip_tag.downcase
    end
  end

  def keyword_json
    if(@keep_key)
      return @keyword
    else
      @keyword.space_to_underscore.strip_tag.downcase
    end
  end

  def values_iphone
    iphone_values = Hash.new
    @values.each do |language, value|
      new_language = language.gsub('*','')
      new_value = value.gsub(/\n/, '\n')
      new_value = new_value.gsub("\\\"", '"')
      new_value = new_value.gsub(/"/, '\"')
      new_value.gsub!(/[%]\d*[s]/) do |w|
        w.gsub!('s','@')
      end
      iphone_values.store new_language, new_value
    end
    iphone_values
  end

  def values_android
    android_values = Hash.new
    @values.each do |language, value|
      new_language = language.gsub('*','')
      new_value = value
      if(!value.start_with?("<![CDATA["))
        new_value = new_value.gsub('%i','%d')
        new_value = new_value.gsub('\?', '')
        new_value = new_value.gsub(/\n/, '\n')
        new_value = new_value.gsub("\\\"", '"')
        new_value = new_value.gsub("'","\\\\'")
        new_value = new_value.gsub(/"/, '\"')
        new_value = new_value.gsub('&', '&amp;')
        new_value.gsub!(/[%]\d*[@]/) do |w|
          w.gsub!('@','s')
        end
        new_value = new_value.gsub('...', '&#8230;')
        if(new_value == '?')
          new_value = "\"?\""
        end
      end
      android_values.store new_language, new_value
    end
    android_values
  end

  def values_json
    json_values = Hash.new
    @values.each do |language, value|
      new_language = language.gsub('*','')
      new_value = value.gsub('%i','%d')
      new_value = new_value.gsub("\\'","'")
      new_value.gsub!(/[%]\d*[@]/) do |w|
        w.gsub!('@','s')
      end
      json_values.store new_language, new_value
    end
    json_values
  end
end
