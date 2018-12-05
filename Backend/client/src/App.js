import React, { Component } from 'react';
import {
  Button, Card, CardBody, CardTitle, Form, FormGroup, Label,
  Input, Badge, Container, Row, Col
} from 'reactstrap';

const awearUrl = "https://awear-222521.appspot.com";

class App extends Component {
  constructor(props) {
    super(props);
    this.state = {
      loggedIn: false,
      user: {},
      password: "",
      username: "",
      cSelected: [],
      child: "",
      childObj: {}
    };
  }

  /******************** API CALLS ***********************/
  login = () => {
    console.log("Logging in...");
    let params = {
      "username": this.state.username,
      "password": this.state.password
    };
    console.log(params);
    fetch(awearUrl + "/login", {
      method: 'POST',
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(params)
    })
      .then(res => res.json())
      .then(res => {
        this.setState({
          user: res,
          loggedIn: true
        }, () => {
          if (res.child !== "") {
            this.loadChildObject(res.child);
          }
        });
      }).catch(err => {
        alert("Error logging in");
        console.log(err);
      });
  }

  loadChildObject = (child) => {
    let params = {
      "username": child
    };
    fetch(awearUrl + "/getuser", {
      method: 'post',
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(params)
    })
      .then(res => res.json())
      .then(res => {
        console.log(res);
        this.setState({
          childObj: res
        });
      })
      .catch(err => console.log(err));
  }

  addChild = () => {
    console.log("HERE")
    if (this.state.child === "") return;

    let user = this.state.user;
    user.child = this.state.child;
    fetch(awearUrl + "/updateUser", {
      method: 'POST',
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify(user)
    })
      .then(res => res.json())
      .then(res => {
        console.log(res);
        this.setState({
          user: res
        }, () => {
          if (res.child !== "") {
            this.loadChildObject(res.child);
          }
        });
      })
      .catch(err => {
        alert("Error adding child");
        console.log("ERROR: " + err);
      });
  }

  createAccount = () => {
    console.log("Creating account...");
    let params = {
      "username": this.state.username,
      "password": this.state.password
    };
    fetch(awearUrl + "/adduser", {
      method: 'POST',
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(params)
    })
      .then(res => res.json())
      .then(res => {
        console.log(res);
        this.setState({
          user: res,
          loggedIn: true
        });
      }).catch(err => {
        alert("Error creating account");
        console.log(err);
      })
  }

  updateUser = (user) => {
    fetch(awearUrl + "/updateUser", {
      method: 'POST',
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify(user)
    })
      .then(res => res.json())
      .then(res => {
        console.log("NEW USER\n");
        console.log(res)
        this.setState({
          user: res
        }, () => {
          if (res.child !== "") {
            this.loadChildObject(res.child);
          }
        });
      })
      .catch(err => {
        console.log("ERROR: " + err);
      });
  }

  /************************************ USER API CONTROLS ************************************/
  toggleEnabled = () => {
    let user = this.state.user;
    user.enabled = this.state.user.enabled === 1 ? 0 : 1;
    this.updateUser(user);
  }

  toggleOutdoor = () => {
    let user = this.state.user;
    user.outdoorMode = this.state.user.outdoorMode === 1 ? 0 : 1;
    this.updateUser(user);
  }

  toggleRecord = () => {
    let user = this.state.user;
    user.recordStats = this.state.user.recordStats === 1 ? 0 : 1;
    this.updateUser(user);
  }

  /**************************** CHILD CONTROLS ************************************/
  toggleChildEnabled = () => {
    let child = this.state.childObj;
    child.enabled = this.state.childObj.enabled === 1 ? 0 : 1;
    this.updateUser(child);
  }

  toggleChildOutdoor = () => {
    let child = this.state.childObj;
    child.outdoorMode = this.state.childObj.outdoorMode === 1 ? 0 : 1;
    this.updateUser(child);
  }

  toggleChildRecord = () => {
    let child = this.state.childObj;
    child.recordStats = this.state.childObj.recordStats === 1 ? 0 : 1;
    this.updateUser(child);
  }

