-- SPOOL skyrimdb.out
-- SET ECHO ON
-- SET LINESIZE 1000

CREATE TABLE WeaponType (
  wName      CHAR(20),
  speed      INTEGER  NOT NULL,
  stagger    INTEGER  NOT NULL,
  stamina    INTEGER  NOT NULL,
  damageType CHAR(20) NOT NULL,
  wield      CHAR(20) NOT NULL,
  --SKY_WT1: Names of weapons like 'sword' are unique
  CONSTRAINT SKY_WT1 PRIMARY KEY (wName)
);
--
--
CREATE TABLE Locations (
  locationID INTEGER,
  weather    CHAR(20) NOT NULL,
  locType    CHAR(20) NOT NULL,
  refID      INTEGER  NOT NULL,
  locatedIn  INTEGER,
  -- SKY_l2: each location ID must be unique
  CONSTRAINT SKY_l1 PRIMARY KEY (locationID),
  --   SKY_l2: if a location is located somewhere, it must be located in a real location.
  CONSTRAINT SKY_l2 FOREIGN KEY (locatedIn) REFERENCES Locations (locationID) DEFERRABLE INITIALLY DEFERRED
);

--
--
CREATE TABLE Character (
  refID      INTEGER,
  essential  CHAR     NOT NULL,
  name       CHAR(20) NOT NULL,
  gender     CHAR     NOT NULL,
  race       CHAR(20) NOT NULL,
  charClass  CHAR(20) NOT NULL, --changed 'class' to 'charClass'
  charLevel  INTEGER  NOT NULL, -- changed 'level' to 'charLevel'
  locationID INTEGER,
  --   SKY_c1: All characters have a unique refID.
  CONSTRAINT SKY_c1 PRIMARY KEY (refID),
  --   SKY_c2: The character gender has to be either "M" for male or "F" for female.
  CONSTRAINT SKY_c2 CHECK (gender IN ('M', 'F')),
  --   SKY_c3: The character charClass has to be 'player', 'merchant', 'bandit', 'mage', 'fighter', or 'civilian'.
  CONSTRAINT SKY_c3 CHECK (charClass IN ('player', 'merchant', 'bandit', 'mage', 'fighter', 'civilian')),
  --   SKY_c4: The character level has to be greater than 0, but less than 101.
  CONSTRAINT SKY_c4 CHECK (NOT (charLevel < 1 AND charLevel > 100)),
  --   SKY_c5: The character race has to be 'Altmer', 'Argonian', 'Bosmer', 'Breton', 'Dunmer', 'Imperial', 'Khajiit', 'Nord', 'Orsimer', or 'Redguard'.
  CONSTRAINT SKY_c5 CHECK (race IN
                           ('Altmer', 'Argonian', 'Bosmer', 'Breton', 'Dunmer', 'Imperial', 'Khajiit', 'Nord', 'Orsimer', 'Redguard')),
  -- SKY_c6: The location of the character must be valid
  CONSTRAINT SKY_c6 FOREIGN KEY (locationID) REFERENCES Locations (locationID) DEFERRABLE INITIALLY DEFERRED
);
--
--
CREATE TABLE Weapon (
  wID        INTEGER,
  attack     INTEGER  NOT NULL,
  wepValue   INTEGER  NOT NULL, -- changed 'value' to 'wepValue'
  weight     INTEGER  NOT NULL,
  locationID INTEGER,
  refID      INTEGER,
  material   CHAR(20) NOT NULL,
  wName      CHAR(20) NOT NULL,
  --SKY_w1: Each weapon ID must be unique
  CONSTRAINT SKY_w1 PRIMARY KEY (wID),
  --SKY_w2: The potential locationID of the weapon must be a valid location
  CONSTRAINT SKY_w2 FOREIGN KEY (locationID) REFERENCES Locations (locationID) DEFERRABLE INITIALLY DEFERRED,
  --SKY_w3: The potential character who owns the weapon must be a valid character
  CONSTRAINT SKY_w3 FOREIGN KEY (refID) REFERENCES Character (refID) DEFERRABLE INITIALLY DEFERRED,
  --SKY_w4: The name of what type of weapon it is must be a valid WeaponType
  CONSTRAINT SKY_w4 FOREIGN KEY (wName) REFERENCES WeaponType (wName) DEFERRABLE INITIALLY DEFERRED,
  --SKY_w5: This constraint makes sure that a weapon is either in an inventory or in a location.
  CONSTRAINT SKY_w5 CHECK (locationID IS NOT NULL OR refID IS NOT NULL)
);
--
--
CREATE TABLE Enchantment (
  wID             INTEGER,
  enchantmentName CHAR(40),
  soulCharge      INTEGER  NOT NULL,
  effect          CHAR(40) NOT NULL,
  enchantValue    INTEGER  NOT NULL, -- changed 'value' to 'enchantValue'
  --SKY_e1: an enchantment must be on a valid weapon ID with a valid enchantment name
  CONSTRAINT SKY_e1 PRIMARY KEY (wID, enchantmentName),
  --SKY_e2: the weapon the enchantment is on must exist
  CONSTRAINT SKY_e2 FOREIGN KEY (wID) REFERENCES Weapon (wID) DEFERRABLE INITIALLY DEFERRED
);


