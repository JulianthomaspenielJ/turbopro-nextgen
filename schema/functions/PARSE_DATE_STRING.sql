DROP FUNCTION IF EXISTS PARSE_DATE_STRING;

DELIMITER $$

CREATE FUNCTION PARSE_DATE_STRING(inputDate VARCHAR(20))
RETURNS DATE
DETERMINISTIC
BEGIN
  DECLARE parsedDate DATE;

  -- Try format: YYYY-MM-DD (ISO)
  IF inputDate REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' THEN
    SET parsedDate = STR_TO_DATE(inputDate, '%Y-%m-%d');

  -- Try format: MM-DD-YYYY or DD-MM-YYYY
  ELSEIF inputDate REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4}$' THEN
    IF CAST(SUBSTRING_INDEX(inputDate, '-', 1) AS UNSIGNED) <= 12 THEN
      SET parsedDate = STR_TO_DATE(inputDate, '%m-%d-%Y');
    ELSE
      SET parsedDate = STR_TO_DATE(inputDate, '%d-%m-%Y');
    END IF;

  -- Try format: MM/DD/YYYY or DD/MM/YYYY
  ELSEIF inputDate REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}$' THEN
    IF CAST(SUBSTRING_INDEX(inputDate, '/', 1) AS UNSIGNED) <= 12 THEN
      SET parsedDate = STR_TO_DATE(inputDate, '%m/%d/%Y');  -- MM/DD/YYYY
    ELSE
      SET parsedDate = STR_TO_DATE(inputDate, '%d/%m/%Y');  -- DD/MM/YYYY
    END IF;

  -- If unknown or null, use today's date
  ELSE
    SET parsedDate = CURDATE();
  END IF;

  RETURN parsedDate;
END $$

DELIMITER ;
