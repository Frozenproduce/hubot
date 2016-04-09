import aws from 'aws-sdk';

export default robot => {
  robot.respond(/deploy version ([a-z0-9]+)/, res => {
    if (robot.auth.hasRole(res.envelope.user, 'deployer')) {
      res.send(`ok - deploying match ${res.match[1]}`);
    } else {
      res.send('denied');
    }
  });
};
