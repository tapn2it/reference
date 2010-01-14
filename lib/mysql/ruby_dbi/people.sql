# people.sql - structure of people table

DROP TABLE IF EXISTS people;
#@ _CREATE_TABLE_
CREATE TABLE people
(
  id     INT UNSIGNED NOT NULL AUTO_INCREMENT, # ID number
  name   CHAR(20) NOT NULL,                    # name
  height FLOAT,                                # height in inches
  PRIMARY KEY (id)
);
#@ _CREATE_TABLE_

INSERT INTO people (name,height)
  VALUES
    ('Wanda',62.5),
    ('Robert',75),
    ('Phillip',71.5),
    ('Sarah',68)
;
