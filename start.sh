docker build -t gdrive_sync .
docker stop gdrive_sync
docker rm gdrive_sync
docker run -d --name gdrive_sync -v $PWD/files:/files gdrive_sync
docker exec -it gdrive_sync bash
#sleep 5
#touch files/test1
#touch files/test2
#touch files/test3
