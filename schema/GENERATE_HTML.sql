DELIMITER $$

CREATE PROCEDURE GENERATE_HTML(
  IN jsonInput JSON,
  OUT htmlOutput TEXT
)
BEGIN
  DECLARE itemCount INT DEFAULT JSON_LENGTH(jsonInput);
  DECLARE idx INT DEFAULT 0;
  DECLARE tableHTML TEXT DEFAULT '';

  DECLARE section JSON;
  DECLARE dataArray JSON;
  DECLARE headerText VARCHAR(255);
  DECLARE headerColor VARCHAR(50);
  DECLARE fallbackKeys JSON;
  DECLARE fallbackKey VARCHAR(255);
  DECLARE fallbackText VARCHAR(500);
  DECLARE fallbackValue VARCHAR(255);
  DECLARE keyList JSON;
  DECLARE keyName VARCHAR(255);
  DECLARE colIdx INT;
  DECLARE colCount INT;
  DECLARE rowIdx INT;
  DECLARE rowCount INT;
  DECLARE cellValue VARCHAR(1000);

  -- Add CSS styles
  SET tableHTML = CONCAT(tableHTML, '
    <style>
      table {
        width: 100%;
        border-collapse: collapse;
        font-family: Arial, sans-serif;
        font-size: 12px;
        margin-bottom: 30px;
        color: #222;
      }
      th {
        background-color: #f2f2f2;
        color: #000;
        padding: 4px 6px;
        text-align: left;
        border: 1px solid #ccc;
        font-weight: bold;
        font-size: 12px;
      }
      td {
        padding: 4px 6px;
        border: 1px solid #ccc;
        font-weight: normal;
        font-size: 12px;
      }
      tr:nth-child(even) {
        background-color: #f6f6f6;
      }
      h3 {
        color: #333;
        font-size: 16px;
        text-transform: uppercase;
      }
      .no-data {
        font-style: italic;
        color: #888;
        margin: 5px 0 25px 0;
      }
    </style>
  ');

  WHILE idx < itemCount DO
    SET section = JSON_EXTRACT(jsonInput, CONCAT('$[', idx, ']'));
    SET dataArray = JSON_EXTRACT(section, '$.array');
    SET headerText = JSON_UNQUOTE(JSON_EXTRACT(section, '$.header'));
    SET headerColor = JSON_UNQUOTE(JSON_EXTRACT(section, '$.color'));
    SET fallbackText = JSON_UNQUOTE(JSON_EXTRACT(section, '$.fallbackText'));
    SET fallbackKeys = JSON_EXTRACT(section, '$.KEYS');

    SET rowCount = JSON_LENGTH(dataArray);

    SET tableHTML = CONCAT(tableHTML, '<h3 style="color:', headerColor, '">', headerText, '</h3>');

    IF rowCount > 0 THEN
      -- Build table header
      SET keyList = JSON_KEYS(JSON_EXTRACT(dataArray, '$[0]'));
      SET colCount = JSON_LENGTH(keyList);

      SET tableHTML = CONCAT(tableHTML, '<table><thead><tr>');
      SET colIdx = 0;
      WHILE colIdx < colCount DO
        SET keyName = JSON_UNQUOTE(JSON_EXTRACT(keyList, CONCAT('$[', colIdx, ']')));
        SET tableHTML = CONCAT(tableHTML, '<th>', keyName, '</th>');
        SET colIdx = colIdx + 1;
      END WHILE;
      SET tableHTML = CONCAT(tableHTML, '</tr></thead><tbody>');

      -- Rows
      SET rowIdx = 0;
      WHILE rowIdx < rowCount DO
        SET tableHTML = CONCAT(tableHTML, '<tr>');
        SET colIdx = 0;
        WHILE colIdx < colCount DO
          SET keyName = JSON_UNQUOTE(JSON_EXTRACT(keyList, CONCAT('$[', colIdx, ']')));
          SET cellValue = JSON_UNQUOTE(JSON_EXTRACT(dataArray, CONCAT('$[', rowIdx, '].', keyName)));
          SET tableHTML = CONCAT(tableHTML, '<td>', IFNULL(cellValue, ''), '</td>');
          SET colIdx = colIdx + 1;
        END WHILE;
        SET tableHTML = CONCAT(tableHTML, '</tr>');
        SET rowIdx = rowIdx + 1;
      END WHILE;
      SET tableHTML = CONCAT(tableHTML, '</tbody></table>');

    ELSE
      -- No data - show fallback or KEY-based summary
      SET fallbackValue = '';
      IF fallbackKeys IS NOT NULL AND JSON_LENGTH(fallbackKeys) > 0 THEN
        SET colIdx = 0;
        WHILE colIdx < JSON_LENGTH(fallbackKeys) DO
          SET fallbackKey = JSON_UNQUOTE(JSON_EXTRACT(fallbackKeys, CONCAT('$[', colIdx, ']')));
          SET fallbackValue = JSON_UNQUOTE(JSON_EXTRACT(dataArray, CONCAT('$[0].', fallbackKey)));
          IF fallbackValue IS NOT NULL AND fallbackValue <> '' THEN
            LEAVE;
          END IF;
          SET colIdx = colIdx + 1;
        END WHILE;
      END IF;

      IF fallbackValue IS NOT NULL AND fallbackValue <> '' THEN
        SET tableHTML = CONCAT(tableHTML, '<div class="no-data">Unable to process: ', headerText, ' (', fallbackValue, ')</div>');
      ELSEIF fallbackText IS NOT NULL AND fallbackText <> '' THEN
        SET tableHTML = CONCAT(tableHTML, '<div class="no-data">', fallbackText, '</div>');
      ELSE
        SET tableHTML = CONCAT(tableHTML, '<div class="no-data">No data available.</div>');
      END IF;

    END IF;

    SET idx = idx + 1;
  END WHILE;

  SET htmlOutput = tableHTML;
END$$

DELIMITER ;
