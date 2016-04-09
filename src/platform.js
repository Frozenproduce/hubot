import AWS from 'aws-sdk';

const apps = [
  'basket-service',
  'discounts-service',
  'events-service',
  'graph',
  'payment-gateways',
  'products-service',
  'profiles-directory',
  'profiles-renderer',
  'reservations',
  'router',
  'shrinkray',
  'streams-service',
  'themes-service',
  'viewers-service',
];

function getStatusForEnv(conn, name) {
  const params = { AttributeNames: ['All'], EnvironmentName: `${name}-blue` };
  return conn.describeEnvironmentHealth(params).promise()
}

function writeResponse(item) {
  return `App: ${item.EnvironmentName} - ${item.HealthStatus} - P95:${item.ApplicationMetrics.Latency.P95}s`;
}

function transformResults(payloads) {
  return payloads.map(writeResponse);
}

export default robot => {
  robot.respond(/platform status/, res => {
    const conn = new AWS.ElasticBeanstalk();
    Promise.all(apps.map(app => getStatusForEnv(conn, app)))
      .then(transformResults)
      .then(statuses => res.send(statuses.join('\n')))
      .catch(err => res.send(JSON.stringify(err, null, 4)));
  });
};
