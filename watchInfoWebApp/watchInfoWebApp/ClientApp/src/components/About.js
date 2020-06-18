import React, { Component } from "react";
import espImage from "./img/esp32.PNG";
import watchImage from "./img/watchos.jpg";
import phoneImage from "./img/ios.png";

export class About extends Component {
  static displayName = About.name;

  constructor(props) {
    super(props);
    this.state = { loading: true };
  }

  componentDidMount() {}

  render() {
    return (
      <div>
        <h1 id="tabelLabel">About</h1>
        <p>
          This page shows the progress of the applications on the iPhone, the
          Apple Watch and the ESP32.
          <table className="col-md-12">
            <tr>
              <td>
                {" "}
                <img src={phoneImage} width="300" />
              </td>
              <td>
                {" "}
                <img src={watchImage} width="300" />
              </td>{" "}
              <td>
                {" "}
                <img src={espImage} width="300" />
              </td>
            </tr>
          </table>
        </p>
        <br />
      </div>
    );
  }
}
