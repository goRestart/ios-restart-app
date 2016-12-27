class FormatSpecifiers
    attr_reader :specifiers
    def initialize(string)
        @specifiers = []

        matches = string.scan(/%((\d\$)?(@|d|D|u|U|x|X|o|O|f|e|E|g|G|c|C|s|S|p|a|A|F|ld|lx|lu|zx))/)
        matches.sort! { |a,b| a[0] <=> b[0] }
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

        def format_args
        args = []
        for i in 0..@specifiers.length-1 
            type = type_for_specifier(@specifiers[i])
            if i == 0 
                args.push("var#{i+1}: #{type}")
            else
                args.push("_ var#{i+1}: #{type}")
            end
        end
        return args.join(", ")
    end

    def format_vars
        vars = []
        for i in 0..@specifiers.length-1 
            vars.push("var#{i+1}")
        end
        return vars.join(", ")
    end

    def type_for_specifier(specifier)
        # strip $n if any
        tmpSpecifier = specifier.sub(/\d\$/, "")
        case tmpSpecifier
        when '@', 's', 'S'
            return "String"
        when 'd','D','u','U','x','X','o','O'
            return "Int"
        when 'f', 'F', 'e', 'E', 'g', 'G', 'a', 'A'
            return "Double"
        else
            return "AnyObject"
        end
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