var dbPass = "root"
var clusterName = "otusCluster"

try {
  print('Setting up InnoDB cluster...\n');
  shell.connect('root@server1:3306', dbPass)
  var cluster = dba.createCluster(clusterName);
  print('Adding instances to the cluster.');
  cluster.addInstance({user: "root", host: "server2", port: 3306, password: dbPass}, {recoveryMethod: "incremental"})
  print('.');
  cluster.addInstance({user: "root", host: "server3", port: 3306, password: dbPass}, {recoveryMethod: "incremental"})
  print('.\nInstances successfully added to the cluster.');
  print('\nInnoDB cluster deployed successfully.\n');
} catch(e) {
  print('\nThe InnoDB cluster could not be created.\n\nError: ' + e.message + '\n');
}
