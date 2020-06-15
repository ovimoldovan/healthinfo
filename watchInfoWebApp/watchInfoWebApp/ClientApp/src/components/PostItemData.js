import React, { Component } from "react";
import { authHeader } from "../helper/auth-header";

export class PostItemData extends Component {
  static displayName = "PostItemData";
  constructor(props) {
    super(props);
    this.state = { heartBpm: 0, errors: {}, validForm: false, status: "" };
    this.handleChange = this.handleChange.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
  }

  handleChange(e) {
    const { name, value } = e.target;
    this.setState((state) => {
      state[name] = value;

      if (state.heartBpm == "" || state.heartBpm == 0) {
        state.errors["name"] = "If you're sending BPMs, you're probably alive.";
        state.validForm = false;
      } else {
        state.errors["name"] = undefined;
        state.validForm = true;
      }
      state.status = "";
      return state;
    });
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

    this.setState((state) => {
      state.validForm = false;
      state.status = "Sent.";
      return state;
    });

    return fetch(`Api/DataItem`, requestOptions);
  }

  render() {
    console.log(authHeader().token);
    const { heartBpm, errors, status } = this.state;
    return (
      <div>
        <h1>Send BPM data</h1>

        <form name="form" onSubmit={this.handleSubmit}>
          <input
            type="number"
            className="form-control"
            name="heartBpm"
            value={heartBpm}
            onChange={this.handleChange}
          />
          <input
            type="submit"
            onClick={this.handleSubmit}
            value="Send"
            className="btn btn-primary"
            disabled={!this.state.validForm}
          />
        </form>
        <span style={{ color: "red" }}>{errors["name"]}</span>
        <span style={{ color: "green" }}> {status}</span>
      </div>
    );
  }
}
