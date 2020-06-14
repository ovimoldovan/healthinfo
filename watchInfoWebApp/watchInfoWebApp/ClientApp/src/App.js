import React, { Component, useState } from "react";
import { Route } from "react-router";
import { Layout } from "./components/Layout";
import { Home } from "./components/Home";
import { FetchData } from "./components/FetchData";
import { AdminPanel } from "./components/AdminPanel";
import { Login } from "./components/Login";
import { PrivateRoute } from "./components/PrivateRoute";
import { PostItemData } from "./components/PostItemData";
import { PositionData } from "./components/PositionData";

export default class App extends Component {
  static displayName = App.name;

  render() {
    return (
      <Layout>
        <PrivateRoute exact path="/" component={Home} />
        <Route path="/AdminPanel" component={AdminPanel} />
        <Route path="/Fetch-Data" component={FetchData} />
        <Route path="/Position-Data" component={PositionData} />
        <Route path="/PostItemData" component={PostItemData} />
        <Route path="/login" component={Login} />
      </Layout>
    );
  }
}