--
--
CREATE TABLE Quests (
  questName CHAR(40),
  -- SKY_q1: The names of quests must be unique
  CONSTRAINT SKY_q1 PRIMARY KEY (questName)
);

--
--

CREATE TABLE Monster (
  id           INTEGER,
  health       INTEGER  NOT NULL,
  monsterLevel INTEGER  NOT NULL, -- changed 'level' to 'monsterLevel'
  loot         INTEGER,
  locationID   INTEGER  NOT NULL,
  monsterType  CHAR(20) NOT NULL, -- changed 'type' to 'monsterType'
  bounty       INTEGER,
  soulSize     INTEGER  NOT NULL,
  refID        INTEGER,
  duration     INTEGER,
  timeSummoned INTEGER,
  --   SKY_m1: This constraint makes sure the level is between 1 and 100
  CONSTRAINT SKY_m1 CHECK (NOT (monsterLevel < 1 OR monsterLevel > 100)),
  /*
  SKY_m2: This constraint checks to make sure that if the monster isn't summoned that it has a refID
  refID comes from it being summoned, so commenting this out for now
  ALSO - there is something wrong with the relational operator
  */
  --   CONSTRAINT SKY_m2 CHECK ((refID OR timeSummoned) AND (NOT (refID AND timeSummoned))),
  --   SKY_m3: monster health must be greater than or equal to 100
  CONSTRAINT SKY_m3 CHECK (NOT (health < 100)),
  --   SKY_m4: checks to make sure that the total loot dropped by a monster is within a specific range dependant upon their level.
  CONSTRAINT SKY_m4 CHECK (NOT (loot > (monsterLevel * 100))),
  --   SKY_m5: the monster's id must be unique
  CONSTRAINT SKY_m5 PRIMARY KEY (id),
  --   SKY_m6: the location that the monster is at must exist
  CONSTRAINT SKY_m6 FOREIGN KEY (locationID) REFERENCES Locations (locationID) DEFERRABLE INITIALLY DEFERRED,
  --   SKY_m7: potential the summoner's refID must exist
  CONSTRAINT SKY_m7 FOREIGN KEY (refID) REFERENCES Character (refID) DEFERRABLE INITIALLY DEFERRED
);
--
--
CREATE TABLE DamageMulti (
  id         INTEGER,
  damageMult INTEGER,
  -- SKY_dm1: the id and the damageMult must be a unique pair
  CONSTRAINT SKY_dm1 PRIMARY KEY (id, damageMult),
  -- SKY_dm2: the id of the monster must exist
  CONSTRAINT SKY_dm2 FOREIGN KEY (id) REFERENCES Monster (id) DEFERRABLE INITIALLY DEFERRED
);
--
--

