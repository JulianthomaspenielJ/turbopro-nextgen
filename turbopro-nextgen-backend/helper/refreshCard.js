async function refreshCard(pool, cardId, userId) {

    if (cardId === 16) {  // updating upcommingBids card
        try {
            // Step 1: Get all dashCardIds for this user and cardId
            const [rows] = await pool.execute(
                `
            SELECT 
                dc.dashCardId AS dashCardId
            FROM dashboard_card dc
            JOIN dashboard_layout dl
                ON dc.dc_dashLayoutId = dl.dashLayoutId
                AND dc.dc_layoutId = dl.dl_layoutId
            JOIN dashboard d
                ON dl.dl_dashId = d.dashId
            WHERE dc.dc_cardId = ?
                AND d.dash_userLoginId = ?
            `,
                [cardId, userId]
            );

            // Step 2: Loop and call DASHBOARD_update_card procedure
            for (const row of rows) {
                const dashCardId = row.dashCardId;

                // Calling the procedure with given parameters
                await pool.execute(`CALL DASHBOARD_update_card(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`, [
                    'UPDATE_CARD',    // _action
                    userId,           // _userId
                    null,             // _dash_category
                    dashCardId,       // _dashCardId
                    cardId,           // _cardId
                    null,             // _dashLayoutId
                    null,             // _cardLayoutId
                    null,             // _dc_position
                    null,             // _filter
                    0,                // _suppressOutput
                    0                 // _debug
                ]);
            }

            console.log(`Refreshed ${rows.length} cards for user ${userId}`);
        } catch (error) {
            console.error('Error in refreshCard:', error);
            throw error;
        }
    }
}
module.exports = {
    refreshCard
};