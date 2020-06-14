import React, { Component } from "react";

export class FetchData extends Component {
  static displayName = FetchData.name;

  constructor(props) {
    super(props);
    this.state = { hour: [], loading: true };
  }

  componentDidMount() {
    this.populateHourData();
  }

  static renderHour(hour) {
    return <p>{hour}</p>;
  }

  render() {
    var contents = this.state.loading ? (
      <p>
        <em>Loading...</em>
      </p>
    ) : (
      FetchData.renderHour(this.state.hour)
    );

    var dateContents = new Date(this.state.hour).toDateString();
    var hourContents = new Date(this.state.hour).toLocaleTimeString();

    return (
      <div>
        <h1 id="tabelLabel">Server date</h1>
        <p>Fetching the server current date.</p>
        {dateContents}
        <br />
        {hourContents}
      </div>
    );
  }

  async populateHourData() {
    const response = await fetch("Api/General/hour");
    const data = await response.json();
    this.setState({ hour: data, loading: false });
  }
}
