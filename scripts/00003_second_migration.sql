--
--    Copyright 2010-2016 the original author or authors.
--
--    Licensed under the Apache License, Version 2.0 (the "License");
--    you may not use this file except in compliance with the License.
--    You may obtain a copy of the License at
--
--       http://www.apache.org/licenses/LICENSE-2.0
--
--    Unless required by applicable law or agreed to in writing, software
--    distributed under the License is distributed on an "AS IS" BASIS,
--    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--    See the License for the specific language governing permissions and
--    limitations under the License.
--

-- // First migration.
-- Migration SQL that makes the change goes here.
-- ========== ========== ========== ========== ========== ========== ==========
-- DB1, DB2, DB3 - DBA
-- ========== ========== ========== ========== ========== ========== ==========

SET FOREIGN_KEY_CHECKS = 0;

USE DBA;

-- ========== ========== ========== ========== ========== ========== ==========


DELIMITER ||

CREATE FUNCTION format_time( picoseconds BIGINT UNSIGNED )
  RETURNS varchar(16) CHARSET utf8
DETERMINISTIC
  BEGIN

    IF picoseconds IS NULL THEN

      RETURN NULL;

    ELSE

      RETURN CAST(CONCAT(ROUND(picoseconds / 1000000000000, 2)) AS DECIMAL(10,6));

    END IF;

  END;
||

DELIMITER ;

-- ========== ========== ========== ========== ========== ========== ==========

-- ---------- ---------- ----------

-- ---------- ---------- ----------
DELIMITER ||

-- ---------- ---------- ----------
CREATE DEFINER = CURRENT_USER
FUNCTION DBA.uc_words( str VARCHAR(255) )
  RETURNS VARCHAR(255)
LANGUAGE SQL
CONTAINS SQL
  SQL SECURITY DEFINER
DETERMINISTIC
  COMMENT '
           Description
           -----------

           INIT_CAP (or ucfirst) a string. Ignoring certain punctuation.


           Dependencies
           -----------

           none


           Parameters
           -----------

           1 - str VARCHAR(255)
          TODO: consider the size, is it right?


           Returns
           -----------

           VARCHAR(255)


           Example
           -----------

           mysql> SELECT DBA.uc_words( ''THIS IS A TEST'' ) a;
            +----------------+
            | a              |
            +----------------+
            | This Is A Test |
            +----------------+
            1 row in set (0.00 sec)

           Log
           -----------
           2017-04-24 Eric D Peterson         Initial Version
        '
  BEGIN

    DECLARE c CHAR(1);
    DECLARE s VARCHAR(255);
    DECLARE i INT DEFAULT 1;
    DECLARE bool INT DEFAULT 1;
    DECLARE punct CHAR(17) DEFAULT ' ()[]{},.-_!@;:?/';

    SET s = LCASE( str );
    WHILE i < LENGTH( str ) DO
      BEGIN

        SET c = SUBSTRING( s, i, 1 );
        IF ( LOCATE( c, punct ) > 0 ) THEN

          SET bool = 1;

        ELSEIF ( bool = 1 ) THEN
          BEGIN

            IF ( c >= 'a' AND c <= 'z' ) THEN
              BEGIN

                SET s = CONCAT( LEFT( s, i - 1 ), UCASE( c ), SUBSTRING( s, i + 1 ) );
                SET bool = 0;

              END;
            ELSEIF ( c >= '0' AND c <= '9' ) THEN

              SET bool = 0;

            END IF;

          END;
        END IF;
        SET i = i + 1;

      END;

    END WHILE;
    RETURN s;

  END;
||

-- ---------- ---------- ----------
DELIMITER ;

-- ========== ========== ========== ========== ========== ========== ==========


DELIMITER ||

