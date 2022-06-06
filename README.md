# ![One37 Logo](https://www.one37id.com/images/Logo-2.svg)

One37 Business Connector - Local Development

Assets for a developer to setup a local instanceof the One37 Business Connector using pre-built docker containers.

## Background

The robust One37 Business Connector unlocks the reuse of Verifiable Credentials to business applications, ensuring accuracy, completeness, and trust of data without any added burden or lengthy form-filling.

The Business connector offers a 'black-box' solution to bridge existing business applications with the decentralised world of Verifiable Credentials.

This is achieved with simple RESTful API integration and No-Code visual design for customer facing workflows.

## Installation

### Requirements

The developer workstation will need to meet the following requirements:

* **Windows 10+** or **Apple MacOS 14+** or **Linux OS distribution**
* **Docker Desktop or Docker CE** installed with **docker-compose** support.
* A Public Internet address or Inward traffic routing solution like [Ngrok](https://ngrok.com/docs/getting-started)
* One37 issued Docker Registry access credentials
* Appropriate code editing tools for your chosen software development languages. eg [VSCode](https://code.visualstudio.com/)

### Setup

Sign-in to GitHub and Fork the following repository to your own account.
[https://github.com/One37ID/business-connector-dev.git](https://github.com/One37ID/business-connector-dev.git)

At the command line interface for the relevant operating system, clone the new forked repo to a local working folder.

``` bash
git clone https://github.com/YOUR_OWN_ACCOUNT/business-connector-dev.git
```

As of the latest release, your local folder contents should look like this.

``` powershell
Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
-a---          2022/06/02    12:39           6594 .gitignore
-a---          2022/06/02    15:20           5874 COPYME-config.json
-a---          2022/06/02    13:48           1268 docker-compose.yml
-a---          2022/06/04    12:33           7322 README.md
-a---          2022/06/05    09:32             42 run-agent.bat
-a---          2022/06/05    09:32             42 run-agent.sh
```
<br>
Setup `ngrok` as per it's platform specific installation instructions.

## Usage

### Customize docker-compose.yml

Before starting the Business Connector, it may be preferred to modify several parameters that are present in the `docker-compose.yml` file.
For instance the file has values which define passwords for access to the Redis and PostgreSQL instances and these should be changed for better security.
<br>
```
version: '1.0'
services:
  db:
    image: postgres:14.1-alpine
    restart: always
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=postgres
    ports:
      - '5432:5432'
    volumes:
      - db:/var/lib/postgresql/data
  cache:
    image: redis:latest
    restart: always
    ports:
      - '6379:6379'
    command: redis-server --save 20 1 --loglevel warning --requirepass your-redis-Password
    volumes:
      - cache:/data
  agent:
    image: registry.gitlab.com/one37id/registry/solitaire/staging
    depends_on:
      - db
      - cache
    ports:
      - 3000:3000
    environment:
      - ASPNETCORE_ENVIRONMENT=Development
      - MINIMUM_LOG_LEVEL=1
      - AGENT_SETUP_MODE=true
      - RECREATE_WORKFLOWS=false
      - DELETE_REDIS_CONFIG=false
      - KESTREL_PORT=3000
      - AUTH_REQUEST_MAX_TTL_MINUTES=1
      - AUTH_BACKDOOR_SECRET_KEY=LocalDevHash
      - AUTH_SECRET_KEY=EzAKoAxdivooooooooooooofIgb5zHOi
      - AUTH_NONCE_TTL_MINUTES=1
      - REDIS_HOST=cache
      - REDIS_PORT=6379
      - REDIS_PASSWORD=your-redis-Password
    links:
      - db
      - cache
volumes:
  cache:
    driver: local
  db:
    driver: local
```

### Start the services

Start the services into config mode with the appropriate `run-agent` shell script for your environment or this command in the project folder:

``` bash
docker-compose -f docker-compose.yml up -d
```

After it has started you can confirm this by pointing your browser to

[http://localhost:3000/swagger](http://localhost:3000/swagger)

In order to be able to communicate with this instance from the Upa! Wallet App, it will need to be publicly accessible.

Start ngrok as follows to make a publicly accessible network tunnel.
<br>
```
ngrok http 3000
```

It will set up the tunnel and output a **Forwarding URL** that will need to be captured into the service's configuration as detailed below.

**Note:**
Unless you have a paid subscription to ngrok with custom domains configured, this **forwarding** value will only be valid for **this session** and the config will need updating each time ngrok is restarted.

### Access and Configuration

You must also make a copy of `COPYME.config.json` and alter it to match any modifications made to the redis or postgres db connection credentials and ports.

Also update the `hostName` and `agency.callbackUrl` host path values based on the **Forwarding URL** generated by **ngrok**

Test access to the Swagger URL using the Ngrok hostname.

Yopu should see this:

<br>
## Support

Tell people where they can go to for help. It can be any combination of an issue tracker, a chat room, an email address, etc.

## Roadmap

If you have ideas for releases in the future, it is a good idea to list them in the README.

## Contributing

State if you are open to contributions and what your requirements are for accepting them.

For people who want to make changes to your project, it's helpful to have some documentation on how to get started. Perhaps there is a script that they should run or some environment variables that they need to set. Make these steps explicit. These instructions could also be useful to your future self.

You can also document commands to lint the code or run tests. These steps help to ensure high code quality and reduce the likelihood that the changes inadvertently break something. Having instructions for running tests is especially helpful if it requires external setup, such as starting a Selenium server for testing in a browser.

## Authors and acknowledgment

Show your appreciation to those who have contributed to the project.

## License

For open source projects, say how it is licensed.

## Project status

If you have run out of energy or time for your project, put a note at the top of the README saying that development has slowed down or stopped completely. Someone may choose to fork your project or volunteer to step in as a maintainer or owner, allowing your project to keep going. You can also make an explicit request for maintainers.