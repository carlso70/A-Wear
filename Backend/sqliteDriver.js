const
    sqlite3 = require('sqlite3').verbose(),
    db = new sqlite3.Database(':memory:');

module.exports = {

    /* username: String, password: String, isParent: Boolean, child: String */
    insertUser: function (username, password, isParent, child) {
        if (child == null) child = "";
        if (isParent == null) isParent = false;

        db.serialize(() => {
            var stmt = db.prepare("INSERT INTO userTable (username, password, isParent, child) VALUES (?, ?, ?, ?)");
            stmt.run(username, password, isParent, child);
            stmt.finalize();
        })
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
            db.run("CREATE TABLE IF NOT EXISTS userTable (username TEXT, password TEXT, isParent INTEGER, child TEXT)");
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