'use strict';

const ftp = require('basic-ftp');
const fs = require('fs');

class FTPClient {
    constructor(host = 'localhost', port = 21, username = 'anonymous', password = 'guest', secure = false) {
        this.client = new ftp.Client();
        this.settings = {
            host: host,
            port: port,
            user: username,
            password: password,
            secure: secure
        };
    }

    upload(sourcePath, remotePath, permissions) {
        let self = this;
        return new Promise(async (resolve, _) => {
            let access = null, uploadLog = null, permission = null;
            try {
                access = await self.client.access(self.settings);
                uploadLog = await self.client.uploadFrom(fs.createReadStream(sourcePath), remotePath);
                permission = await self.changePermissions(permissions.toString(), remotePath);
            } catch(err) {
                console.log("error :: ",err);
                resolve(err);
            }
            console.log("End of Try Block");
            self.client.close();
            resolve({ access, uploadLog, permission})
        })
    }

    close() {
        this.client.close();
    }

    changePermissions(perms, filepath) {
        let cmd = 'SITE CHMOD ' + perms + ' ' + filepath;
        return this.client.send(cmd, false);
    }
}

module.exports = FTPClient;