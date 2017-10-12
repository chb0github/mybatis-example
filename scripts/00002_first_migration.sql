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
-- ========== ========== ========== ========== ========== ========== ==========
-- DB1, DB2, DB3 - DBA
--
-- NOTE: view creations in a seperate file
-- NOTE: function creations in a seperate file
-- NOTE: procedure creations in a seperate file
-- NOTE: event creations in a seperate file
-- ========== ========== ========== ========== ========== ========== ==========

SET FOREIGN_KEY_CHECKS = 0;

-- DROP DATABASE IF EXISTS DBA;

CREATE DATABASE DBA
  DEFAULT CHARACTER SET = utf8
  DEFAULT COLLATE = utf8_unicode_ci;

USE DBA;

-- ========== ========== ========== ========== ========== ========== ==========

CREATE TABLE events_statements (
  SCHEMA_NAME varchar(64) NOT NULL DEFAULT '',
  DIGEST varchar(32) NOT NULL DEFAULT '',
  DIGEST_TEXT longtext,
  COUNT_STAR BIGINT unsigned NOT NULL,
  SUM_TIMER_WAIT BIGINT unsigned NOT NULL,
  MIN_TIMER_WAIT BIGINT unsigned NOT NULL,
  AVG_TIMER_WAIT BIGINT unsigned NOT NULL,
  MAX_TIMER_WAIT BIGINT unsigned NOT NULL,
  SUM_LOCK_TIME BIGINT unsigned NOT NULL,
  SUM_ERRORS BIGINT unsigned NOT NULL,
  SUM_WARNINGS BIGINT unsigned NOT NULL,
  SUM_ROWS_AFFECTED BIGINT unsigned NOT NULL,
  SUM_ROWS_SENT BIGINT unsigned NOT NULL,
  SUM_ROWS_EXAMINED BIGINT unsigned NOT NULL,
  SUM_CREATED_TMP_DISK_TABLES BIGINT unsigned NOT NULL,
  SUM_CREATED_TMP_TABLES BIGINT unsigned NOT NULL,
  SUM_SELECT_FULL_JOIN BIGINT unsigned NOT NULL,
  SUM_SELECT_FULL_RANGE_JOIN BIGINT unsigned NOT NULL,
  SUM_SELECT_RANGE BIGINT unsigned NOT NULL,
  SUM_SELECT_RANGE_CHECK BIGINT unsigned NOT NULL,
  SUM_SELECT_SCAN BIGINT unsigned NOT NULL,
  SUM_SORT_MERGE_PASSES BIGINT unsigned NOT NULL,
  SUM_SORT_RANGE BIGINT unsigned NOT NULL,
  SUM_SORT_ROWS BIGINT unsigned NOT NULL,
  SUM_SORT_SCAN BIGINT unsigned NOT NULL,
  SUM_NO_INDEX_USED BIGINT unsigned NOT NULL,
  SUM_NO_GOOD_INDEX_USED BIGINT unsigned NOT NULL,
  FIRST_SEEN timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  LAST_SEEN timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  SNAPSHOT_TIME timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (SCHEMA_NAME,DIGEST,SNAPSHOT_TIME)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ========== ========== ========== ========== ========== ========== ==========

CREATE TABLE objects (
  id INT unsigned NOT NULL AUTO_INCREMENT,
  obj_schema varchar(64) COLLATE utf8_bin NOT NULL,
  obj_name varchar(64) COLLATE utf8_bin NOT NULL,
  obj_type enum('TABLE','VIEW') COLLATE utf8_bin NOT NULL,
  created date NOT NULL,
  dropped date DEFAULT NULL,
  PRIMARY KEY (id),
  KEY objects_ix1 (obj_schema,obj_name,created) COMMENT 'help sorting by schema.name',
  KEY objects_ix2 (obj_schema,obj_name,dropped,obj_type) COMMENT 'help searching in track_objects_check_found function and track_objects_main procedure'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin STATS_PERSISTENT=1 STATS_AUTO_RECALC=1 STATS_SAMPLE_PAGES=50 COMMENT='When were the objects (TABLE and VIEW) created & dropped?  Note: collation is set for case sensitivity. Tables a and A are different';

-- ========== ========== ========== ========== ========== ========== ==========

SET FOREIGN_KEY_CHECKS = 1;

-- //@UNDO
DROP TABLE objects;
DROP TABLE events_statements;



