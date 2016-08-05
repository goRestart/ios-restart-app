File.open("./Constants/LGLocalizedString.swift", 'r').each do |line|
	if line.include? "static"
		locString = line.split(" ")[2].chomp(":")
		result = (`grep -rnw '.' -e #{locString} | wc -l`).strip()
		if result == "1"
			puts locString
		end
	end
end