import React, { Component } from 'react';
import { Button, Form, FormGroup, Label, Input } from 'reactstrap';

const awearUrl = "https://awear-222521.appspot.com";

class App extends Component {
  constructor(props) {
    super(props);
    this.state = {
      loggedIn: false,
      user: {},
      pass: "",
      username: "",
    };
  }

  login() {
    console.log("Logging in...");
    console.log(this.state)
  }

  createAccount() {
    console.log("Creating account...");
    fetch(awearUrl + "/adduser", {
      method: 'post',
      body: JSON.stringify()
    }).then(res => {

    }).catch(err => {
      console.log(err);
    })
  }

  render() {
    if (this.state.loggedIn && this.state.user) {

    } else {
      return (
        <div style={{ "margin": "40px"}}>
          <Form>
            <FormGroup>
              <Label for="username">Username</Label>
              <Input name="username" value={this.state.username} placeholder="Enter Username" />
            </FormGroup>
            <FormGroup>
              <Label for="password">Password</Label>
              <Input type="password" name="password" value={this.state.pass} placeholder="Enter Password" />
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
