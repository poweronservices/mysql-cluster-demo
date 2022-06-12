# Database setup

- [ ] Check out this repo
- [ ] Review all files in this repo:
  - `docker-compose.yml` defines 3 identical (except for `server_id`) MySQL 8 Docker containers
  - Note the root password in `docker-compose.yml` - you'll be using it below!
  - `Dockerfile` installs MySQL 8 and MySQL Shell
  - `cluster.cnf` sets some MySQL configuration that is required for clustering
  - `classicmodels.sql` is a sample database copied from _mysqltutorial.org_
- [ ] Run `docker-compose up --build`
  - This will create 3 Docker containers and create the `classicmodels` database on each
  - When this is finished, you should see 3 containers running and `ready for connections` (`db1_1`, `db2_1`, and `db3_1`)


# Cluster setup

- [ ] In a new terminal, start MySQL Shell on any container: `docker-compose exec db1 mysqlsh`
  - You should be in `JS` mode, if not then run `\js` to switch to JS mode
- [ ] Configure all 3 instances with a new user account to manage clustering (do NOT set the new account password to be the same as the root password):
  - `dba.configureInstance('root@db1', { clusterAdmin: 'cluster-admin' })`
  - `dba.configureInstance('root@db2', { clusterAdmin: 'cluster-admin' })`
  - `dba.configureInstance('root@db3', { clusterAdmin: 'cluster-admin' })`
- [ ] Disconnect from the local instance as `root` and reconnect as the new account:
  - `\disconnect`
  - `\connect cluster-admin@localhost`
- [ ] Create the cluster with the current instance: `cluster = dba.createCluster('mycluster')`
- [ ] Verify that the cluster is created with 1 instance: `cluster.status()`
- [ ] Add the other instances to the cluster:
  - Choose `Clone` when prompted
  - When you see `Waiting for server restart...`, run this in a new terminal: `docker-compose up -d db#` (replace `db#` with the container being restarted)
  - `cluster.addInstance('cluster-admin@db1')`
  - `cluster.addInstance('cluster-admin@db2')`
  - `cluster.addInstance('cluster-admin@db3')`
- [ ] Verify that `cluster.status()` shows 3 instances (1 `PRIMARY` and 2 `SECONDARY`)
- [ ] Switch the cluster to multi-primary mode: `cluster.switchToMultiPrimaryMode()`
- [ ] Verify that `cluster.status()` shows 3 `PRIMARY` instances now


# Data testing

- [ ] Open 3 new terminals for the 3 instances:
  - `docker-compose exec db1 mysql -D classicmodels -p` (enter root password)
  - `docker-compose exec db2 mysql -D classicmodels -p` (enter root password)
  - `docker-compose exec db3 mysql -D classicmodels -p` (enter root password)
- [ ] In `db1`, update a couple of existing records
- [ ] In `db2` and `db3`, select those records and verify that the changes are reflected
- [ ] In `db2`, deleted a couple of existing records
- [ ] In `db1` and `db3`, select those records and verify that they no longer exist
- [ ] In `db3`, create a couple of new records
- [ ] In `db1` and `db2`, select the new records and verify that they exist
- [ ] Shut down one of the existing containers: `docker kill cluster_db3_1`
- [ ] In MySQL Shell, verify that the cluster shows 2 active instances and 1 missing instance: `cluster.status()`
- [ ] In each of the remaining containers, create, update, and delete some records
- [ ] Verify from the other remaining container that these changes are reflected
- [ ] Restart the missing instance: `docker-compose up -d db3`
- [ ] In MySQL Shell, verify that the cluster shows all 3 active instances again (it might take a few seconds): `cluster.rescan()` and then `cluster.status()`
- [ ] Verify that the restored instance reflects all changes made while it was down
