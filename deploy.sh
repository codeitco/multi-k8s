#--------------------------
# build prod docker images
#--------------------------
docker build -t crazypikis/multi-client:latest -t crazypikis/multi-client:$SHA -f ./client/Dockerfile ./client
docker build -t crazypikis/multi-server:latest -t crazypikis/multi-server:$SHA -f ./server/Dockerfile ./server
docker build -t crazypikis/multi-worker:latest -t crazypikis/multi-worker:$SHA -f ./worker/Dockerfile ./worker

#--------------------------
# push images to docker hub
#--------------------------
docker push crazypikis/multi-client:latest
docker push crazypikis/multi-server:latest
docker push crazypikis/multi-worker:latest

docker push crazypikis/multi-client:$SHA
docker push crazypikis/multi-server:$SHA
docker push crazypikis/multi-worker:$SHA

#--------------------------
# apply kubernetes configs
#--------------------------
kubectl apply -f k8s

#--------------------------
# use latest build images
#--------------------------
kubectl set image deployments/client-deployment client=crazypikis/multi-client:$SHA
kubectl set image deployments/server-deployment server=crazypikis/multi-server:$SHA
kubectl set image deployments/worker-deployment worker=crazypikis/multi-worker:$SHA