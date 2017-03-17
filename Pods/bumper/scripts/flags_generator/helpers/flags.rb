class Flags 
	def initialize(flags)
		@flags = flags
	end

	def flags 
		return @flags 
	end

	def bumperInitClasses
		params = Array.new
		@flags.each do |flag|
			params << flag.classInstance
		end
		return params
	end
end