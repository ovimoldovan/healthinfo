import React, { Component } from "react";
import { userService } from "../services/user.service";
import { CSVLink } from "react-csv";

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
  }

  render() {
    const { user, dataItems } = this.state;
      return (
        <div className="col-md-12 col-md-offset-6">
        <h1>Hi, {user.name}!</h1>
              <table> <tr> <td > <h4>My data:</h4> </td>
                  <td>
                      {dataItems.length && (<CSVLink data={dataItems} className="btn btn-info"> Download </CSVLink>)}
                  </td> </tr>
              </table>
        {dataItems.loading && <em>Loading data...</em>}
        {dataItems.length && (
          <center><table className="table table-striped" aria-labelledby="tabelLabel">
            <thead>
              <tr>
                <th>BPM</th>
                <th>Date</th>
                <th>Position</th>
                <th>Steps</th>
                <th>Distance (m)</th>
                <th>Temperature (C)</th>
                <th>Rel. Altitude (m)</th>
                <th>Abs. Altitude (m)</th>
                <th>Pressure (kPa)</th>
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
                  <td>{dataItems.temperature}</td>
                  <td>{dataItems.relativeAltitude}</td>
                  <td>{dataItems.absoluteAltitude}</td>
                  <td>{dataItems.pressure}</td>
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
                      </center>
        )}
        <p>© 2020-2022 Ovidiu Moldovan</p>
      </div>
    );
  }
}
