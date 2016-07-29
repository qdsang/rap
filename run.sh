#!/bin/sh
ADMIN_USER=${ADMIN_USER:-admin}
ADMIN_PASS=${ADMIN_PASS:-tomcat}
MAX_UPLOAD_SIZE=${MAX_UPLOAD_SIZE:-52428800}

cat << EOF > /usr/tomcat/conf/tomcat-users.xml
<?xml version='1.0' encoding='utf-8'?>
<tomcat-users>
<user username="${ADMIN_USER}" password="${ADMIN_PASS}" roles="admin-gui,manager-gui"/>
</tomcat-users>
EOF

if [ -f "/usr/tomcat/webapps/manager/WEB-INF/web.xml" ]
then
	sed -i "s#.*max-file-size.*#\t<max-file-size>${MAX_UPLOAD_SIZE}</max-file-size>#g" /usr/tomcat/webapps/manager/WEB-INF/web.xml
	sed -i "s#.*max-request-size.*#\t<max-request-size>${MAX_UPLOAD_SIZE}</max-request-size>#g" /usr/tomcat/webapps/manager/WEB-INF/web.xml
fi


ROOT_DEF_CONFIG_PATH="/usr/tomcat/webapps/ROOT/WEB-INF/classes/_config.properties"
ROOT_CONFIG_PATH="/usr/tomcat/webapps/ROOT/WEB-INF/classes/config.properties"

if [ ! -f ${ROOT_DEF_CONFIG_PATH} ]
then
	/bin/sh -e /usr/tomcat/bin/startup.sh
	sleep 10
	/bin/sh -e /usr/tomcat/bin/shutdown.sh
	cp ${ROOT_CONFIG_PATH} ${ROOT_DEF_CONFIG_PATH}
fi


sed -e "s/mysql\\\:\/\/localhost\\\:3306\/rap_db/mysql\\\:\/\/${MYSQL_PORT_3306_TCP_ADDR:-localhost}\\\:${MYSQL_PORT_3306_TCP_PORT:-3306}\/rap_db/g" ${ROOT_DEF_CONFIG_PATH} > ${ROOT_CONFIG_PATH}
sed -i -e "s/jdbc\.username\=root/jdbc\.username\=${MYSQL_USERNAME:-root}/g" ${ROOT_CONFIG_PATH}
sed -i -e "s/jdbc\.password\=/jdbc\.password\=${MYSQL_PASSWORD}/g" ${ROOT_CONFIG_PATH}
sed -i -e "s/redis\.host\=localhost/redis\.host\=${REDIS_PORT_6379_TCP_ADDR:-localhost}/g" ${ROOT_CONFIG_PATH}
sed -i -e "s/redis\.port\=6379/redis\.port\=${REDIS_PORT_6379_TCP_PORT:-6379}/g" ${ROOT_CONFIG_PATH}


/bin/sh -e /usr/tomcat/bin/catalina.sh run