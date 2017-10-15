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
1. Choose "Other UI" for "Application type".<br>
![](https://raw.githubusercontent.com/gimite/google-drive-ruby/master/doc/images/app_type_other.png)
1. Choose User data for "What data will you be accessing?"
1. Click "What credentials do I need?"
1. Click "Create client ID"
1. Enter a Product Name for "Product name shows to users"
1. Click Done
1. Click the client ID in the list - i.e. "Other client 1"
1. Create a file config.json which contains the client ID and client secret from the page that you're on now, which looks like:
   ```
   {
     "client_id": "xxxxxxxxxxxx-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.apps.googleusercontent.com",
     "client_secret": "xxxxxxxxxxxxxxxxxxxxxxxx"
   }

   ```


## 3) Get Started!

The start.sh script will make sure you're ready to go. Follow the on-screen instructions to get going.

```
./start.sh
```
