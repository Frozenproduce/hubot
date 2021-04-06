const remove = (array, elementToRemove) => array.filter((el) => el !== elementToRemove);
const pickRandom = (array) => array[Math.floor(array.length * Math.random())];

const generator = (segments, length, separator = "") => {
  const generate = (availableSegments = segments, currentLength = length) => {
    const segment = pickRandom(availableSegments);
    return currentLength > 1
      ? segment + separator + generate(remove(availableSegments, segment), currentLength - 1)
      : segment;
  };
  return generate;
};

const suggestionTemplates = [
  "How about _?",
  "Why not _?",
  "Maybe try _.",
  "Go for _.",
  "_ is best, imo",
  "I think _ works.",
  "_. Definitely.",
  "If you don't go with _, I don't want to be friends any more.",
  "_, obviously",
  "I'd go with _.",
  "_ all the way",
];

const suggest = (generate) => pickRandom(suggestionTemplates).replace("_", generate());

const nameSegments = [
  "Product",
  "Price",
  "Event",
  "Glue",
  "Reservation",
  "Basket",
  "Mutation",
  "Component",
  "Module",
  "Class",
  "Burrito",
  "Sandwich",
  "Factory",
  "Builder",
  "Manager",
  "Abstract",
  "Predicate",
  "Model",
  "PG",
  "Container",
  "Decorator",
  "Dispatcher",
  "Getter",
  "Setter",
  "Response",
  "Request",
  "Async",
  "Promise",
  "Mapper",
  "Value",
  "Key",
  "Function",
  "StirFry",
  "Panic",
  "OnFire",
  "Explosion",
  "Drama",
  "Hope",
  "Probably",
  "Template",
  "Proxy",
  "Interpreter",
  "Format",
  "Collection",
  "Exception",
  "Stank",
  "Noodler",
  "Salad",
  "Sad",
  "Emoji",
  "Immutable",
  "Desperately",
  "Vague",
  "Programmer",
];

const nameGenerator = generator(nameSegments, 3);

const lunchBases = [
  "sandwich",
  "burrito",
  "pasta",
  "pizza",
  "chocolate",
  "curry",
  "stir fry",
  "sushi",
  "burger",
  "noodles",
  "meat",
  "surprise",
  "wrap",
  "pasty",
  "cake",
  "dissapointment",
  "salad",
];

const lunchFlavours = lunchBases.concat([
  "a ham",
  "an Internet",
  "a theoretical",
  "some digital",
  "a vegetable",
  "a dissapointing",
  "floor",
  "some suspicious",
  "an over-priced",
  "a dusty",
  "some artisanal",
  "spicy",
]);

const lunchGenerator = () => `${pickRandom(lunchFlavours)} ${pickRandom(lunchBases)}`;

export default (robot) => {
  robot.hear(/\?name/, (res) => res.send("I killed slackbot and ate their name generator 😇"));

  // chuck, what shall I name this function?
  // Chuck, name me
  // etc.
  robot.respond(/.*name.*/i, (res) => res.send(suggest(nameGenerator)));

  // chuck whats for lunch?
  robot.respond(/.*lunch.*/i, (res) => res.send(suggest(lunchGenerator)));
};