  deleteChild = () => {
    let user = this.state.user;
    user.child = "";
    this.updateUser(user);
  }

  /********************** END API CALLS *********************/

  /******************** UI HANDLERS ***********************/
  handleChange = (event) => {
    let params = {};
    params[event.target.id] = event.target.value;
    this.setState(params);
  }

  onCheckboxBtnClick = (selected) => {
    const index = this.state.cSelected.indexOf(selected);
    if (index < 0) {
      this.state.cSelected.push(selected);
    } else {
      this.state.cSelected.splice(index, 1);
    }
    this.setState({ cSelected: [...this.state.cSelected] });
  }
  /********************** END UI HANDLERS *********************/

  render() {
    if (this.state.loggedIn && this.state.user) {
      let childControls = <div />
      if (this.state.user.child !== "") {
        if (this.state.childObj === null) this.loadChildObject(this.state.user.child);
        childControls = (<div>
          <Card>
            <CardBody>
              <CardTitle>Child Controls</CardTitle>
              <h2 style={{ "margin": "20px" }}><Badge color="warning">Child: {this.state.user.child}</Badge></h2>
              <Button color="primary" onClick={() => this.toggleChildEnabled()} active={this.state.childObj.enabled == 1}>Enable Child iOS Recording</Button>{' '}
              <Button color="primary" onClick={() => this.toggleChildOutdoor()} active={this.state.childObj.outdoorMode == 1}>Outdoor Mode</Button>{' '}
              <Button color="primary" onClick={() => this.toggleChildRecord()} active={this.state.childObj.recordStats == 1}>Record Stats</Button>
              <br />
              <Button color="danger" style={{ "margin": "40px" }} onClick={() => this.deleteChild()}>Remove Child</Button>
            </CardBody>
          </Card>
        </div>);
      } else {
        childControls = (<div >
          <Label for="child">Add Child Account</Label>
          <Input name="child" id="child" value={this.state.child} onChange={this.handleChange} placeholder="Enter Child" />
          <Button style={{ "margin": "20px" }} color="secondary" onClick={() => this.addChild()}>Add Child</Button>
        </div>);
      }

      return (
        <Container style={{ "margin": "40px" }}>
          <Row className="text-center">
            <Col>
              <h1 style={{ "margin": "40px" }}><Badge color="secondary">{this.state.user.username}</Badge></h1>
            </Col>
          </Row>
          <Row className="text-center">
            <Col>
              <Card>
                <CardBody>
                  <CardTitle>User Controls</CardTitle>
                  <Button color="primary" onClick={() => this.toggleEnabled()} active={this.state.user.enabled == 1}>Enable iOS Recording</Button>{' '}
                  <Button color="primary" onClick={() => this.toggleOutdoor()} active={this.state.user.outdoorMode == 1}>Outdoor Mode</Button>{' '}
                  <Button color="primary" onClick={() => this.toggleRecord()} active={this.state.user.recordStats == 1}>Record Stats</Button>
                  <br />
                  <Button color="danger" style={{ "margin": "40px" }} onClick={() => this.deleteChild()}>Remove Child</Button>
                </CardBody>
              </Card>
            </Col>
          </Row>
          <Row className="text-center">
            <Col>
              {childControls}
            </Col>
          </Row>
        </Container >
      );
    } else {
      return (
        <div style={{ "margin": "40px" }}>
          <Form>
            <FormGroup>
              <Label for="username">Username</Label>
              <Input name="username" id="username" value={this.state.username} onChange={this.handleChange} placeholder="Enter Username" />
            </FormGroup>
            <FormGroup>
              <Label for="password">Password</Label>
              <Input type="password" id="password" name="password" value={this.state.pass} onChange={this.handleChange} placeholder="Enter Password" />
            </FormGroup>
            <Button onClick={() => this.login()}>Login</Button>{' '}
            <Button onClick={() => this.createAccount()}>Create Account</Button>
          </Form>
        </div>
      );
    }
  }
}

export default App;
