class Flag 
	def initialize(name, values, description)
		@name = name
		uncapitalized = Array.new
		values.each do |value|
			uncapitalized << value.uncapitalize
		end
		@values = uncapitalized
		@description = description
		@isBool = false
		if values.length == 2
			@isBool = values.first.isBool && values.last.isBool
			if @isBool 
				@values = values.first.boolValue ? ["yes", "no"] : ["no", "yes"]
			end
		end
	end

	def isBool 
		return @isBool 
	end

	def classInstance 
		return @name+".self"
	end

	def objectName
		return @name 
	end

	def varName 
		return @name.uncapitalize
	end

	def varClassName
		return @isBool ? "Bool" : @name 
	end

	def varDefaultCase
		return @isBool ? defaultBool : defaultCase
	end

	def casesParams
		return @values.join(', ')
	end

	def allCases
		params = Array.new
		@values.each do |value|
			params << "."+value
		end
		return "[]" if params.empty?
		return "["+params.join(', ')+"]"
	end

	def defaultCase
		return "."+@values.first
	end

	def defaultBool
		return @values.first.boolValue ? "true" : "false"
	end

	def trueCase 
		return @values.first if @values.first == "Yes" || @values.first == "yes" || @values.first == "true"
		return @values.last
	end

	def falseCase 
		return @values.first if @values.first == "No" || @values.first == "no" || @values.first == "false"
		return @values.last
	end

	def description
		return @description
	end

	def fromPositionCases
		result = Array.new
		@values.each_with_index do |value, index|
			result << "case #{index}: return .#{value}"
		end
		return result
	end

	def print
		puts "Name: #{@name}, values: #{@values}, description: #{@description}"
	end
end