# Hedge

Percy/GitHub integration to update GitHub pull request statuses without granting
Percy full read/write access to your repositories.

This runs as a server that listens for GitHub pull request and push webhooks,
polls the Percy API for build status based on the received SHAs, and updates
the GitHub API with corresponding status updates.

## Setup
Hedge has no external service dependencies, just run the server with
`mix run --no-halt`. (This means there is no persistence, so you will probably
need to override occasional builds if you let the server go down.)

Once it's running and available on the internet, set up a GitHub webhook
pointing to the `/hooks` endpoint of your server, and configure it to send only
`pull_request` events.
