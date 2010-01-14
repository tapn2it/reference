# SQL script to set up the animal table if it doesn't exist

DROP TABLE IF EXISTS animal;
CREATE TABLE animal
(
  name      CHAR(40),
  category  CHAR(40)
);
INSERT INTO animal (name, category)
VALUES
  ('snake', 'reptile'),
  ('frog', 'amphibian'),
  ('tuna', 'fish'),
  ('racoon', 'mammal')
;

SELECT * FROM animal;
