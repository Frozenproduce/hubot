import AWS from 'aws-sdk';
import { awsConfig } from './awsConfig';

const apps = [
  'basket-service',
  'events-service',
  'graph',
  'payment-gateways',
  'products-service',
  'profiles-directory',
  'reservations',
  'router',
  'shrinkray',
  'streams-service',
  'themes-service',
  'viewers-service',
];

const statuses = {
  Green: ['😀', '🕶', '✨', '👍', '😺', '🎉'],
  Yellow: ['😬', '😰', '😮', '💔'],
  Red: ['🔥', '💀', '🌋', '😱', '👎'],
  Grey: ['👻', '👽', '🤖']
};

function statusIndicator(colour) {
  const indicators = statuses[colour];
  return indicators[Math.floor(Math.random() * indicators.length)];
}

function getStatusForEnv(conn, name) {
  const params = { AttributeNames: ['All'], EnvironmentName: `${name}-blue` };
  return conn.describeEnvironmentHealth(params).promise()
}

function writeResponse(item) {
  const rawRate = item.ApplicationMetrics.RequestCount / item.ApplicationMetrics.Duration;
  const rate = isNaN(rawRate) ? '?' : `${rawRate}/s`;
  const p95 = item.ApplicationMetrics.Latency
    ? `${item.ApplicationMetrics.Latency.P95}s`
    : '?';

  const status = statusIndicator(item.Color);
  return {
    fallback: `${status} ${item.EnvironmentName} - ${item.HealthStatus} - P95: ${p95} - Rate ${rate}`,
    field: {
      title: item.EnvironmentName,
      value: `${status} _*${item.HealthStatus}*_       P95: *${p95}*       Rate: *${rate}*`,
      short: true
    },
  };
}

function transformResults(payloads) {
  return payloads.map(writeResponse);
}

export default robot => {
  robot.respond(/.*platform status(\s+\w+)?.*/i, res => {
    if (robot.auth.hasRole(res.envelope.user, 'developer')) {
      const conn = new AWS.ElasticBeanstalk(awsConfig(res.match[1]));
      Promise.all(apps.map(app => getStatusForEnv(conn, app)))
        .then(transformResults)
        .then(statuses => {
          const fallbacks = statuses.map(({ fallback }) => fallback);

          robot.emit('slack.attachment', {
            message: res,
            content: {
              fallback: `Platform Status Report:\n${fallbacks.join('\n')}`,
              title: 'Platform Status Report',
              fields: statuses.map(({ field }) => field),
              mrkdwn_in: ['fields'],
            },
          });
        })
        .catch(err => res.send(err.stack || JSON.stringify(err, null, 4)));
    } else {
      res.send('Sorry, you lack the right permissions to do that');
    }
  });
};
