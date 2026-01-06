#!/usr/bin/env ruby
# frozen_string_literal: true

require 'fileutils'
require 'open-uri'
require 'zip'
require 'inquirer'

# Hardcoded values
DOWNLOAD_URL = 'https://github.com/ghall89/mac-app-template/archive/refs/heads/main.zip'
ZIP_FILENAME='mac-app-template-main.zip'
EXTRACTED_DIR = ZIP_FILENAME.sub(/\.zip$/, '')

bundle_name = Ask.input 'What\'s your project name? (e.g. MyProject)', response: false
# bundle_id = Ask.input 'What\'s your project\'s bundle identifier? (e.g. com.coolness.MyProject)', response: false
# install_deps = Ask.confirm 'Would you like to use Homebrew to install tooling?'

# Download
puts "Downloading #{ZIP_FILENAME}..."
File.open(ZIP_FILENAME, 'wb') do |file|
  file.write URI.open(DOWNLOAD_URL).read
end

# Unzip
puts "Unzipping #{ZIP_FILENAME}..."
Zip::File.open(ZIP_FILENAME) do |zip_file|
  zip_file.each do |entry|
    entry.extract(entry.name)
  end
end

# Clean up
FileUtils.rm(ZIP_FILENAME)

# Verify
unless Dir.exist?(EXTRACTED_DIR)
  puts "Expected directory #{EXTRACTED_DIR} not found"
  exit 1
end

# Rename project directory
puts "Renaming #{EXTRACTED_DIR} to #{bundle_name}..."
FileUtils.mv(EXTRACTED_DIR, bundle_name)
Dir.chdir(bundle_name)

# Handle .env file
if File.exist?('.env.example')
  puts 'Renaming .env.example to .env and removing first 2 lines...'
  FileUtils.mv('.env.example', '.env')
  lines = File.readlines('.env')
  File.open('.env', 'w') { |f| f.write lines[2..].join }
end

# Handle Sources folder and file
old_folder = 'Sources/{{bundle_name}}'
new_folder = "Sources/#{bundle_name}"

if Dir.exist?(old_folder)
  puts "Renaming folder #{old_folder} to #{new_folder}..."
  FileUtils.mv(old_folder, new_folder)
else
  puts "Warning: Expected folder #{old_folder} not found"
end

old_file = "#{new_folder}/{{bundle_name}}.swift"
new_file = "#{new_folder}/#{bundle_name}.swift"

if File.exist?(old_file)
  puts "Renaming file #{old_file} to #{new_file}..."
  FileUtils.mv(old_file, new_file)
else
  puts "Warning: Expected file #{old_file} not found"
end

puts 'Updating project references'

Dir.glob('**/*').each do |file|
  next unless File.file?(file)

  content = File.read(file)
  next unless content.include?('{{bundle_name}}')

  content.gsub!('{{bundle_name}}', bundle_name)
  File.open(file, 'w') { |f| f.write content }
end

puts "All done! Project '#{bundle_name}' has been set up."
