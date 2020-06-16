import React, { Component } from "react";
import { authHeader } from "../helper/auth-header";

export class Register extends Component {
  static displayName = "Register";
  constructor(props) {
    super(props);
    this.state = {
      username: "",
      password: "",
      name: "",
      errors: {},
      validForm: false,
      status: "",
    };
    this.handleChange = this.handleChange.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
  }

  handleChange(e) {
    const { name, value } = e.target;
    this.setState((state) => {
      state[name] = value;
      var validUsername;
      var validPassword;
      var validName;
      if (state.username == "") {
        state.errors["username"] = "Email can not be null.";
        validUsername = false;
      } else {
        state.errors["username"] = undefined;
        validUsername = true;
      }

      if (state.password == "" || state.password.length < 5) {
        state.errors["password"] =
          "The password has to have at least 5 characters.";
        validPassword = false;
      } else {
        state.errors["password"] = undefined;
        validPassword = true;
      }

      if (state.name == "") {
        state.errors["name"] = "Name can not be null.";
        validName = false;
      } else {
        state.errors["name"] = undefined;
        validName = true;
      }
      state.validForm = validUsername && validPassword && validName;
      state.status = "";
      return state;
    });
  }

  handleSubmit(event) {
    event.preventDefault();
    const { username, password, name } = this.state;
    const requestOptions = {
      withCredentials: true,
      credentials: "include",
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        username: username,
        password: password,
        name: name,
      }),
    };

    console.log(requestOptions);

    this.setState((state) => {
      state.validForm = false;
      state.status = "Sent. You can now log in.";
      return state;
    });

    return fetch(`Api/User/register`, requestOptions);
  }

  render() {
    console.log(authHeader().token);
    const { username, password, name, errors, status } = this.state;
    return (
      <div>
        <h1>Register</h1>

        <form name="form" onSubmit={this.handleSubmit}>
          <input
            type="email"
            className="form-control"
            name="username"
            value={username}
            onChange={this.handleChange}
            placeholder="Username or email"
          />
          <span style={{ color: "red" }}>{errors["username"]}</span>
          <input
            type="password"
            className="form-control"
            name="password"
            value={password}
            onChange={this.handleChange}
            placeholder="Password"
          />
          <span style={{ color: "red" }}>{errors["password"]}</span>
          <input
            type="text"
            className="form-control"
            name="name"
            value={name}
            onChange={this.handleChange}
            placeholder="Name"
          />
          <span style={{ color: "red" }}>{errors["name"]}</span>
          <br />
          <input
            type="submit"
            onClick={this.handleSubmit}
            value="Send"
            className="btn btn-primary"
            disabled={!this.state.validForm}
          />
        </form>
        <span style={{ color: "green" }}> {status}</span>
      </div>
    );
  }
}
