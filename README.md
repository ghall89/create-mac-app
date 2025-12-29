# create-mac-app

A shell script for bootstrapping a SwiftUI Mac app from [this template](https://github.com/ghall89/mac-app-template). 

Inspired by [create-react-app](https://github.com/facebook/create-react-app).

## Run

`curl -s https://raw.githubusercontent.com/ghall89/create-mac-app/refs/heads/main/create-mac-app.sh | bash -s -- ProjectName`

Replace ProjectName with your desired project name (no spaces).

This will download the template, and replace the `{{bundle_name}}` and `{{bundle_id}}` placeholders with the appropriate values, based on your project name.
