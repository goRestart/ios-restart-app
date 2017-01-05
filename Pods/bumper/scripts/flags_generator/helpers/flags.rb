class Flags 
	def initialize(flags)
		@flags = flags
	end

	def flags 
		return @flags 
	end

	def bumperInitParams
		params = Array.new
		@flags.each do |flag|
			params << flag.classInstance
		end
		return "[]" if params.empty?
		return "["+params.join(', ')+"]"
	end
end