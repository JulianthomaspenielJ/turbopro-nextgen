

DROP FUNCTION IF EXISTS tp_ai_split_new_and_existing;



SELECT tp_ai_split_new_and_existing(
  'JOBS',
  '[
    {
      "jobName": "Bryn Mawr Hospital Boiler Replacement",
      "customerName": null,
      "jobNumber": "FR45765",
      "bidDate": "06-30-2025",
      "jobStatus": null,
      "bidders": [
        {
          "bidder": "Frank Dougherty",
          "contact": "Frankdougherty@dwdmechanical.com",
          "jobNumber": "25-ES-071",
          "from": "DWD Mechanical",
          "joMasterId": 196344
        }
      ]
    },
    {
      "jobName": "CHOP NPT GMP 8 & 9 Tank Farm & Connections INSIDE",
      "customerName": null,
      "jobNumber": "25-ES-079",
      "bidDate": "06-30-2025",
      "jobStatus": null,
      "bidders": [
        {
          "bidder": "Frank Dougherty",
          "contact": "Frankdougherty@dwdmechanical.com",
          "jobNumber": "25-ES-079",
          "from": "DWD Mechanical",
          "joMasterId": 196175
        }
      ]
    },
    {
      "jobName": "Philadelphia Clef Club Renovation Project",
      "customerName": null,
      "jobNumber": "25-QS-387",
      "bidDate": "06-19-2025",
      "jobStatus": null,
      "bidders": [
        {
          "bidder": "Frank Dougherty",
          "contact": "Frankdougherty@dwdmechanical.com",
          "jobNumber": "25-QS-387",
          "from": "DWD Mechanical",
          "joMasterId": 196348
        }
      ]
    }
  ]'
) AS result;


SELECT  tp_ai_split_new_and_existing(
    'BIDDERS',
    '[
        {
        "bidder": "Frank Dougherty",
        "contact": "Frankdougherty@dwdmechanical.com",
        "jobNumber": "4555555",
        "from": "DWD Mechanical"
        },
        {
        "bidder": "Frank Dougherty",
        "contact": "Frankdougherty@dwdmechanical.com",
        "jobNumber": "25-ES-079",
        "from": "DWD Mechanical",
        "joMasterId": 196175
        },
        {
        "bidder": "Frank Dougherty",
        "contact": "Frankdougherty@dwdmechanical.com",
        "jobNumber": "25-QS-387",
        "from": "DWD Mechanical",
        "joMasterId": 196348
        }
    ]'
) AS result;


DELIMITER $$
CREATE FUNCTION `tp_ai_split_new_and_existing`(
    _action VARCHAR(225),
    inputJson JSON
)
RETURNS JSON
READS SQL DATA
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE len INT;
    DECLARE _jsonObj JSON;
    DECLARE _bidders JSON;
    DECLARE _bidder JSON;
    DECLARE bidderLen INT;
    DECLARE j INT;
    DECLARE _jobNumber VARCHAR(255);
    DECLARE _joMasterID INT;
    DECLARE _nextSequence INT;
    DECLARE _contactName VARCHAR(255);
    DECLARE _rxMasterID INT;
    DECLARE _rxContactID INT;
    DECLARE _bidderId INT;

    DECLARE mergedResult JSON DEFAULT JSON_ARRAY();

    SET len = JSON_LENGTH(inputJson);

    IF _action = 'JOBS' THEN
		WHILE i < len DO
			SET _joMasterID = NULL;
			SET _jsonObj = JSON_EXTRACT(inputJson, CONCAT('$[', i, ']'));
			SET _jobNumber = JSON_UNQUOTE(JSON_EXTRACT(_jsonObj, '$.jobNumber'));

			-- Try to find joMasterID by jobNumber
			IF _jobNumber IS NOT NULL AND LENGTH(TRIM(_jobNumber)) > 0 AND LOWER(TRIM(_jobNumber)) != 'null' THEN
				SELECT joMasterID INTO _joMasterID
				FROM joMaster
				WHERE jobNumber = _jobNumber
				LIMIT 1;
			END IF;

			-- Add joMasterId at root level (outside bidders) -- even if null
			SET _jsonObj = JSON_SET(_jsonObj, '$.joMasterId', _joMasterID);

			SET _bidders = JSON_EXTRACT(_jsonObj, '$.bidders');
			SET bidderLen = JSON_LENGTH(_bidders);
			SET j = 0;

			WHILE j < bidderLen DO
				SET _bidder = JSON_EXTRACT(_bidders, CONCAT('$[', j, ']'));

				-- Add joMasterId and jobNumber inside each bidder
				SET _bidder = JSON_SET(_bidder, '$.joMasterId', _joMasterID);
				SET _bidder = JSON_SET(_bidder, '$.jobNumber', _jobNumber);

				SET _bidders = JSON_SET(_bidders, CONCAT('$[', j, ']'), _bidder);
				SET j = j + 1;
			END WHILE;

			SET _jsonObj = JSON_SET(_jsonObj, '$.bidders', _bidders);

			-- Append updated record to final output array
			SET mergedResult = JSON_ARRAY_APPEND(mergedResult, '$', _jsonObj);
			SET i = i + 1;
		END WHILE;


    ELSEIF _action = 'BIDDERS' THEN
        WHILE i < len DO
            SET _joMasterID = NULL;
            SET _rxMasterID = NULL;
            SET _rxContactID = NULL;
            SET _bidderId = NULL;

            SET _jsonObj = JSON_EXTRACT(inputJson, CONCAT('$[', i, ']'));
            SET _jobNumber = JSON_UNQUOTE(JSON_EXTRACT(_jsonObj, '$.jobNumber'));
            SET _contactName = JSON_UNQUOTE(JSON_EXTRACT(_jsonObj, '$.contact'));

            IF _jobNumber IS NOT NULL AND LENGTH(TRIM(_jobNumber)) > 0 AND LOWER(TRIM(_jobNumber)) != 'null' THEN
                SELECT joMasterID INTO _joMasterID
                FROM joMaster
                WHERE jobNumber = _jobNumber
                LIMIT 1;
            END IF;

            IF _contactName IS NOT NULL AND LENGTH(TRIM(_contactName)) > 0 AND LOWER(TRIM(_contactName)) != 'null' THEN
                SELECT rxContactID, rxMasterID INTO _rxContactID, _rxMasterID
                FROM rxContact
                WHERE CONCAT(FirstName, ' ', LastName) = _contactName
                LIMIT 1;
            END IF;

            IF _joMasterID IS NOT NULL AND _rxMasterID IS NOT NULL AND _rxContactID IS NOT NULL THEN
                SELECT joBidderID INTO _bidderId
                FROM joBidder
                WHERE joMasterID = _joMasterID AND rxMasterID = _rxMasterID AND rxContactID = _rxContactID
                LIMIT 1;
            END IF;

           SET _jsonObj = REPLACE(
				_jsonObj,
				'}',
				CONCAT(
					', "joMasterID":', IFNULL(_joMasterID, 'null'),
					', "rxContactID":', IFNULL(_rxContactID, 'null'),
					', "rxMasterID":', IFNULL(_rxMasterID, 'null'),
					', "joBidderID":', IFNULL(_bidderId, 'null'),
					'}'
				)
			);


            SET mergedResult = JSON_ARRAY_APPEND(mergedResult, '$', _jsonObj);
            SET i = i + 1;
        END WHILE;
    END IF;

    RETURN mergedResult;
END$$
DELIMITER ;