CREATE TABLE CharacterSkills (
  refID  INTEGER,
  skills CHAR(20) NOT NULL,
  --SKY_csk1: The refID and skills pair must be unique
  CONSTRAINT SKY_csk1 PRIMARY KEY (refID, skills),
  --SKY_csk2: The refID must be a valid refID
  CONSTRAINT SKY_csk2 FOREIGN KEY (refID) REFERENCES Character (refID) DEFERRABLE INITIALLY DEFERRED,
  --SKY_csk3: The character can only have these skills: 'Armor','Stealing', 'Crafting', or 'Swordsmanship'.
  CONSTRAINT SKY_csk3 CHECK (skills IN ('Armor', 'Stealing', 'Crafting', 'Swordsmanship'))
);
--
--
CREATE TABLE CharacterMagic (
  refID INTEGER,
  magic CHAR(20) NOT NULL,
  --SKY_cmg1: The refID and magic pair must be unique
  CONSTRAINT SKY_cmg1 PRIMARY KEY (refID, magic),
  --SKY_cmg2: The refID must be a valid refID
  CONSTRAINT SKY_cmg2 FOREIGN KEY (refID) REFERENCES Character (refID) DEFERRABLE INITIALLY DEFERRED,
  --   SKY_cmg3 checks to make sure the character's magic skill is one of the following strings in the list.
  CONSTRAINT SKY_cmg3 CHECK (magic IN ('Alteration', 'Conjuration', 'Destruction', 'Illusion', 'Restoration'))
);
--
--
CREATE TABLE CharacterStats (
  refID INTEGER,
  stats INTEGER NOT NULL,
  --SKY_cstat1: The refID and stats pair must be unique
  CONSTRAINT SKY_cstat1 PRIMARY KEY (refID, stats),
  --SKY_cstat2: The refID must be a valid refID
  CONSTRAINT SKY_cstat2 FOREIGN KEY (refID) REFERENCES Character (refID) DEFERRABLE INITIALLY DEFERRED
);
--
--
CREATE TABLE CharacterFaction (
  refID   INTEGER,
  faction CHAR(20) NOT NULL,
  --SKY_cf1: The refID and magit=c pair must be unique
  CONSTRAINT SKY_cf1 PRIMARY KEY (refID, faction),
  --SKY_cf2: The refID must be a valid refID
  CONSTRAINT SKY_cf2 FOREIGN KEY (refID) REFERENCES Character (refID) DEFERRABLE INITIALLY DEFERRED,
  --   SKY_cf3: The character can only be apart of the following factions:
  CONSTRAINT SKY_cf3 CHECK (faction IN ('Bards College', 'Greybeards'))
);
--
--
CREATE TABLE QuestStarted (
  questName   CHAR(20),
  refID       INTEGER,
  timeStarted INTEGER NOT NULL,
  --   SKY_qs1: The questname and the refID must be a unique pair
  CONSTRAINT SKY_qs1 PRIMARY KEY (questName, refID),
  --   SKY_qs2: The questName must be a valid name for a Quest
  CONSTRAINT SKY_qs2 FOREIGN KEY (questName) REFERENCES Quests (questName) DEFERRABLE INITIALLY DEFERRED,
  --   SKY_qs3: The refID must be a valid Character
  CONSTRAINT SKY_qs3 FOREIGN KEY (refID) REFERENCES Character (refID) DEFERRABLE INITIALLY DEFERRED
);

CREATE TABLE QuestLocated (
  locationID INTEGER,
  questName  CHAR(40),
  --   SKY_ql1: The questname and location must be a unique pair
  CONSTRAINT SKY_ql1 PRIMARY KEY (locationID, questName),
  --   SKY_ql2: The locationID must be a valid location
  CONSTRAINT SKY_ql2 FOREIGN KEY (locationID) REFERENCES Locations (locationID) DEFERRABLE INITIALLY DEFERRED,
  --   SKY_ql3: The quest name must be a valid quest
  CONSTRAINT SKY_ql3 FOREIGN KEY (questName) REFERENCES Quests (questName) DEFERRABLE INITIALLY DEFERRED
);

