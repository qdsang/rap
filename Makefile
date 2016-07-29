.PHONY: build test

TAG = latest
REPO = qdsang/rap


build:
	docker build -t $(REPO):$(TAG) .

push:
	docker push $(REPO):$(TAG)

test:
	docker run --name rap --link rap-mysql:mysql -p 18080:8080 -e ADMIN_USER=admin -e ADMIN_PASS=tomcat -d $(REPO):$(TAG)

test2:
	docker run --name rap -v ${PWD}/webapps:/usr/tomcat/webapps --link rap-redis:redis --link rap-mysql:mysql -p 18080:8080 -e MYSQL_USERNAME=root -e MYSQL_PASSWORD=my-secret-pw -e ADMIN_USER=admin -e ADMIN_PASS=tomcat -d $(REPO):$(TAG)

redis:
	docker run --name rap-redis -p 6379:6379 -d redis:3-alpine

mysql:
	docker run --name rap-mysql -e MYSQL_ROOT_PASSWORD=my-secret-pw -e MYSQL_DATABASE=rap_db -e MYSQL_ALLOW_EMPTY_PASSWORD=yes -d index.tenxcloud.com/docker_library/mysql:5.6
	#  -v /my/own/datadir:/var/lib/mysql

