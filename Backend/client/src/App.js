import React, { Component } from 'react';
import { Button, ButtonGroup, Form, FormGroup, Label, Input, Badge } from 'reactstrap';

const awearUrl = "https://awear-222521.appspot.com";

class App extends Component {
  constructor(props) {
    super(props);
    this.state = {
      loggedIn: false,
      user: {},
      password: "",
      username: "",
      cSelected: []
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
        console.log(res.json);
        this.setState({
          user: res,
          loggedIn: true
        });
      }).catch(err => {
        console.log(err);
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
        console.log(err);
      })
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
      if (this.state.user.child !== "" && this.state.child !== null) {
        childControls = (<ButtonGroup>
          <Button color="primary" onClick={() => this.onCheckboxBtnClick(1)} active={this.state.cSelected.includes(1)}>One</Button>
          <Button color="primary" onClick={() => this.onCheckboxBtnClick(2)} active={this.state.cSelected.includes(2)}>Two</Button>
          <Button color="primary" onClick={() => this.onCheckboxBtnClick(3)} active={this.state.cSelected.includes(3)}>Three</Button>
        </ButtonGroup>);
      }

      return (
        <div>
          <h1><Badge color="secondary">{this.state.user.username}</Badge></h1>
          {childControls}
        </div>
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