-- -- foreign keys
-- ALTER TABLE Weapon
--   ADD FOREIGN KEY (refID) REFERENCES Character (refID)
-- DEFERRABLE INITIALLY DEFERRED;
--
-- ALTER TABLE Weapon
--   ADD FOREIGN KEY (wName) REFERENCES WeaponType (wName)
-- DEFERRABLE INITIALLY DEFERRED;
--
-- ALTER TABLE Enchantment
--   ADD FOREIGN KEY (wID) REFERENCES Weapon (wID)
-- DEFERRABLE INITIALLY DEFERRED;
--
-- ALTER TABLE Character
--   ADD FOREIGN KEY (locationID) REFERENCES Locations (locationID)
-- DEFERRABLE INITIALLY DEFERRED;
--
-- ALTER TABLE Monster
--   ADD FOREIGN KEY (refID) REFERENCES Character (refID)
-- DEFERRABLE INITIALLY DEFERRED;
--
-- ALTER TABLE Locations
--   ADD FOREIGN KEY (locatedIn) REFERENCES Locations (locationID)
-- DEFERRABLE INITIALLY DEFERRED;
--
-- ALTER TABLE Locations
--   ADD FOREIGN KEY (refID) REFERENCES Character (refID)
-- DEFERRABLE INITIALLY DEFERRED;
--
-- ALTER TABLE DamageMulti
--   ADD FOREIGN KEY (id) REFERENCES Monster (id)
-- DEFERRABLE INITIALLY DEFERRED;
--
-- ALTER TABLE CharacterSkills
--   ADD FOREIGN KEY (refID) REFERENCES Character (refID)
-- DEFERRABLE INITIALLY DEFERRED;
--
-- ALTER TABLE CharacterMagic
--   ADD FOREIGN KEY (refID) REFERENCES Character (refID)
-- DEFERRABLE INITIALLY DEFERRED;
--
--
-- ALTER TABLE CharacterStats
--   ADD FOREIGN KEY (refID) REFERENCES Character (refID)
-- DEFERRABLE INITIALLY DEFERRED;
--
-- ALTER TABLE CharacterFaction
--   ADD FOREIGN KEY (refID) REFERENCES Character (refID)
-- DEFERRABLE INITIALLY DEFERRED;
--
-- ALTER TABLE QuestStarted
--   ADD FOREIGN KEY (refID) REFERENCES Character (refID);
--
-- ALTER TABLE QuestLocated
--   ADD FOREIGN KEY (locationID) REFERENCES Locations (locationID)
-- DEFERRABLE INITIALLY DEFERRED;

-- end of foreign keys


