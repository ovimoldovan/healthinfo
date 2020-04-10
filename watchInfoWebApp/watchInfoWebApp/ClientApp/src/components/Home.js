import React, { Component } from "react";
import { Link } from "react-router-dom";
import { userService } from "../services/user.service";

export class Home extends Component {
  static displayName = Home.name;

  constructor(props) {
    super(props);

    this.state = {
      user: {},
      users: [],
    };
  }

  componentDidMount() {
    this.setState({
      user: JSON.parse(localStorage.getItem("user")),
      users: { loading: true },
    });
    userService.getAll().then((users) => this.setState({ users }));
  }

  render() {
    const { user, users } = this.state;
    console.log(user);
    return (
      <div className="col-md-6 col-md-offset-3">
        <h1>Hi, {user.name}!</h1>
        <p>You're logged in with React & Basic HTTP Authentication!!</p>
        <h3>Users from secure api end point:</h3>
        {users.loading && <em>Loading users...</em>}
        {users.length && (
          <ul>
            {users.map((user, index) => (
              <li key={user.id}>{user.name + " " + user.lastName}</li>
            ))}
          </ul>
        )}
        <p>
          <Link to="/login">Logout</Link>
        </p>
      </div>
    );
  }
}
