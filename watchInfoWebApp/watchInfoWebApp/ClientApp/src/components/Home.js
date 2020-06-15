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

  deleteDataItem(id) {
    var dataItems = this.state.dataItems.filter((item) => item.id !== id);

    this.setState({ dataItems });

    userService.deleteDataItemById(id);
    /*.then(
        userService.getAll().then((dataItems) => this.setState({ dataItems }))
      ); */
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
                <th>Controls</th>
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
                  <td>
                    <button
                      className="btn btn-danger"
                      onClick={() => this.deleteDataItem(dataItems.id)}
                    >
                      Delete
                    </button>
                  </td>
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
