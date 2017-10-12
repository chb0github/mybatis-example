##Steps to repeat the problem##
1. `docker run -d --rm -p 3306:3306  -e MYSQL_ROOT_PASSWORD=my-secret-pw  mysql:5.6`
2. `sleep 15` 
3.`migrate up`
