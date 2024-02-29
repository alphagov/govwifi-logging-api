echo "Creating userdetails table"
apk add mysql-client
mysql -uroot -proot -huser_db -e "create database govwifi_test"
mysql -uroot -proot -huser_db govwifi_test  < mysql_user/schema.sql
