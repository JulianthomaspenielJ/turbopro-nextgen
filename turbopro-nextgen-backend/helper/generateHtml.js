
function generateHtml(jsonInput) {
    let tableHTML = `
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
        font-style: bold;
        color:  #555;
        margin: 5px 0;
        padding: 10px;
        text-align: center;
        border: 1px solid  #ccc;
        background-color: #f9f9f9;
        border-radius: 6px;
        font-size: 14px;
      }
    </style>
  `;

    for (let idx = 0; idx < jsonInput.length; idx++) {
        const section = jsonInput[idx];
        const dataArray = section.array || [];
        const headerText = section.header || '';
        const headerColor = section.color || '';
        const fallbackText = section.fallbackText || '';
        const fallbackKeys = section.KEYS || [];
        const skipKeys = section.skip || [];

        const rowCount = dataArray.length;
        tableHTML += `<h3 style="color:${headerColor}">${headerText}</h3>`;

        if (rowCount > 0) {
            const firstRow = dataArray[0];
            const keyList = Object.keys(firstRow).filter(k => !skipKeys.includes(k));
            const colCount = keyList.length;

            tableHTML += '<table><thead><tr>';
            for (let colIdx = 0; colIdx < colCount; colIdx++) {
                const keyName = keyList[colIdx];
                tableHTML += `<th>${keyName}</th>`;
            }
            tableHTML += '</tr></thead><tbody>';

            for (let rowIdx = 0; rowIdx < rowCount; rowIdx++) {
                tableHTML += '<tr>';
                const row = dataArray[rowIdx];
                for (let colIdx = 0; colIdx < colCount; colIdx++) {
                    const keyName = keyList[colIdx];
                    const cellValue = row[keyName] != null ? row[keyName] : '';
                    tableHTML += `<td>${cellValue}</td>`;
                }
                tableHTML += '</tr>';
            }

            tableHTML += '</tbody></table>';
        } else {
            let fallbackValue = '';
            let foundValidFallback = false;

            if (fallbackKeys && fallbackKeys.length > 0 && dataArray.length > 0) {
                for (let i = 0; i < fallbackKeys.length && !foundValidFallback; i++) {
                    const key = fallbackKeys[i];
                    fallbackValue = dataArray[0][key] || '';
                    if (fallbackValue !== '') {
                        foundValidFallback = true;
                    }
                }
            }

            tableHTML += '<div class="no-data">';
            if (fallbackValue !== '') {
                tableHTML += `Unable to process: ${headerText} (${fallbackValue})`;
            } else if (fallbackText !== '') {
                tableHTML += fallbackText;
            } else {
                tableHTML += 'No data available.';
            }
            tableHTML += '</div>';
        }
    }

    return tableHTML;
}

module.exports = {
    generateHtml
};

