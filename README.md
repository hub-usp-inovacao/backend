# README

[![Maintainability](https://api.codeclimate.com/v1/badges/8b317823f31c83a4bb3b/maintainability)](https://codeclimate.com/github/portal-solus/backend/maintainability)

This project adopts several Docker and Docker-Compose configurations, with different config files.
In order to simplify the management process, a `Makefile` is also present.


The targets are very similar between `dev` and `prod`, and for that they are presented in general terms -- the concrete targets are the following ones replacing `<env>` with either `dev` or `prod`.

The target are as follows, being necessary to run `make <target>`:

1. `build_<env>`
  builds the images necessary for the specified env adopting caches whenever possible;

2. `rebuild_<env>`
  also builds the images, but discards any cached layer;

3. `<env>`
  launches the containers with the latest images available, building them when there are none;

4. `stop_<env>`
  stops the containers that are running, removing them after stopping


In the `prod` environment, there are a few exclusive targets, as follows:

1. `fetch_prod`
  runs the rake task that fetches data from spreadsheets without generating any report;

2. `deploy`
  updates the repository and dispatch the deployment pipeline, building newer images, stopping running containers and running newer ones.