--
--------------------------------------------------------------------------------------------------------------
--Populate the database
--------------------------------------------------------------------------------------------------------------
--
-- ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD';
--
--
-- COMMENTING ALL OF THESE OUT FOR NOW: ALL TYPES MUST BE STRINGS
-- Insert into WeaponType values ('Dagger', 10, 1, 2, slashing, one-handed);
-- Insert into WeaponType values ('Mace', 5, 2, 3, bludgeoning, one-handed);
-- Insert into WeaponType values ('Sword', 8, 3, 4, piercing, one-handed);
-- Insert into WeaponType values ('War Axe', 7, 5, 5, slashing, one-handed);
-- Insert into WeaponType values ('BattleAxe', 4, 7, 7, slashing, two-handed);
-- Insert into WeaponType values ('Greatsword', 3, 8, 7, piercing, two-handed);
-- Insert into WeaponType values ('Warhammer', 2, 10, 9, bludgeoning, two-handed);
-- Insert into WeaponType values ('Bow', 1, 1, 5, piercing, two-handed);
-- Insert into WeaponType values ('Crossbow', 5, 1, 2, piercing, two-handed);
--
-- Insert into Weapons values (1, 4, 10, 2, iron, dagger);
-- Insert into Weapons values (2, 5, 18, 3, steel, dagger);
-- Insert into Weapons values (3, 6, 30, 3, orchalcum, dagger);
-- Insert into Weapons values (4, 6, 95, 4, moonstone, dagger);
-- Insert into Weapons values (5, 9, 165, 5, glass, dagger);
-- Insert into Weapons values (6, 10, 290, 5, ebony, dagger);
-- Insert into Weapons values (7, 11, 500, 6, daedra heart, dagger);
-- Insert into Weapons values (8, 12, 600, 7, dragonbone, dagger);
--
--
-- Insert into Weapons values (9, 9, 35, 13, iron, mace);
-- Insert into Weapons values (10, 10, 65, 14, steel, mace);
-- Insert into Weapons values (11, 11, 105, 15, orchalcum, mace);
-- Insert into Weapons values (12, 14, 330, 17, moonstone, mace);
-- Insert into Weapons values (13, 14, 575, 18, glass, mace);
-- Insert into Weapons values (14, 16, 1000, 19, ebony, mace);
-- Insert into Weapons values (15, 16, 1750, 20, daedra heart, mace);
-- Insert into Weapons values (16, 17, 2000, 24, dragonbone, mace);
-- SET FEEDBACK OFF
--------------------------------------------
INSERT INTO WeaponType VALUES ('axe', 3, 4, 10, 'slashing', 'two-handed');
INSERT INTO WeaponType VALUES ('bow', 3, 2, 4, 'piercing', 'two-handed');
INSERT INTO WeaponType VALUES ('mace', 3, 3, 8, 'bludgeoning', 'one-handed');
INSERT INTO WeaponType VALUES ('spork', 10, 0, 1, 'slashing', 'one-handed');
INSERT INTO WeaponType VALUES ('dagger', 8, 0, 2, 'slashing', 'one-handed');
INSERT INTO WeaponType VALUES ('sword', 5, 2, 5, 'slashing', 'one-handed');
--------------------------------------------
INSERT INTO Weapon VALUES (100, 10, 100, 5, NULL, 1, 'steel', 'dagger');
INSERT INTO Weapon VALUES (200, 8, 80, 2, 5, NULL, 'wood', 'bow');
INSERT INTO Weapon VALUES (300, 11, 190, 10, NULL, 3, 'iron', 'mace');
INSERT INTO Weapon VALUES (400, 2, 20, 1, NULL, 4, 'iron', 'spork');
INSERT INTO Weapon VALUES (500, 15, 500, 15, 6, NULL, 'glass', 'axe');
INSERT INTO Weapon VALUES (600, 20, 750, 8, NULL, 2, 'steel', 'sword');
INSERT INTO Weapon VALUES (700, 9, 160, 4, NULL, 5, 'steel', 'bow');
--------------------------------------------
INSERT INTO Quests VALUES ('A New Order');
INSERT INTO Quests VALUES ('No Stone Unturned');
INSERT INTO Quests VALUES ('Monty Python and the Holy Grail');
INSERT INTO Quests VALUES ('Under New Management');
INSERT INTO Quests VALUES ('Whodunit');
INSERT INTO Quests VALUES ('Taking Care of Business');
INSERT INTO Quests VALUES ('The Cure for Madness');
--------------------------------------------
INSERT INTO Character VALUES (1, 'n', 'DaggerMan', 'M', 'Khajiit', 'bandit', 10, 5);
INSERT INTO Character VALUES (2, 'y', 'Link', 'M', 'Dunmer', 'player', 72, 1);
INSERT INTO Character VALUES (3, 'n', 'MaceMan', 'M', 'Nord', 'fighter', 32, 4);
INSERT INTO Character VALUES (4, 'n', 'SporkBoy', 'M', 'Altmer', 'civilian', 1, 2);
INSERT INTO Character VALUES (5, 'n', 'Archer', 'M', 'Imperial', 'bandit', 32, 3);
--------------------------------------------
INSERT INTO Enchantment VALUES (100, 'Lunar', 17, 'Came from the Moon', 1000);
INSERT INTO Enchantment VALUES (400, 'Unbending', 100, 'Will never bend', 800);
INSERT INTO Enchantment VALUES (600, 'Master', 80, 'Allows for time travel', 2000);
INSERT INTO Enchantment VALUES (700, 'Shocking', 32, 'Acts like a taser', 250);
--------------------------------------------
-- SET FEEDBACK ON
-- COMMIT;
--------------------------------------------
/*
Queries to print out database. These are NOT the official queries
 */

-- The queries are now in the 'showSkyrim.sql' file

/*
SQL queries go there along with the query number and the features that it demonstrates.
Via the specs for the project:

1. A comment line stating the query number and the feature(s) it demonstrates
(e.g. – Q25 – correlated subquery).
2. A comment line stating the query in English.
3. The SQL code for the query.
 */
/*
REMOVE THIS BEFORE SUBMITTING - FOR REFERENCE ONLY

At a minimum, your queries must demonstrate the features listed below. You may of course demonstrate
more than one feature in any one query and thus end up having to write fewer, but more interesting,
queries.
1. A join involving at least four relations.
2. A self-join.
3. UNION, INTERSECT, and/or MINUS.
4. SUM, AVG, MAX, and/or MIN.
5. GROUP BY, HAVING, and ORDER BY, all appearing in the same query
6. A correlated subquery.
7. A non-correlated subquery.
8. A relational DIVISION query.
9. An outer join query.
10. A RANK query.
11. A Top-N query.
 */
/*
Testing of the four ICs that are listed in the final documentation
Via the specs for the project:

Include the following items for every IC that you test (Important: see the next section titled
“Submit a final report” regarding which ICs to test).
A comment line stating: Testing: < IC name>
A SQL INSERT, DELETE, or UPDATE that will test the IC.
 */
-- SET ECHO OFF
-- SPOOL OFF




