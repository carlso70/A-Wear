const
    express = require('express'),
    app = express(),
    bodyParser = require('body-parser'),
    cors = require('cors'),
    sqliteDriver = require('./sqliteDriver.js');

app.use(cors({ credentials: true, origin: true }));
app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());

sqliteDriver.initDB();

/* 
 * Gets all the users 
 */
app.get('/allusers', (req, res) => {
    sqliteDriver.getAllUsers().then(users => res.send(users)).catch(err => res.send(err));
})

/* 
 *  Gets a specific users info 
 */
app.post('/getuser', (req, res) => {
    sqliteDriver.getUser(req.body.username).then(user => {
        res.send(user);
    }).catch(err => {
        res.send(err);
    });
});

/* 
 * Update a user, by sending a FULL new user object to replace the user at username
 */
app.post('/updateUser', (req, res) => {
    console.log("IN UPDATE USER requestbody:\n\n\n");
    console.log(req.body);
    /* If adding a new child, check if object exists */
    sqliteDriver.getUser(req.body.child).then(user => {
        if (user == {}) res.sendStatus(500);
    }).catch(err => {
        res.sendStatus(500);
    })

    /* Update User */
    sqliteDriver.deleteUser(req.body.username);
    sqliteDriver.insertUser(req.body.username, req.body.password, req.body.isParent,
        req.body.child, req.body.enabled, req.body.outdoorMode, req.body.recordStats);

    /* Get the new and improved user */
    sqliteDriver.getUser(req.body.username).then(user => {
        console.log("\n\nAFTER UPDATE \n");
        getFullUserObject(user).then(newUser => {
            console.log(newUser)
            res.send(newUser).end()
        });
    }).catch(err => {
        res.sendStatus(500);
    });
});

/* 
 * Add user post request
 * body: 
 *      {
 *          username: string, 
 *          password: string, 
 *          isParent: bool, 
 *          child: string, 
 *          enabled: bool, 
 *          outdoorMode: bool, 
 *          recordStats: bool
 *      }
 */
app.post('/adduser', (req, res) => {
    /* Check if user is in, this is hacky af TODO fix */
    sqliteDriver.getUser(req.body.username).then(user => {
        console.log(user)
        if (user.username !== null || user.username !== "")
            res.sendStatus(500);
    }).catch(err => {
        /* If there is an error that means the user was not found, which means we can add it */
        sqliteDriver.insertUser(req.body.username, req.body.password, req.body.isParent,
            req.body.child, req.body.enabled, req.body.outdoorMode, req.body.recordStats);

        /* Fetch the newly created user from the db */
        sqliteDriver.getUser(req.body.username).then(user => {
            res.send(user).end();
        }).catch(err => {
            console.log(err);
            res.sendStatus(500);
        });
    });
});

/* Login a user, if successful sends the user object, horribly insecure */
app.post('/login', (req, res) => {
    console.log("\nPASSWORD: " + req.body.password + "\nUSERNAME: " + req.body.username + "\n");
    let pass = req.body.password;
    sqliteDriver.getUser(req.body.username).then(result => {
        if (result.password == pass) {
            res.send(result).end();
        } else {
            res.sendStatus(500).end();
        }
    }).catch(err => {
        console.log(err);
        res.sendStatus(500).end();
    });
});

app.get('/cleanout', (req, res) => {
    sqliteDriver.dropDB();
    sqliteDriver.initDB();
});

// Listen to the App Engine-specified port, or 8080 otherwise
const PORT = process.env.PORT || 8080;
app.listen(PORT, () => {
    console.log(`Server listening on port ${PORT}...`);
});