CREATE DEFINER=CURRENT_USER FUNCTION DBA.track_objects_check_existance(
  p_tbl_schema VARCHAR(64),
  p_tbl_name   VARCHAR(64)
)
  RETURNS TINYINT
  COMMENT '
           Description
           -----------

           Verify if this object_schema and object_name have been saved before


           Dependencies
           -----------

           access to information_schema.tables

           other routines, table, and event as part of this framework:
            - Table: objects
            - Procedure: track_objects_main, track_objects_new, track_objects_drop
            - Function: track_objects_check_found
            - Event: track_objects


           Parameters
           -----------

           1 - table schema
           2 - table name


           Returns
           -----------

           TRUE (1) if row found
           FALSE (0) if not


           Example
           -----------

           called from DBA.track_objects_drop, but can be used elsewhere:
           mysql> SELECT DBA.track_objects_check_existance( ''DBA'', ''xxxx'' ) AS not_found;
           mysql> SELECT DBA.track_objects_check_existance( ''TalentWise'', ''SmartFormV2_FormInstance_Backup'' ) AS found;


           Log
           -----------
           2017-05-01 Eric D Peterson         Initial Version
           2017-05-08 EDP                     change tables to objects
        '
LANGUAGE SQL
NOT DETERMINISTIC
READS SQL DATA
  SQL SECURITY DEFINER
  BEGIN

    DECLARE v_found TINYINT DEFAULT 0;

    -- ---------- ---------- ----------
    -- To search by case sensitive (e.g. two tables 'a' and 'A' are created, how to search for each?)
    -- ---------- ---------- ----------
    SELECT
      1
    INTO
      v_found
    FROM
      information_schema.tables
    WHERE
      table_type   IN ( 'BASE TABLE', 'VIEW' ) AND
      table_schema = p_tbl_schema COLLATE utf8_bin AND
      table_name   = p_tbl_name COLLATE utf8_bin;

    -- ---------- ---------- ----------
    IF ( v_found IS NULL ) THEN

      SET v_found = 0;

    END IF;
    RETURN v_found;

  END;
||

DELIMITER ;

-- ========== ========== ========== ========== ========== ========== ==========


DELIMITER ||

CREATE DEFINER=CURRENT_USER FUNCTION DBA.track_objects_check_found(
  p_obj_schema VARCHAR(64),
  p_obj_name   VARCHAR(64)
)
  RETURNS TINYINT
  COMMENT '
           Description
           -----------

           Verify if this object_schema and object_name have been saved before


           Dependencies
           -----------

           other routines, table, and event as part of this framework:
            - Table: objects
            - Procedure: track_objects_main, track_objects_new, track_objects_drop
            - Function: track_objects_check_existance
            - Event: track_objects


           Parameters
           -----------

           1 - object schema
           2 - object name


           Returns
           -----------

           TRUE (1) if row found
           FALSE (0) if not


           Example
           -----------

           called from DBA.track_objects_new, but can be used elsewhere:
           mysql> SELECT DBA.track_objects_check_found( ''DBA'', ''xxx'' ) AS not_found;
           mysql> SELECT DBA.track_objects_check_found( ''OnPrem'', ''UserFlag'' ) AS found;


           Log
           -----------
           2017-05-01 Eric D Peterson         Initial Version
           2017-05-08 EDP                     change tables to objects
        '
LANGUAGE SQL
NOT DETERMINISTIC
READS SQL DATA
  SQL SECURITY DEFINER
  BEGIN

    DECLARE v_found TINYINT DEFAULT 0;

    -- ---------- ---------- ----------
    -- To search by case sensitive (e.g. two tables 'a' and 'A' are created, how to search for each?)
    -- ---------- ---------- ----------
    SELECT
      1
    INTO
      v_found
    FROM
      DBA.objects
    WHERE
      obj_schema = p_obj_schema COLLATE utf8_bin AND
      obj_name   = p_obj_name COLLATE utf8_bin AND
      dropped    IS NULL;

    -- ---------- ---------- ----------
    IF ( v_found IS NULL ) THEN

      SET v_found = 0;

    END IF;
    RETURN v_found;

  END;
||

DELIMITER ;

-- ========== ========== ========== ========== ========== ========== ==========

SET FOREIGN_KEY_CHECKS = 1;



-- //@UNDO
DROP FUNCTION format_time;
DROP FUNCTION DBA.uc_words;
DROP FUNCTION DBA.track_objects_check_existance;
DROP FUNCTION DBA.track_objects_check_found;



