# Test Funnel + Slurm

This repository relies on two other repositories:

* `funnel`, hosted in GitHub at: <https://github.com/ohsu-comp-bio/funnel.git>
* `slurmtestenvironment`, hosted in our internal GitLab at: <https://gitlab.ci.csc.fi/compen/css/slurmtestenvironment.git>

both are added as submodules to this repository.

## Deployment

First init the submodules:

```
git submodule init funnel
git submodule init slurmtestenvironment
```

then update them:

```
git submodule update funnel
git submodule update slurmtestenvironment
```

### Slurm deployment

Follow the instructions in the `slurmtestenvironment` repo README. Once the requirements are met and as advised in the aforementioned README, run:

```
source ~/project_2001012-openrc.sh
ansible-playbook -i inventory site.yml
```

The file `~/project_2001012-openrc.sh` must be downloaded from OpenStack. This will create 4 VM nodes in the project `2001012`, one login node (`slurm-login`), an Ondemand node (`ondemand-login`), and two compute nodes (`compute0` and `compute1`).

### Funnel deployment

First it is necessary to build funnel. After installing the necessary depedencies (TODO), the build can be done by:

```
make build
````

Then 3 files must be copied to the `slurm-login` node:

* `funnel`, must be copied to `/nfs/home/slurmer/bin/`.
* `funnel_config.yml`, must be copied to `/nfs/home/slurmer/etc/`. The folder must be created.
* `deployments/systemd/funnel-server.service`, the paths must be fixed and the file copied to `/usr/lib/systemd/system/`:

```
sed -e 's#/path/to/funnel#/nfs/home/slurmer/bin/funnel#' -e 's#/path/to/funnel/config.yml#/nfs/home/slurmer/etc/funnel_config.yml#' deployments/systemd/funnel-server.service > ../funnel-server.service
echo 'User=slurmer' >>../funnel-server.service
echo 'Group=slurmer' >>../funnel-server.service
```

```
sudo systemctl enable funnel-server
sudo systemctl start funnel-server
```

## Testing

First test the webinterface. It should be available at `LOGIN_NODE_IP:8000`:

![Funnel website](funnel-website.png)

If there is any problem to connect, the usual culprit is the SecurityGroups configuration.

Then try the API with this [funnel client](funnel-client.sh). You must edit the file and set the `IP` variable to the frontend IP.

* `List`:

```
$ ./funnel-client.sh
{}
```

* `New`:

```
$ ./funnel-client.sh new
{"id":"cdbphhl8nr8u7sqrhg6g"}
```

`cdbphhl8nr8u7sqrhg6g` is the id of the job just created.

* `view`:

```
$ ./funnel-client.sh view cdbrqllckctob4vs9du0
{
  "id": "cdbrqllckctob4vs9du0",
  "state": "COMPLETE"
}
```

```
$ VIEW=BASIC ./funnel-client.sh view cdbrqllckctob4vs9du0
{
  "id": "cdbrqllckctob4vs9du0",
  "state": "COMPLETE",
  "name": "Hello world",
  "description": "Demonstrates the most basic echo task.",
  "executors": [
    {
      "image": "alpine",
      "command": [
        "echo",
        "hello world"
      ]
    }
  ],
  "logs": [
    {
      "logs": [
        {
          "start_time": "2022-10-25T10:41:27.927578626Z",
          "end_time": "2022-10-25T10:41:30.912919765Z"
        }
      ],
      "metadata": {
        "hostname": "compute0",
        "slurm_id": "45"
      },
      "start_time": "2022-10-25T10:41:27.913952746Z",
      "end_time": "2022-10-25T10:41:30.92044549Z"
    }
  ],
  "creation_time": "2022-10-25T10:41:26.786274179Z"
}
```

