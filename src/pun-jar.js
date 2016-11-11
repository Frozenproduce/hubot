export default robot => {
  robot.respond(/.*pun.?jar (.*$)/i, res => {
    const end = res.match[1];
    const [u, ...bits] = end.split('for');
    const reason = bits.join('for').trim();
    const user = u.trim().toLowerCase();

    const puns = (robot.brain.get(`punjar.${user}.count`) || 0) + 1;
    const originalReasons = robot.brain.get(`punjar.${user}.reasons`) || [];
    const reasons = reason
      ? originalReasons.concat([reason])
      : originalReasons;

    robot.brain.set(`punjar.${user}.count`, puns);
    robot.brain.set(`punjar.${user}.reasons`, reasons);

    res.reply(`Urgh, ${user}. They've made ${puns} puns.`);

    if (originalReasons.length && Math.random() < 0.6) {
      res.reply(`Remember\n> ${res.random(originalReasons)}`);
    }
  });
};
