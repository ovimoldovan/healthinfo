import React, { Component } from "react";
import { userService } from "../services/user.service";
import { Button, FormGroup, FormControl, FormLabel } from "react-bootstrap";

export class Login extends Component {
  constructor(props) {
    super(props);

    userService.logout();

    this.state = {
      username: "",
      password: "",
      submitted: false,
      loading: false,
      error: "",
    };

    this.handleChange = this.handleChange.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
  }

  handleChange(e) {
    const { name, value } = e.target;
    this.setState({ [name]: value });
  }

  handleSubmit(e) {
    e.preventDefault();
    this.setState({ submitted: true });
    const { username, password, returnUrl } = this.state;
    if (!(username && password)) {
      return;
    }

    this.setState({ loading: true });
    userService.login(username, password).then(
      (user) => {
        const { from } = this.props.location.state || {
          from: { pathname: "/" },
        };
        this.props.history.push(from);
        window.location.reload();
      },
      (error) => this.setState({ error, loading: false })
    );
  }

  render() {
    const { username, password, submitted, loading, error } = this.state;
    return (
      <center style={{ marginTop: 50 }}>
        <div className="col-md-6 col-md-offset-3">
          <h1 style={{ marginBottom: 15 }}>Login</h1>
          <form name="form" onSubmit={this.handleSubmit}>
            <div
              className={
                "form-group" + (submitted && !username ? " has-error" : "")
              }
            >
              <input
                type="text"
                className="form-control"
                name="username"
                value={username}
                onChange={this.handleChange}
                placeholder="Username"
              />
              {submitted && !username && (
                <div style={{ color: "red" }}>Username is required</div>
              )}
            </div>
            <div
              className={
                "form-group" + (submitted && !password ? " has-error" : "")
              }
            >
              <input
                type="password"
                className="form-control"
                name="password"
                value={password}
                onChange={this.handleChange}
                placeholder="Password"
              />
              {submitted && !password && (
                <div style={{ color: "red" }}>Password is required</div>
              )}
            </div>
            <div className="form-group">
              <input
                type="submit"
                onClick={this.handleSubmit}
                value="Login"
                className="btn btn-primary"
                disabled={loading}
              />

              {loading && (
                <img src="data:image/gif;base64,R0lGODlhEAAQAPIAAP///wAAAMLCwkJCQgAAAGJiYoKCgpKSkiH/C05FVFNDQVBFMi4wAwEAAAAh/hpDcmVhdGVkIHdpdGggYWpheGxvYWQuaW5mbwAh+QQJCgAAACwAAAAAEAAQAAADMwi63P4wyklrE2MIOggZnAdOmGYJRbExwroUmcG2LmDEwnHQLVsYOd2mBzkYDAdKa+dIAAAh+QQJCgAAACwAAAAAEAAQAAADNAi63P5OjCEgG4QMu7DmikRxQlFUYDEZIGBMRVsaqHwctXXf7WEYB4Ag1xjihkMZsiUkKhIAIfkECQoAAAAsAAAAABAAEAAAAzYIujIjK8pByJDMlFYvBoVjHA70GU7xSUJhmKtwHPAKzLO9HMaoKwJZ7Rf8AYPDDzKpZBqfvwQAIfkECQoAAAAsAAAAABAAEAAAAzMIumIlK8oyhpHsnFZfhYumCYUhDAQxRIdhHBGqRoKw0R8DYlJd8z0fMDgsGo/IpHI5TAAAIfkECQoAAAAsAAAAABAAEAAAAzIIunInK0rnZBTwGPNMgQwmdsNgXGJUlIWEuR5oWUIpz8pAEAMe6TwfwyYsGo/IpFKSAAAh+QQJCgAAACwAAAAAEAAQAAADMwi6IMKQORfjdOe82p4wGccc4CEuQradylesojEMBgsUc2G7sDX3lQGBMLAJibufbSlKAAAh+QQJCgAAACwAAAAAEAAQAAADMgi63P7wCRHZnFVdmgHu2nFwlWCI3WGc3TSWhUFGxTAUkGCbtgENBMJAEJsxgMLWzpEAACH5BAkKAAAALAAAAAAQABAAAAMyCLrc/jDKSatlQtScKdceCAjDII7HcQ4EMTCpyrCuUBjCYRgHVtqlAiB1YhiCnlsRkAAAOwAAAAAAAAAAAA==" />
              )}
            </div>
            {error && <div className={"alert alert-danger"}>{error}</div>}
          </form>
        </div>
      </center>
    );
  }
}
