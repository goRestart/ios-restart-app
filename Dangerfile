# Sometimes it's a README fix, or something like that - which isn't relevant for
# including in a project's CHANGELOG for example
declared_trivial = pr_title.include? "#trivial"

# Make it more obvious that a PR is a work in progress and shouldn't be merged yet
warn("PR is classed as Work in Progress") if pr_title.include? "[WIP]"

# Warn when there is a big PR
warn("Big PR") if lines_of_code > 1000

# Don't let testing shortcuts get into master by accident
fail("fdescribe left in tests") if `grep -r fdescribe letgoTests/`.length > 1
fail("fit left in tests") if `grep -r "fit letgoTests/`.length > 1
fail("fcontext left in tests") if `grep -r "fcontext letgoTests/`.length > 1
warn("There are some Implicit Unwrapped Optionals in the code!") if `grep -r --include \*.swift 'IBOutlet\|func' -v Ambatana/src/ | grep -r '[a-zA-Z0-9)]!'`.length > 1
warn("Needs testing on a real Phone") if pr_labels.include?("ui-testing")
 

build_file = ENV["XCS_XCODEBUILD_LOG"]

if !build_file.nil?
	# look at the top 1000 symbols
	most_expensive_swift_table = `cat #{build_file} | egrep '\.[0-9]ms' | sort -t "." -k 1 -n | tail -1000 | sort -t "." -k 1 -n -r`

	# each line looks like "29.2ms  /Users/distiller/eigen/Artsy/View_Controllers/Live_Auctions/LiveAuctionLotViewController.swift:50:19    @objc override func viewDidLoad()"
	# Looks for outliers based on http://stackoverflow.com/questions/5892408/inferential-statistics-in-ruby/5892661#5892661
	time_values = most_expensive_swift_table.lines.map { |line| line.split.first.to_i }.reject { |value| value == 0 }

	require_relative "config/enumerable_stats"
	outliers = time_values.outliers(3)

	if outliers.any?
	  warn("Detected some Swift building time outliers")

	  current_branch = env.request_source.pr_json["head"]["ref"]
	  headings = "Time | Class | Function |\n| --- | ----- | ----- |"
	  warnings = most_expensive_swift_table.lines[0...outliers.count].map do |line|
	    time, location, function_name = line.split "\t"
	    github_loc = location.gsub("/Users/distiller/eigen", "/artsy/eigen/tree/#{current_branch}")
	    github_loc_code = github_loc.split(":")[0...-1].join("#L")
	    name = File.basename(location).split(":").first
	    "#{time} | [#{name}](#{github_loc_code}) | #{function_name}"
	  end

	  markdown(([headings] + warnings).join)
	end
end 