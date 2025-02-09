import React, { Component } from "react";
import {
  Collapse,
  Container,
  Navbar,
  NavbarBrand,
  NavbarToggler,
  NavItem,
  NavLink,
} from "reactstrap";
import { Link } from "react-router-dom";
import "./NavMenu.css";
import { userService } from "../services/user.service";
import logo from "./img/logo.png";

export class NavMenu extends Component {
  static displayName = NavMenu.name;

  constructor(props) {
    super(props);

    this.toggleNavbar = this.toggleNavbar.bind(this);
    this.state = {
      collapsed: true,
      user: {},
    };
    this.update = this.update.bind(this);
  }

  toggleNavbar() {
    this.setState({
      collapsed: !this.state.collapsed,
    });
  }

  componentDidMount() {
    this.setState({
      user: JSON.parse(localStorage.getItem("user")),
    });
  }

  update() {
    this.setState({
      user: JSON.parse(localStorage.getItem("user")),
    });
  }

  logout() {
    localStorage.removeItem("user");
  }

  render() {
    const userStatus = this.state;
    var isAuth;
    console.log(userStatus);
    return (
      <header>
        <Navbar
          className="navbar-expand-sm navbar-toggleable-sm ng-white border-bottom box-shadow mb-3"
          light
        >
          <Container>
                    <NavbarBrand tag={Link} to="/" >
                        <div>
                            <img src={logo} height="50" />
                            <div style={{marginBottom: '0'}} >Health Info </div>
                        </div>
            </NavbarBrand>
            <NavbarToggler onClick={this.toggleNavbar} className="mr-2" />
            <Collapse
              className="d-sm-inline-flex flex-sm-row-reverse"
              isOpen={!this.state.collapsed}
              navbar
            >
              <ul className="navbar-nav flex-grow">
                <NavItem>
                  <NavLink tag={Link} className="text-dark" to="/">
                    Home
                  </NavLink>
                </NavItem>
                <NavItem>
                  <NavLink tag={Link} className="text-dark" to="/AdminPanel">
                    {userStatus.user != null
                      ? userStatus.user.role == "Admin"
                        ? "Admin Panel"
                        : null
                      : null}
                  </NavLink>
                </NavItem>
                <NavItem>
                  <NavLink tag={Link} className="text-dark" to="/fetch-data">
                    Fetch data
                  </NavLink>
                </NavItem>
                <NavItem>
                  <NavLink tag={Link} className="text-dark" to="/PostItemData">
                    {userStatus.user != null ? "Post Item" : null}
                  </NavLink>
                </NavItem>
                <NavItem>
                  <NavLink tag={Link} className="text-dark" to="/Position-Data">
                    {userStatus.user != null ? "Position Map" : null}
                  </NavLink>
                </NavItem>
                <NavItem>
                  <NavLink
                    tag={Link}
                    className="text-dark"
                    to="/login"
                    onClick={() => this.update()}
                  >
                    {localStorage.getItem("user") ? "Logout" : "Login"}
                  </NavLink>
                </NavItem>
                <NavItem>
                  <NavLink
                    tag={Link}
                    className="text-dark"
                    to="/register"
                    onClick={() => this.update()}
                  >
                    {localStorage.getItem("user") ? null : "Register"}
                  </NavLink>
                </NavItem>
                <NavItem>
                  <NavLink tag={Link} className="text-dark" to="/about">
                    About
                  </NavLink>
                </NavItem>
              </ul>
            </Collapse>
          </Container>
        </Navbar>
      </header>
    );
  }
}
