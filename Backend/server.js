const
    express = require('express'),
    app = express(),
    sqliteDriver = require('./sqliteDriver.js');

app.use(express.json());
sqliteDriver.initDB();

app.get('/', (req, res) => {
    res.send('Hello from App Engine!');
});

// Gets all the users
app.get('/allusers', (req, res) => {
    sqliteDriver.getAllUsers().then(users => res.send(users)).catch(err => res.send(err));
})

/* 
 * Add user post request
 * body: {username: string, password: string, isParent: bool, child: string}
 */
app.post('/adduser', (req, res) => {
    sqliteDriver.insertUser(req.body.username, req.body.password, req.body.isParent, req.body.child);
    res.sendStatus(200);
});

// Listen to the App Engine-specified port, or 8080 otherwise
const PORT = process.env.PORT || 8080;
app.listen(PORT, () => {
    console.log(`Server listening on port ${PORT}...`);
});

// sqliteDriver.dropDB();
// sqliteDriver.initDB();
// for (var i = 0; i < 10; i++) {
//     sqliteDriver.insertUser("testname " + i, "pass" + i, i % 2 == 0, "testname " + i - 1);
// }

// sqliteDriver.getAllUsers().then(res => {
//     console.log(res);
// }).catch(err => console.log(err));
