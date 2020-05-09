import React, { Component } from "react";
import { authHeader } from "../helper/auth-header";
import { userService } from "../services/user.service";

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
    };
    this.handleChange = this.handleChange.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
    this.handleSubmitProject = this.handleSubmitProject.bind(this);
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

    return fetch(
      `http://localhost:11940/Api/Project/newProject`,
      requestOptions
    ).then(
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

    return fetch(
      `http://localhost:11940/Api/User/changeProject/` + projectId,
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

  render() {
    console.log(authHeader().token);
    const { name, projects, project, projectId } = this.state;
    return (
      <div>
        <h1>Add Projects</h1>
        <form name="form" onSubmit={this.handleSubmit}>
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
            value="Add new project"
            className="btn btn-primary"
          >
            {" "}
            Submit{" "}
          </button>
        </form>
        <h1>List of projects</h1>
        {projects.loading && <em>Loading data...</em>}
        {projects.length && (
          <ul>
            {projects.map((projects, index) => (
              <li key={projects.id}>
                {"Name: " + projects.name + ", id: " + projects.id}
              </li>
            ))}
          </ul>
        )}
        <h6>Current project: {project.name + ", id: " + project.id}</h6>
        <button onClick={this.toggleUpdate}> Refresh</button>
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
            value="Change project"
            className="btn btn-primary"
          >
            {" "}
            Submit{" "}
          </button>
        </form>
      </div>
    );
  }
}
