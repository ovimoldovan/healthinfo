import React, { Component, useState } from "react";
import { Route } from "react-router";
import { Layout } from "./components/Layout";
import { Home } from "./components/Home";
import { FetchData } from "./components/FetchData";
import { Counter } from "./components/Counter";
import { Login } from "./components/Login";
import { userService } from "./services/user.service";
import { PrivateRoute } from "./components/PrivateRoute";

export default class App extends Component {
  static displayName = App.name;

  render() {
    return (
      <Layout>
        <PrivateRoute exact path="/" component={Home} />
        <Route path="/login" component={Login} />
      </Layout>
    );
  }
}
