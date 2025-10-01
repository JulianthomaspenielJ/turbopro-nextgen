
const { generateHtml } = require('../helper/generateHtml');
async function processFileJsonSections(fileProcessingJson) {

    const sections = [
        {
            header: "NEW JOBS",
            array: fileProcessingJson.newJobs || [],
            color: "gray",
            fallbackText: "NO NEW JOBS ARE AVALIBALE",
            skip: ['code']
        },
        {
            header: "EXISTING JOBS",
            array: fileProcessingJson.updatedJobs || [],
            color: "gray",
            fallbackText: "NO EXISTING JOBS ARE AVALIBALE",
            skip: ['code']
        },
        {
            header: "UNABLE TO ADD/UPDATE JOBS",
            array: fileProcessingJson.errorJobs || [],
            color: "gray",
            fallbackText: "NO JOBS FAILED TO PROCESS",
            KEYS: ["jobName", "jobNumber"],
            skip: ['code']
        },
        {
            header: "NEW BIDDERS",
            array: fileProcessingJson.newBidders || [],
            color: "gray",
            fallbackText: "NO NEW BIDDERS ARE AVALIBALE",
            skip: ['code']
        },
        {
            header: "EXISTING BIDDERS",
            array: fileProcessingJson.updatedBidders || [],
            color: "gray",
            fallbackText: "NO EXISTING BIDDERS ARE AVALIBALE",
            skip: ['code']
        },
        {
            header: "UNABLE TO ADD/UPDATE BIDDER",
            array: fileProcessingJson.errorBidders || [],
            color: "gray",
            fallbackText: "NO BIDDER FAILED TO PROCESS",
            KEYS: ["jobName", "jobNumber", "bidder", "contact"],
            skip: ['code']
        }
    ];

    const response = generateHtml(sections)
    return response;

}
module.exports = {
    processFileJsonSections
};