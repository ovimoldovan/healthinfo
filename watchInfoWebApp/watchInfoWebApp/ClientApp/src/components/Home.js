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

  formatDate(date) {
    var dateObject = new Date(date);
    var dayString = dateObject.toDateString();
    var hourString = dateObject.toLocaleTimeString();
    return dayString + " " + hourString;
  }

  render() {
    const { user, dataItems } = this.state;
    return (
      <div className="col-md-12 col-md-offset-6">
        <h1>Hi, {user.name}!</h1>
        <h4>My data:</h4>
        {dataItems.loading && <em>Loading data...</em>}
        {dataItems.length && (
          <table className="table table-striped" aria-labelledby="tabelLabel">
            <thead>
              <tr>
                <th>BPM</th>
                <th>Date</th>
                <th>Position</th>
                <th>Steps</th>
                <th>Distance</th>
                <th>Device</th>
              </tr>
            </thead>
            <tbody>
              {dataItems.map((dataItems, index) => (
                <tr key={dataItems.id}>
                  <td>{dataItems.heartBpm}</td>
                  <td>{this.formatDate(dataItems.sentDate)}</td>
                  <td>{dataItems.gpsCoordinates}</td>
                  <td>{dataItems.steps}</td>
                  <td>{dataItems.distance}</td>
                  <td>{dataItems.device}</td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
        <p>
          <Link to="/login">Logout</Link>
        </p>
      </div>
    );
  }
}
