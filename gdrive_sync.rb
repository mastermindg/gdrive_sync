require "google_drive"
require "rb-inotify"
require 'json'

# Get the Google Drive subfolder to upload files to
config = File.read('config.json')
googlefolder = JSON.parse(config)['subfolder']

foldersync = '/files'
#notifier = INotify::Notifier.new

# Checks if a file has changed in the last 2 seconds
def checkforChange(filepath)
  size = 0
  puts File.size(filepath)
  sleep 5
  puts File.size(filepath)
end

def uploadFile(file,foldersync,googlefolder)
  session = GoogleDrive::Session.from_config("config.json")
  basename = File.basename(file)
  puts "\tCopying #{file}"
  checkforChange(file)
  exit
  uploaded = session.upload_from_file("#{foldersync}/#{basename}", basename, convert: false)
  unless googlefolder.nil?
    puts "\tMoving it to #{googlefolder}" 
    session.collection_by_title("Plex Cloud Sync").add(uploaded)
  end
  session.root_collection.remove(uploaded)
  File.delete("#{foldersync}/#{basename}")
end

loop do
  puts 'Checking for new files...'
  files = Dir["#{foldersync}/*"]
  unless files.count == 3
    files.each do |file|
      uploadFile(file,foldersync,googlefolder) 
    end
  end 
  sleep 1
end

