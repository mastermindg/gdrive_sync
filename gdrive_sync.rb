require "google_drive"
require 'json'
require 'csv'

# Get the Google Drive subfolder to upload files to
CSV.foreach('folders.csv') do |row|
  if row[0] == 'googlefolder'
    $googlefolder = row[1]
  end
end

foldersync = '/files'

# Checks if googlefolder exists and if not creates it
def checkforGoogleFolder(googlefolder)
  session = GoogleDrive::Session.from_config("config.json")
  folder = session.collection_by_title(googlefolder)
  if folder.nil?
    session.root_collection.create_subcollection(googlefolder)
  end
end

# Checks if a file has changed in the last 5 seconds
def checkforChange(filepath)
  size1 = File.size(filepath)
  sleep 5
  size2 = File.size(filepath)
  if size1 == size2
    0
  else
    1
  end
end

def uploadFile(file,foldersync,googlefolder)
  session = GoogleDrive::Session.from_config("config.json")
  basename = File.basename(file)
  status = checkforChange(file)
  if status == 0
    puts "\tCopying #{file} to Google Drive"
    uploaded = session.upload_from_file("#{foldersync}/#{basename}", basename, convert: false)
    unless googlefolder.nil?
      puts "\tMoving it to #{googlefolder}"
      checkforGoogleFolder(googlefolder)
      session.collection_by_title(googlefolder).add(uploaded)
    end
    session.root_collection.remove(uploaded)
    File.delete("#{foldersync}/#{basename}")
  else
    puts "File hasn't arrived yet...waiting for it to finish"
  end
end

# Recursively uploads a folder file by file
def uploadFolder(folder,foldersync,googlefolder)
  puts "Feature Pending"
  #Create the collection
  #uploadFile(file)
end

puts 'Starting the script...'

loop do
  puts "\tChecking for new files..."
  entries = Dir["#{foldersync}/*"]
  unless entries.count == 0
    folders = Dir.glob("#{foldersync}/*").select {|f| File.directory? f}
    folders.each do |folder|
      puts "\t\t#{folder} is a folder. Recursively uploading it if it's ready"
      uploadFolder(folder,foldersync,$googlefolder)
    end
    files = Dir.glob("#{foldersync}/*").select {|f| File.file? f}
    files.each do |file|
      puts "\t\tUploading file #{file} if it's ready"
      uploadFile(file,foldersync,$googlefolder)
    end
  end 
  sleep 5
end

