require "google_drive"
require "rb-inotify"
require 'json'

# Get the Google Drive subfolder to upload files to
config = File.read('config.json')
googlefolder = JSON.parse(config)['subfolder']

foldersync = '/files'
notifier = INotify::Notifier.new

def uploadFile(file,foldersync,googlefolder)
  session = GoogleDrive::Session.from_config("config.json")
  filename = File.basename(file)
  puts "\tCopying #{file}" 
  uploaded = session.upload_from_file("#{foldersync}/#{filename}", filename, convert: false)
  unless googlefolder.nil?
    puts "\tMoving it to #{googlefolder}" 
    session.collection_by_title("Plex Cloud Sync").add(uploaded)
  end
  session.root_collection.remove(uploaded)
  File.delete("#{foldersync}/#{filename}")
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

