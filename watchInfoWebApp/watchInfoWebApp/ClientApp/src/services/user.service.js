import { authHeader } from "../helper/auth-header";

export const userService = {
  login,
  logout,
  getAll,
  getAllProjects,
  getCurrentProject,
  getCurrentDataItem,
  getProjectDataById,
  deleteDataItemById,
  getProjectDataWithUserById,
};

function login(username, password) {
  const requestOptions = {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ username, password }),
  };

  return fetch(`Api/User/login`, requestOptions)
    .then(handleResponse)
    .then((user) => {
      if (user) {
        user.loggedIn = true;
        user.authdata = window.btoa(username + ":" + password);
        localStorage.setItem("user", JSON.stringify(user));
        console.log(user);
      }

      return user;
    });
}

function logout() {
  var refresh = false;
  if (localStorage.getItem("user")) {
    refresh = true;
  }
  localStorage.removeItem("user");
  if (refresh) {
    window.location.reload();
  }
}

function getAll() {
  const requestOptions = {
    method: "GET",
    headers: authHeader(),
  };

  return fetch(`Api/DataItem/`, requestOptions).then(handleResponse);
}

function getAllProjects() {
  const requestOptions = {
    method: "GET",
    headers: authHeader(),
  };

  return fetch(`Api/Project/getAllData`, requestOptions).then(handleResponse);
}

function getCurrentProject() {
  const requestOptions = {
    method: "GET",
    headers: authHeader(),
  };

  return fetch(`Api/Project/currentProject`, requestOptions).then(
    handleResponse
  );
}

function getProjectDataById(id) {
  const requestOptions = {
    method: "GET",
    headers: authHeader(),
  };

  return fetch(`Api/DataItem/getProjectData/` + id, requestOptions).then(
    handleResponse
  );
}

function getProjectDataWithUserById(id) {
  const requestOptions = {
    method: "GET",
    headers: authHeader(),
  };

  return fetch(
    `Api/DataItem/getProjectDataWithUser/` + id,
    requestOptions
  ).then(handleResponse);
}

function deleteDataItemById(id) {
  const requestOptions = {
    method: "DELETE",
    headers: authHeader(),
  };

  return fetch(`Api/DataItem/` + id, requestOptions).then(handleResponse);
}

function getCurrentDataItem(id) {
  const requestOptions = {
    method: "GET",
    headers: authHeader(),
  };

  return fetch(`Api/DataItem/` + id, requestOptions).then(handleResponse);
}

function handleResponse(response) {
  return response.text().then((text) => {
    const data = text && JSON.parse(text);
    if (!response.ok) {
      if (response.status === 401) {
        // auto logout if 401 response returned from api
        logout();
      }

      const error = (data && data.message) || response.statusText;
      return Promise.reject(error);
    }

    return data;
  });
}
