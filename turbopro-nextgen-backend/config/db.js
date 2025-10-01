var mysql = require("mysql2");
var dotenv = require("dotenv");

dotenv.config()

var dbConfig = {
    connectionLimit: 10,
    multipleStatements: true,
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME
};

// var dbConfig = {
//     connectionLimit: 10,
//     host: "localhost",
//     user: "root",
//     password: "Passw0rd",
//     database: "bartos_test",
// };


var pool = mysql.createPool(dbConfig);

console.log("dbConfig", dbConfig);
console.log("env",process.env);

pool.getConnection((err, connection) => {
    if (err) {
        if (err.code === 'PROTOCOL_CONNECTION_LOST') {
            console.error('Database connection was closed.')
        }
        if (err.code === 'ER_CON_COUNT_ERROR') {
            console.error('Database has too many connections.')
        }
        if (err.code === 'ECONNREFUSED') {
            console.error('Database connection was refused.')
        }
        console.log("", err);
    }
    if (connection) connection.release()
    return
})
module.exports = pool
