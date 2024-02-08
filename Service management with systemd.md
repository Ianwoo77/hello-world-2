# Service management with systemd

Services, also frequently called daemons, are long-running processes that run in the background. These can be things like dbs and web servers-- but also regular system services like network manager, desktop environment, and so on. These long-running background serivces are typically started and controlled via an `init`system such as `systemd`.

`init`refers to the first process your os kernel starts, and its job of this process to take care of starting any other processes. And `systemd`services are controlled using a command line utility called `systemctl`-- used for starting and stopping services.

- The command U will use to interact with `systemd`-- `systemctl`
- A slight deeper dive into what an init system does, and how `systemd`speifically fills this role
- Managing services with `systemctl`
- A few tips for working with container environment

### Basics

Linux services are background processes that run on a Linux system to perform specific tasks. They are just similar to Windows services or daemons on macOS. Most non-containerized Linux environment use `systemd`manage services.

- `systemctl`-- controls services
- `journalctl`-- work with system logs

`systemd`is a system and service manager for linux that provides a std way to manage services. The overwhelming majority of Linux distributions now use `systemd`-- services can be started, stopped, restarted, enabled, and disabled. To manage with `systemd`-- using the basic commands like:

- systemctl `start` <service>
- `stop <service>`
- `restart <service>`
- `systemctl status <service>`-- displays the curerent status of a service.

`init`-- the first process that is started when the system boots up -- Can find it at PID `1`-- init is responsible for managing the boot process and starting all other processes and services that have been configured to run on the system. It also re-parents orphaned processes, and keeps them as its own children, to ensure they still behave normally.

### Processes and Services

Can think of a linux service as some packaging around a piece of software that makes it easier to manage as a running process. A service adds convenient features to how program is handled by the system. FORE -- define dependenices between different processes, control startup order, add environment variables for the process to start with.

systemctl commands -- `systemctl`is the tool you will use to manage the services that have been defined on your system. These examples will use the `foobar`service.. justlike:

Checking the status of a service -- `systemctl`status `<service>`checks the status of the service, get an assortment of data that is useful for all kinds of troubleshooting tasks.

```sh
systemctl status nginx
```

- Docs -- the main page where you can find relevant documentation if it’s been installed.
- Main PID and child processes -- the processId of the main process associated with the service.
- Resource usage -- RAM and CPU time
- CGroup -- Details about the control group to which this process belonegs.

Starting a service

```sh
systemctl start foobar
systemctl stop foobar
systemctl restart foobar # equivalent to start then stop
```

Be careful with this -- if a service’s configuration file has changed on disk since it was started, and that config file has a bug that prevenets the program from successuflly starting. Fore, many popular programs have built-in configuraiton validation like `nginx -t`

Reolading -- 

```sh
systemctl reload foobar
```

Note that not all services support this subcommand. It’s up to the person creating the sevice configuration to implement. Note that if a service does have a `reload`, it is generally safer then `restart`. Usually, `reload`-- 

- *re-checks* the configuration on disk to ensure that it’s valid
- *re-reads* the configuration into memory without interrupting the running process
- *re-starts* the processes only after **validating** the config and making sure the process will start successfully after being stopped.

### Enable and Disable

`systemctl enable foobar`-- configures `foobar`to start automatically on boot. `enable`and `disable`are about future system startups. They have no effect on the service’s running status at the time you run the command.

Fore, if you want to an `nginx`web server now and ensure that it automatically start on reboot, need to run:

```sh
systemctl start nginx
systemctl enable nginx
```

Cuz of this, enable and disable come with optional flag also starts the service like:

```sh
systemctl enable --now nginx # equivalent to the two commands above
```

## Pandas 101

6. How to get the items of series A not present in Series B

   ```python
   ser1 = pd.Series([1, 2, 3, 4, 5])
   ser2 = pd.Series([4, 5, 6, 7, 8])
   ser1[~ser1.isin(ser2)]
   ```

7. How to get the items not common in both A and B

   ```python
   ser_u = pd.Series(np.union1d(ser1, ser2))
   ser_i = pd.Series(np.intersect1d(ser1, ser2))
   ser_u[~ser_u.isin(ser_i)]
   ```


### Using data within a Context -- 

One benefit of using `context.Context`in a program is the ability to access data stored inside a context. By adding data to a context and passing the context from function to function -- each layer of a program can add additional info about what is happening. the first func may add a username to the context. And the next func may add the file path to the content the user is trying to access.