import React, { Component } from "react";
import { authHeader } from "../helper/auth-header";
import { userService } from "../services/user.service";
import "../custom.css";
import { OverlayTrigger, Popover } from "react-bootstrap";
export class AdminPanel extends Component {
  static displayName = "Project";
  constructor(props) {
    super(props);
    this.state = {
      user: {},
      name: "",
      projects: [],
      project: {},
      projectId: 0,
      dataItems: [],
      selectedUser: [],
      affectedUsername: "",
      affectedUsernameProjectId: 0,
    };
    this.handleChange = this.handleChange.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
    this.handleSubmitProject = this.handleSubmitProject.bind(this);
    this.handleChangeProjectByUser = this.handleChangeProjectByUser.bind(this);
  }

  handleChange(e) {
    const { name, value } = e.target;
    this.setState({ [name]: value });
  }

  handleSubmit(event) {
    event.preventDefault();
    const { name } = this.state;
    let user = JSON.parse(localStorage.getItem("user"));
    const requestOptions = {
      withCredentials: true,
      credentials: "include",
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: "Bearer " + user.token,
      },
      body: JSON.stringify({ name: name }),
    };

    console.log(requestOptions);

    return fetch(`Api/Project/newProject`, requestOptions).then(
      userService
        .getAllProjects()
        .then((projects) => this.setState({ projects }))
    );
  }

  handleSubmitProject(event) {
    event.preventDefault();
    const { projectId } = this.state;
    let user = JSON.parse(localStorage.getItem("user"));
    const requestOptions = {
      withCredentials: true,
      credentials: "include",
      method: "PUT",
      headers: {
        "Content-Type": "application/json",
        Authorization: "Bearer " + user.token,
      },
      body: JSON.stringify({ projectId: projectId }),
    };

    console.log(requestOptions);

    return fetch(`Api/User/changeProject/` + projectId, requestOptions).then(
      userService
        .getCurrentProject()
        .then((project) =>
          this.setState({ project }, () => console.log(this.state.project))
        )
    );
  }

  handleChangeProjectByUser(event) {
    event.preventDefault();
    const { affectedUsername, affectedUsernameProjectId } = this.state;
    let user = JSON.parse(localStorage.getItem("user"));
    const requestOptions = {
      withCredentials: true,
      credentials: "include",
      method: "PUT",
      headers: {
        "Content-Type": "application/json",
        Authorization: "Bearer " + user.token,
      },
      body: JSON.stringify({
        username: affectedUsername,
        projectId: affectedUsernameProjectId,
      }),
    };

    console.log(requestOptions);

    return fetch(
      `Api/User/changeProjectByUser/` +
        affectedUsername +
        `/` +
        affectedUsernameProjectId,
      requestOptions
    ).then(
      userService
        .getCurrentProject()
        .then((project) =>
          this.setState({ project }, () => console.log(this.state.project))
        )
    );
  }

  toogleUpdate() {
    userService
      .getCurrentProject()
      .then((project) => this.setState({ project }));
    this.setState(this.state);
  }

  componentDidMount() {
    this.setState({
      user: JSON.parse(localStorage.getItem("user")),
      projects: { loading: true },
    });
    userService
      .getAllProjects()
      .then((projects) => this.setState({ projects }));
    userService
      .getCurrentProject()
      .then((project) => this.setState({ project }));
  }

  selectProject(id) {
    userService
      .getProjectDataById(id)
      .then((dataItems) => this.setState({ dataItems }));
  }

  selectDataItem(id) {
    userService
      .getProjectDataWithUserById(id)
      .then((selectedUser) => this.setState({ selectedUser }));
  }

  formatDate(date) {
    var dateObject = new Date(date);
    var dayString = dateObject.toDateString();
    var hourString = dateObject.toLocaleTimeString();
    return dayString + " " + hourString;
  }
  render() {
    console.log(authHeader().token);
    const {
      name,
      projects,
      project,
      projectId,
      dataItems,
      selectedUser,
      affectedUsername,
      affectedUsernameProjectId,
    } = this.state;
    const popover = (
      <Popover id="popover-basic">
        <Popover.Title as="h6">by user:</Popover.Title>
        <Popover.Content>
          {selectedUser.name != null
            ? selectedUser.name
            : "No user data available"}
        </Popover.Content>
      </Popover>
    );

    console.log(selectedUser);
    return (
      <div>
        <form
          name="form"
          onSubmit={this.handleSubmit}
          className="grayOne col-md-12"
        >
          <h3>Add Projects</h3>
          <input
            type="text"
            className="form-control"
            name="name"
            value={name}
            onChange={this.handleChange}
          />
          <button
            type="submit"
            onClick={this.handleSubmit}
            className="btn btn-primary"
          >
            {" "}
            Add new project{" "}
          </button>
        </form>
        <div className="grayTwo col-md-12">
          <table className="col-md-12">
            <tbody>
              <tr>
                <td>
                  <div className="adminTable col-md-12">
                    <h4>List of projects</h4>
                    {projects.loading && <em>Loading data...</em>}
                    {projects.length && (
                      <ul>
                        {projects.map((project, index) => (
                          <li key={project.id}>
                            <button
                              onClick={() => this.selectProject(project.id)}
                              className="projectButton"
                            >
                              {"Name: " + project.name + ", id: " + project.id}
                            </button>
                          </li>
                        ))}
                      </ul>
                    )}
                  </div>
                </td>

                <td>
                  <div className="adminTable col-md-12">
                    <table
                      className="table table-striped"
                      aria-labelledby="tabelLabel"
                    >
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
                          <OverlayTrigger
                            trigger="click"
                            placement="top"
                            overlay={popover}
                            rootClose="mousedown"
                          >
                            <tr
                              key={dataItems.id}
                              onClick={() => this.selectDataItem(dataItems.id)}
                            >
                              <td>{dataItems.heartBpm}</td>
                              <td>{this.formatDate(dataItems.sentDate)}</td>
                              <td>{dataItems.gpsCoordinates}</td>
                              <td>{dataItems.steps}</td>
                              <td>{dataItems.distance}</td>
                              <td>{dataItems.device}</td>
                            </tr>
                          </OverlayTrigger>
                        ))}
                      </tbody>
                    </table>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
        <div className="grayOne col-md-12">
          <h4>Current project: {project.name + ", id: " + project.id}</h4>

          <form name="form2" onSubmit={this.handleSubmitProject}>
            <input
              type="text"
              className="form-control"
              name="projectId"
              value={projectId}
              onChange={this.handleChange}
            />
            <button
              type="submit"
              onClick={this.handleSubmitProject}
              className="btn btn-primary"
            >
              {" "}
              Change project{" "}
            </button>
          </form>
        </div>

        <div className="grayTwo col-md-12">
          <h4>Asign user to a project </h4>

          <form name="form2" onSubmit={this.handleChangeProjectByUser}>
            <input
              type="text"
              className="form-control"
              name="affectedUsername"
              value={affectedUsername}
              onChange={this.handleChange}
            />
            <input
              type="text"
              className="form-control"
              name="affectedUsernameProjectId"
              value={affectedUsernameProjectId}
              onChange={this.handleChange}
            />
            <button
              type="submit"
              onClick={this.handleChangeProjectByUser}
              className="btn btn-primary"
            >
              {" "}
              Change project{" "}
            </button>
          </form>
        </div>
        <p>© 2020 Ovidiu Moldovan</p>
      </div>
    );
  }
}
