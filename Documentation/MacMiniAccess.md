### Configure remote access to mac mini via SSH

##### Accounts configured:
- Mac-mini account name:   `macmini`
- Apple developer + itunesconnect:  `ios-automation@letgo.com`
- GitHub: 	`letbot` (mobile@letgo.com) 

#### 1 time setup steps:
- `alias macmini="ssh macmini@mac-mini.local"`
	- consider adding above line to your `~/.bash_profile` or `~/.zshrc` file to avoid typing it again each time you open the terminal

#### Steps:
- run `macmini` command on terminal. Will prompt a password, use the macmini user one.
- You're now on macmini, just access/clone letgo-ios or lg-corekit as usual (it's configured on develop branch)
	- There are already one `~/letgo-ios` and `~/lgcorekit` configured on develop branch
- Run any fastlane command as usual
	- If you're running deploy_to_appstore lane use the `ios-automation@letgo.com` account when prompted

