const
    sqlite3 = require('sqlite3').verbose(),
    db = new sqlite3.Database(':memory:');

module.exports = {
    initDB: function () {
        db.serialize(function () {
            db.run("CREATE TABLE IF NOT EXISTS userTable (username TEXT, password TEXT)");

            var stmt = db.prepare("INSERT INTO userTable (username, password) VALUES (?, ?)");
            for (var i = 0; i < 10; i++) {
                stmt.run("Username " + i, "pass " + i);
            }
            stmt.finalize();

            db.each("SELECT rowid AS id, username AS user, password AS pass FROM userTable", function (err, row) {
                if (err) {
                    console.log(err);
                    return;
                }
                console.log(row.id + ": " + row.user + ", " + row.pass);
            });
        });
    },

    dropDB: function () {
        db.serialize(function() {
            db.run("DROP TABLE IF EXISTS userTable");
        });
    }
};

// Checks if a json is empty
function isEmpty(obj) {
    return Object.keys(obj).length == 0;
}