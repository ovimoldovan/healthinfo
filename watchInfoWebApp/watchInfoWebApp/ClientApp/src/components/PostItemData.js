import React, { Component } from "react";
import { authHeader } from "../helper/auth-header";

export class PostItemData extends Component {
  static displayName = "PostItemData";
  constructor(props) {
    super(props);
    this.state = { heartBpm: 0 };
    this.handleChange = this.handleChange.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
  }

  handleChange(e) {
    const { name, value } = e.target;
    this.setState({ [name]: value });
  }

  handleSubmit(event) {
    event.preventDefault();
    const { heartBpm } = this.state;
    let user = JSON.parse(localStorage.getItem("user"));
    const requestOptions = {
      withCredentials: true,
      credentials: "include",
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: "Bearer " + user.token,
      },
      body: JSON.stringify({ heartBpm: parseInt(heartBpm) }),
    };

    console.log(requestOptions);

    return fetch(`http://localhost:5000/Api/DataItem`, requestOptions);
  }

  render() {
    console.log(authHeader().token);
    const { heartBpm } = this.state;
    return (
      <div>
        <h1>Send BPM data</h1>

        <form name="form" onSubmit={this.handleSubmit}>
          <input
            type="text"
            className="form-control"
            name="heartBpm"
            value={heartBpm}
            onChange={this.handleChange}
          />
          <input
            type="submit"
            onClick={this.handleSubmit}
            value="Login"
            className="btn btn-primary"
          />
        </form>
      </div>
    );
  }
}
