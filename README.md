# ![One37 Logo](https://www.one37id.com/images/Logo-2.svg)

One37 Business Connector - Local Development

Assets for a developer to setup a local instanceof the One37 Business Connector using pre-built docker containers.

## Background

The robust One37 Business Connector unlocks the reuse of Verifiable Credentials to business applications, ensuring accuracy, completeness, and trust of data without any added burden or lengthy form-filling.

The Business connector offers a 'black-box' solution to bridge existing business applications with the decentralised world of Verifiable Credentials.

This is achieved with simple RESTful API integration and No-Code visual design for customer facing workflows.

## Installation

### Requirements

The developer host instance will need to meet the following requirements:

* **Linux OS distribution (free tier Compute instance from any cloud provider)**
* **Docker** installed with **docker-compose** support.
* A **Public Internet address** with **DIRECT SSH & HTTPS** inbound access
* One37 issued **Docker Registry access credentials**
* Appropriate code editing tools for your chosen software development languages. eg [**VSCode**](https://code.visualstudio.com/)

### Setup

Sign-in to GitHub and Fork the following repository to your own account.
[https://github.com/One37ID/business-connector-dev.git](https://github.com/One37ID/business-connector-dev.git)

#### Host Setup

Create a Linux based Virtual machine in any cloud provider or compute environment of your choice.
It **MUST** meet the requirements as stipulated above.

This guide will not detail the steps required for this, but you may find and example procedure for an AWS EC2 setup in the `Host-Setup-AWS.md` file in this repo.

Once you have a a running host, connect to it's shell interface and clone down your forked repo to a host working folder.

``` bash
git clone https://github.com/YOUR_OWN_ACCOUNT/business-connector-dev.git
```

As of the latest release, your local folder contents should look like this.

``` powershell
Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
d----          2022/06/09    14:19                .media
d----          2022/06/09    12:12                agent
d----          2022/06/09    12:14                data
-a---          2022/06/06    10:48              0 .dockerignore
-a---          2022/06/09    11:53           6621 .gitignore
-a---          2022/06/09    12:31           4601 COPYME-config.json
-a---          2022/06/09    12:16           1130 docker-compose.yml
-a---          2022/06/09    14:44           1752 Host-Setup-AWS.md
-a---          2022/06/09    14:47           7469 README.md
-a---          2022/06/09    12:31            195 login.sh
-a---          2022/06/09    12:31            195 run-agent.sh
-a---          2022/06/06    10:50             21 stop.bat
```

## Usage

### Customize docker-compose.yml

Before starting the Business Connector, it may be preferred to modify several parameters that are present in the `docker-compose.yml` file.
For instance the file has values which define passwords for access to the Redis and PostgreSQL instances and these should be changed for better security.

``` yaml
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

Start the services into config mode with the provided shell script in the project folder.

**NOTE:** The `login.sh` file must be edited to include the **One37 Registry Credentials** you have been issued.

``` bash
./login.sh
./run-agent.sh
```
<br>
NOTE: The .sh files might need to be marked as executable after the first repo pull.
<br>
```
chmod +x *.sh
```
<br>
After it has started you can confirm this by pointing your browser to the public hostname of your VM instance.

You can also attach to the logs of the services (best done in a second terminal session)
<br>
```
docker-compose logs -f
```

### Access and Configuration

After the agent service reports that it has started the web server, you can confirm this by pointing your browser to the URL comprising of the **public hostname** of your VM instance followed by `/swagger`.

``` url
https://[yourvominstance.hostname.com]/swagger
```

You should see the **Swagger API UI**.
You may get Certificate error messages in the browser if the EC2 load balancer has not been configured properly.

Using the Swagger UI, you can now deploy the required configuration to the Agent.
Click on `TRY it out` and use the value `Hash` in the first input fields. Leave the other fields empty.

For the body of the request we are going to paste a json configuration payload which we will create next.

#### Edit the config json

The source code provides a template config file `COPYME-config.json` which you should make a copy of to modify according to your environment.
Editing this on your workstation may be the easiest.

``` bash
cp COPYME-config.json dev.json
```

Edit dev.json and update the sections enclosed by `[ ]` before deployment:

Do a global search and replace in the file for `[INSTANCE.HOSTNAME]` replacing it with the hosts public DNS address (e.g. of the Load balancer)

at the `agency` level:

``` json
    "alias": "dev:[YOUR-AGENT-NAME]",
    "namespace": "com.[YOUR-AGENT-NAME]",
    "name": "[Your Agent Name]",
```
<br>
at `agency.security`: (seed values provided by one37)

``` json
      "seed": "[your000000000000000000000000seed]",
      "issuerSeed": "[your000000000000000000000000seed]",
      "walletKey": "[Your-Wallet-Passkey]"
```
<br>
at `agency.schema`: (DID provided by one37)

``` json
      "agentNym": "[Your-Generated-Did]",
```
<br>
Once the neccesary changes have been made, copy the entire contents and paste it into the Agent Swagger Config Set body input area.

Click `Execute` and you will see that in the logs that the agent container has restarted and is proceeding to set itself up.
Please wait until all activity ceases or make a note of any failure mesagges to determine a remedial course of action.

## Support

Please direct any support queries via the Issues function in the GitHub Repo.

## Authors and acknowledgment

This project was made possible by the following contributors:
G. De Beer (Dibbs\_ZA)
A. Podick

## License

For open source projects, say how it is licensed.