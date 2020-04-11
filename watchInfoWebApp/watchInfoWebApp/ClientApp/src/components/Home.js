import React, { Component } from "react";
import { Link } from "react-router-dom";
import { userService } from "../services/user.service";

export class Home extends Component {
  static displayName = Home.name;

  constructor(props) {
    super(props);

    this.state = {
      user: {},
      dataItems: [],
    };
  }

  componentDidMount() {
    this.setState({
      user: JSON.parse(localStorage.getItem("user")),
      dataItems: { loading: true },
    });
    userService.getAll().then((dataItems) => this.setState({ dataItems }));
  }

  render() {
    const { user, dataItems } = this.state;
    console.log(user);
    return (
      <div className="col-md-6 col-md-offset-3">
        <h1>Hi, {user.name}!</h1>
        <h4>My data:</h4>
        {dataItems.loading && <em>Loading data...</em>}
        {dataItems.length && (
          <ul>
            {dataItems.map((dataItems, index) => (
              <li key={dataItems.id}>
                {"BPM: " + dataItems.heartBpm + " at " + dataItems.sentDate}
              </li>
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
