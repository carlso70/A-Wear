const
    sqlite3 = require('sqlite3').verbose(),
    db = new sqlite3.Database(':memory:');

module.exports = {

    /* username: String, password: String, isParent: Boolean, child: String */
    insertUser: function (username, password, isParent, child, enabled, outdoorMode, recordStats) {
        if (child == null) child = "";
        if (isParent == null) isParent = false;
        if (enabled == null) enabled = false;
        if (outdoorMode == null) outdoorMode = false;
        if (recordStats == null) recordStats = false;

        db.serialize(() => {
            var stmt = db.prepare(`INSERT INTO userTable (username, password, isParent, child, 
                enabled, outdoorMode, recordStats) VALUES (?, ?, ?, ?, ?, ?, ?)`);
            stmt.run(username, password, isParent, child, enabled, outdoorMode, recordStats);
            stmt.finalize();
        });
    },

    /* Returns a promsie with a user by a specific user name */
    getUser: (username) => {
        let sql = `SELECT * FROM userTable WHERE username  = ?`;
        return new Promise((resolve, reject) => {
            db.serialize(() => {
                db.get(sql, [username], (err, row) => {
                    if (err)
                        reject(err.message);
                    if (row)
                        resolve(row);
                    else
                        reject(new Error(`No user found found with the id ${username}`));
                });
            });
        });
    },

    /* Returns a promise with all the users */
    getAllUsers: () => {
        return new Promise((resolve, reject) => {
            db.serialize(() => {
                db.all("SELECT * FROM userTable", (err, rows) => {
                    if (err) {
                        reject(err)
                    }
                    resolve(rows);
                });
            });
        });
    },

    /* Initialize the DB. Creates the user table */
    initDB: function () {
        db.serialize(() => {
            db.run(`CREATE TABLE IF NOT EXISTS userTable (username TEXT, password TEXT,
                 isParent INTEGER, child TEXT, enabled INTEGER, outdoorMode INTEGER, recordStats INTEGER)`);
        });
    },

    /* Drops the DB. Removes the userTable */
    dropDB: function () {
        db.serialize(() => {
            db.run("DROP TABLE IF EXISTS userTable");
        });
    },
};

// Checks if a json is empty
function isEmpty(obj) {
    return Object.keys(obj).length == 0;
}