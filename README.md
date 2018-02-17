# Laniakea Spark Worker Provisioning

## Set up a new worker

### Set up a system to host the worker
Install a buildd host using one of our supported releases:
   * Tanglu Elysia
   * Debian Buster
   * PureOS 8.0

For more information see [README.host.md](README.host.md).

### Update the Ansible Playbooks
This configuration was made to work for Tanglu and PureOS - you will have to edit
it and adjust the Ansible Playbook variables to your needs to make it work for
your purpose.
The instructions also use Tanglu or PureOS as example.adjust accordingly.

### Generate the Builder Keys
- Note1: The rng-tools and urandom may help if you don't have enough entropy
         (use with care and inform yourself about what these tools do before using them!).
- Note2: During provisioning ansible will install haveged in the builders to
         help with automated key generation that's needed for sbuild internals.
         You might not want to generate the Builder PGP and SSL keys on a
         provisioned builder.

Do the following steps on some machine that is not the `worker` host.

#### Pick a name
For Tanglu: Pick the name of a chemical element as `buildd` machine name. Check out
[the Debile web interface](http://buildd.tanglu.org/) for a list of existing names.
For other distributions, just pick a unique name.

#### Generate a GPG key
Run
```
gpg --full-generate-key
```
to start generating a new GPG key.

In the interactive prompt enter the following key information:
- Use key type number 4 (*RSA*)
- Use *4096* bit as keysize
- Set a key validity time some time between 1 and 5 years and confirm the displayed date with `y`
- The "real name" should have the following form: `"Tanglu <element> Buildd"`
  (where `<element>` is the name of the element you have picked in the last step)
  - Example: `"Tanglu Helium Buildd"`
- The "email address" should have the following form: `"<element>@buildd.tanglu.org"`
  (where `<element>` is again the name of the element you have picked in the last step)
  - Example: `"helium@buildd.tanglu.org"`.

Wait for the key generation to complete, once all questions are answered.

Finally export the GPG secret and public key:
- If you haven´t done so already, clone this Git repository to a local directory
  (`git clone https://github.com/lkorigin/spark-setup.git`) and open that directory in your shell
- Navigate to the `ansible/keys` subdirectory (so that the provisioning system can find the keys)
- Run these commands to export the GPG secret key and public key and protect the secret key file:
```
gpg --export-secret-key -a <element>@buildd.tanglu.org > <element>_secret.gpg && \
gpg --armor --export "<element>@buildd.tanglu.org" > <element>.gpg && \
chmod go-rwx *secret.gpg
```

#### Generate the CurveZMQ encryption keys

Make sure you're still in the `ansible/keys` subdirectory of your local copy of this Git repository.

Invoke the `lk-keytool` command of the Laniakea suite to generate a TLS key and certificate for your future Debile instance:
```
lk-keytool cert-new --name=<element> --email='<element>@buildd.tanglu.org' --organization='Tanglu Project' <element>
```
Don´t forget to replace `<element>` with the name of your `buildd` machine name.

### Provision the builder

We use `ansible` to setup the builder instances for Tanglu. Some background information on how
`ansible` works can be found on [its web pages](http://www.ansible.com/how-ansible-works).

#### Requirements and Preparation

In order to use `ansible` for provisioning, the following conditions must be met:

 1. The builder instance must to be accessible using SSH
 2. The target SSH user must be allowed to use `sudo` to obtain superuser privileges
 3. You must be able to log into the SSH server, with the desired target user, using
    [Public-key authentication](https://wiki.archlinux.org/index.php/SSH_keys)
 4. The [`hostname`](https://wiki.debian.org/HowTo/ChangeHostname#Core_networking) of the builder
    instance must match the `<element>` name used above
 5. All the packages mentioned in [README.host.md](README.host.md) must be installed on the
    builder instance

Once you have ensured that all of the above conditions are met, you may add the address of the
builder to the `ansible`´s inventory in `/etc/ansible/hosts`:
```
[ tanglu-buildd ]
<builder address>
```
Where `<builder address>` is the server name or IP address of your builder instance.

#### Provision the builder

Party time!

Run the following command in the root directory of your local copy of this Git repository:
```
ansible-playbook -K -u <remote user> -l <builder address> ansible/playbook.yml
```
Where `<remote user>` is the name of the target SSH user and `<builder address>` is again the 
server name or IP address of your builder instance.

`ansible` will ask you for the `sudo` password of the remote user. Once you have entered it, you can
sit back and watch as the builder gets set up. :grinning:

#### Post-setup tasks

Once `ansible` finishes, the builder should be restarted so `systemd` can properly start the
`laniakea-spark`-slave service. After this the builder should be ready and ask the master for new jobs.

Register the builders GPG key with DAK on the master server, and add the builder's public key to
Laniakea's trusted key pool on the master server.

## Vagrant

For testing/development purposes you can set up a Virtualbox VM using vagrant

To do this you will need to add a tanglu box first, e.g.:
http://yofel.net/tanglu/vagrant/tanglu-2.0-amd64.box

then run
 ```
 vagrant up
 ```
