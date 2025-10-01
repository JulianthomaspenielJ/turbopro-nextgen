DROP procedure IF EXISTS `TSUSERSETTINGS_settings`;
DELIMITER $$
CREATE PROCEDURE `TSUSERSETTINGS_settings` ( IN _action varchar(100), IN _bucketType varchar(100),IN _schema VARCHAR(255))
BEGIN
    DECLARE _DEBUG INT DEFAULT 0;
    DECLARE colName VARCHAR(25) DEFAULT NULL;
    DECLARE _documentLimit int default 100;
-- THIS ACTION For adding fields in tsuser settings
	IF(_action='ALTER') THEN
		SET colName = NULL;
		SELECT column_name INTO colName
		FROM information_schema.columns 
		WHERE TABLE_SCHEMA = _schema AND table_name = 'tsUserSetting' AND column_name = 'Doc_Permission';
		IF colName IS NULL THEN
			ALTER TABLE tsUserSetting ADD Doc_Permission tinyint(4) AFTER `TermsConditionsText`;
		END IF;
        SET colName = NULL;
		SELECT column_name INTO colName
		FROM information_schema.columns 
		WHERE TABLE_SCHEMA = _schema AND table_name = 'tsUserSetting' AND column_name = 'client_Bucket';
		IF colName IS NULL THEN
			ALTER TABLE tsUserSetting ADD client_Bucket TEXT AFTER `Doc_Permission`;
		END IF;
        
         SET colName = NULL;
		SELECT column_name INTO colName
		FROM information_schema.columns 
		WHERE TABLE_SCHEMA = _schema AND table_name = 'tsUserSetting' AND column_name = 'quote_bucket';
		IF colName IS NULL THEN
			ALTER TABLE tsUserSetting ADD quote_bucket TEXT AFTER `client_Bucket`;
		END IF;
        
		SET colName = NULL;
		SELECT column_name INTO colName
		FROM information_schema.columns 
		WHERE TABLE_SCHEMA = _schema AND table_name = 'tsUserSetting' AND column_name = 'doc_bucket';
		IF colName IS NULL THEN
			ALTER TABLE tsUserSetting ADD doc_bucket TEXT AFTER `quote_bucket`;
		END IF;
        SET colName = NULL;
		SELECT column_name INTO colName
		FROM information_schema.columns 
		WHERE TABLE_SCHEMA = _schema AND table_name = 'tsUserSetting' AND column_name = 'temp_bucket';
		IF colName IS NULL THEN
			ALTER TABLE tsUserSetting ADD temp_bucket TEXT AFTER `doc_bucket`;
		END IF;
    END IF;
    IF (_DEBUG in (2,3)) THEN SELECT _action,_DEBUG; END IF;
    -- THIS ACTION For getting buckets based on bucket type
    IF(_action='getBucket') THEN
		IF(_documentLimit IS NULL) THEN
				SET _documentLimit = 100;
			END IF;
		IF( _bucketType = 'DOCUMENTS') THEN
			set  @l_sql = 'SELECT doc_bucket as bucket FROM tsUserSetting; ';
		END IF;
        IF( _bucketType = 'QUOTE') THEN
			set  @l_sql = 'SELECT CONCAT(client_Bucket, "/", quote_bucket) as bucket FROM tsUserSetting; ';
		END IF;
         IF( _bucketType = 'TEMP') THEN
			set  @l_sql = 'SELECT CONCAT(client_Bucket, "/", temp_bucket) as bucket FROM tsUserSetting; ';
		END IF;

		IF (_DEBUG in (1,2,3)) THEN select _action,@l_sql; END IF;

				PREPARE stmt FROM @l_sql;
				EXECUTE stmt;
				DEALLOCATE PREPARE stmt;
				set @l_sql = null;

	END IF;
    
END$$

DELIMITER ;