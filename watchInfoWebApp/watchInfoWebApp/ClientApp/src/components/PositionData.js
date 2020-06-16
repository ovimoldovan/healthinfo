import React, { Component } from "react";
import { userService } from "../services/user.service";
import Map from "pigeon-maps";
import Marker from "pigeon-marker";

export class PositionData extends Component {
  static displayName = PositionData.name;

  constructor(props) {
    super(props);

    this.handleMarkerClick = this.handleMarkerClick.bind(this);
    this.state = {
      user: {},
      dataItems: [],
      currentDataItem: {},
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

  handleMarkerClick(payload, anchor) {
    //console.log(`Marker #${payload} clicked at: `, anchor);
    var currentDataItem = userService
      .getCurrentDataItem(payload)
      .then((currentDataItem) => this.setState({ currentDataItem }));
  }

  render() {
    const { user, dataItems } = this.state;
    //MAPS
    console.log(dataItems);

    var gpsData = [];

    for (var i = 0; i < dataItems.length; i++) {
      if (dataItems[i].gpsCoordinates != null) {
        gpsData.push(dataItems[i].gpsCoordinates);
        gpsData.push(dataItems[i].id);
      }
    }

    console.log(gpsData);

    var gpsDataSplit = [];

    if (gpsData[0] != null && gpsData[0][0] != null) {
      //console.log(gpsData[0].split(" "));
      for (var i = 0; i < gpsData.length; i++) {
        if (gpsData[i][0] != null) {
          gpsDataSplit[i] = gpsData[i].split(" ");
          gpsDataSplit[i].push(gpsData[i + 1]);
        }
      }
    }

    //var gpsDataSplit = gpsData[0].toString().split(" ");

    console.log(gpsDataSplit);

    for (i = 0; i < gpsDataSplit.length; i += 2) {
      gpsDataSplit[i][0] = parseFloat(gpsDataSplit[i][0]);
      gpsDataSplit[i][1] = parseFloat(gpsDataSplit[i][1]);
    }
    var _this = this;
    return (
      <div className="col-md-12 col-md-offset-6">
        <table>
          <tr>
            <td>
              <h1>Hi, {user.name}!</h1>
              <h4>My data:</h4>
              {dataItems.loading && <em>Loading data...</em>}
              {
                /*gpsDataSplit[0] != null &&  */

                <Map
                  center={
                    gpsDataSplit[0] != null
                      ? [gpsDataSplit[0][0], gpsDataSplit[0][1]]
                      : [0, 0]
                  }
                  zoom={17}
                  width={600}
                  height={400}
                >
                  {gpsDataSplit[0] != null &&
                    gpsDataSplit.map(function (elem, index) {
                      return (
                        <Marker
                          anchor={[elem[0], elem[1]]}
                          payload={elem[2]}
                          onClick={({ event, anchor, payload }) => {
                            _this.handleMarkerClick(payload, anchor);
                          }}
                        />
                      );
                    })}
                </Map>
              }
            </td>
            <td>
              {this.state.currentDataItem.heartBpm == null && (
                <div className="p-3">
                  <h3>Select a data point </h3>
                </div>
              )}
              <div className="col-md-3 col-md-offset-3">
                <table
                  className="table table-striped"
                  aria-labelledby="tabelLabel"
                >
                  <thead>
                    <tr>
                      <th>BPM</th>
                      <th>Date</th>
                      <th>Steps</th>
                      <th>Distance</th>
                      <th>Device</th>
                    </tr>
                  </thead>
                  <tbody>
                    {this.state.currentDataItem.heartBpm && (
                      <tr>
                        <td>{this.state.currentDataItem.heartBpm}</td>
                        <td>
                          {this.formatDate(this.state.currentDataItem.sentDate)}
                        </td>
                        <td>{this.state.currentDataItem.steps}</td>
                        <td>{this.state.currentDataItem.distance}</td>
                        <td>{this.state.currentDataItem.device}</td>
                      </tr>
                    )}
                  </tbody>
                </table>
              </div>
            </td>
          </tr>
        </table>
      </div>
    );
  }
}
