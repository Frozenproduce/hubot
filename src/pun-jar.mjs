export default (robot) => {
  robot.respond(/.*pun.?jar (.*$)/i, (res) => {
    const end = res.match[1];
    const [u, ...bits] = end.split("for");
    const reason = bits.join("for").trim();
    const user = u.trim().toLowerCase();

    const puns = (robot.brain.get(`punjar.${user}.count`) || 0) + 1;
    const originalReasons = robot.brain.get(`punjar.${user}.reasons`) || [];
    const reasons = reason ? originalReasons.concat([reason]) : originalReasons;

    robot.brain.set(`punjar.${user}.count`, puns);
    robot.brain.set(`punjar.${user}.reasons`, reasons);

    res.reply(`Urgh, ${user}. They've made ${puns} puns.`);

    if (originalReasons.length && Math.random() < 0.6) {
      res.reply(`Remember\n> ${res.random(originalReasons)}`);
    }
  });

  robot.respond(/puns (.*$)/i, (res) => {
    const user = res.match[1].trim().toLowerCase();
    const puns = robot.brain.get(`punjar.${user}.count`) || 0;
    const reasons = robot.brain.get(`punjar.${user}.reasons`) || [];

    const reasonsMsg = reasons.map((r) => `- ${r}`).join("\n");

    const baseMsg = `${user} has made ${puns} puns so far.`;

    if (reasonsMsg) {
      res.reply(`${baseMsg} Some of the worst:\n\n${reasonsMsg}`);
    } else if (puns === 0) {
      res.reply(baseMsg);
    } else {
      res.reply(`${baseMsg} I can't remember any specifics though.`);
    }
  });
};
