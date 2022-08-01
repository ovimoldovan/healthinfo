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
                <div style={{ whiteSpace: 'pre-wrap' }}>
                    Hello! My name is Ovidiu Moldovan, I am an engineer in Automation and Computer Science from TUCN and this is my diploma project. <br/>
                    <br />
                    This project aims to collect data from a number of devices <br />
                    <br />
                    Currently supported: <br />
                    ESP32 modules, <br />
                    Apple Watch (watchOS 6.1 +), <br />
                    Apple iPhone (iOS 13.4+ for watch pairing, 14.0+ for sensors, 15.0+ for altitude/pressure sensors). <br />
                    <br />
                    If you wish to follow this project, you can do so on my <a href="https://github.com/ovimoldovan/watchKitSensors">Github repository. (might be private until its presentation)</a> <br />
                    <br />

                </div>

                <details>
                    <summary> Some photos from the development phase </summary>
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
                    </details>
        </p>
        <br />
      </div>
    );
  }
}
