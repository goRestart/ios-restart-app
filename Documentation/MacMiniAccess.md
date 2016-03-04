### Configure remote access to mac mini via SSH

#### Preconditions: 
- You need to have a ssh identity ([you should have one to connect to github already](https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/))

#### Steps: 

- `ssh-add` (if it fails, execute first `ssh-agent`)
- `brew install ssh-copy-id`
- `ssh-copy-id {YOUR_NAME}@mac-mini.local` (change YOUR_NAME by your real name :trollface:)
- `alias macmini="ssh-add && ssh {YOUR_NAME}@mac-mini.local -A"`
- from now on use `macmini` and you will get connected
- Clone the repos wherever you want and start using `fastlane`