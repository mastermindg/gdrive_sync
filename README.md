# gdrive_sync

Docker container that syncs a folder to Google Drive.

There are two builds - one for x86 and one for ARM.

Follow the following steps:

## 1) Create a new project, or select an existing project
Go to the [credentials page](https://console.developers.google.com/apis/credentials) in the Google Developer Console.
![](https://raw.githubusercontent.com/gimite/google-drive-ruby/master/doc/images/create_project.png)

## 2) Enable Google Drive API
Go [here](https://console.developers.google.com/apis/library/drive.googleapis.com/?q=drive) and click Enable

## 3) Create a Token
1. Click "Create credentials" -> "OAuth client ID".<br>
![](https://raw.githubusercontent.com/gimite/google-drive-ruby/master/doc/images/oauth_client_id.png)
1. Choose "Other" for "Application type".<br>
![](https://raw.githubusercontent.com/gimite/google-drive-ruby/master/doc/images/app_type_other.png)
1. Click "Create" and take note of the generated client ID and client secret.
1. Activate the Drive API for your project in the [Google API Console](https://console.developers.google.com/apis/library).
1. Create a file config.json which contains the client ID and client secret you got above, which looks like:
   ```
   {
     "client_id": "xxxxxxxxxxxx-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.apps.googleusercontent.com",
     "client_secret": "xxxxxxxxxxxxxxxxxxxxxxxx"
   }

   ```


## 3) Build the container

```

```

## 4) Start the container with firstrun

```
docker run gdrive_sync ruby firstrun.rb
docker cp gdrive_sync:/root/config.json .
```
