import React, { Component } from 'react';
import { Button, Form, FormGroup, Label, Input } from 'reactstrap';

class App extends Component {
  constructor(props) {
    super(props);
    this.state = {
      loggedIn: false
    };
  }

  render() {
    if (this.state.loggedIn) {

    } else {
      return (
        <div style={{ "margin": "40px"}}>
          <Form>
            <FormGroup>
              <Label for="Username">Email</Label>
              <Input type="email" name="email" id="exampleEmail" placeholder="with a placeholder" />
            </FormGroup>
            <FormGroup>
              <Label for="examplePassword">Password</Label>
              <Input type="password" name="password" id="examplePassword" placeholder="password placeholder" />
            </FormGroup>
            <Button>Login</Button>{' '}
            <Button>Create Account</Button>
          </Form>
        </div>
      );
    }
  }
}

export default App;
