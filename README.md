Steps to repeat the problem
-
1. `docker run -d --rm -p 3306:3306  -e MYSQL_ROOT_PASSWORD=my-secret-pw  mysql:5.6`
2. `sleep 15` 
3. `migrate up`

**Result**

```
ERROR: Error executing command.  Cause: org.apache.ibatis.jdbc.RuntimeSqlException: Error executing: DELIMITER ||
CREATE FUNCTION format_time( picoseconds BIGINT UNSIGNED )
  RETURNS varchar(16) CHARSET utf8
DETERMINISTIC
  BEGIN
    IF picoseconds IS NULL THEN
      RETURN NULL
.  Cause: com.mysql.jdbc.exceptions.jdbc4.MySQLSyntaxErrorException: You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'DELIMITER ||
CREATE FUNCTION format_time( picoseconds BIGINT UNSIGNED )
  RETURN' at line 1
```
