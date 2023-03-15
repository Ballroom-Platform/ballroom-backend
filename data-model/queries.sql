/* -------------------------USERS SERVICE---------------------------- */
CREATE TABLE Users (
    asgardeo_user_id VARCHAR(255) NOT NULL,
    username VARCHAR(255) NOT NULL,
    fullname VARCHAR(255),
    role VARCHAR(255) NOT NULL,
    PRIMARY KEY (asgardeo_user_id),
    UNIQUE (username)
);

ALTER TABLE Users
ADD role VARCHAR(255) NOT NULL;
/* -------------------------USERS SERVICE---------------------------- */


/* -------------------------CONTESTS SERVICE---------------------------- */

CREATE TABLE Contests (
    contest_id VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NOT NULL,
    /* This could be a field that needs to be consistent in relation to Users*/
    moderator VARCHAR(255) NOT NULL,
    PRIMARY KEY (contest_id),
    FOREIGN KEY (moderator) REFERENCES Users(asgardeo_user_id)
    /* add constraint that start_time < end_time */
);

CREATE TABLE Contest_Challenge (
    contest_id VARCHAR(255) NOT NULL,
    /* This could be a field that needs to be consistent in relation to Challenges*/
    challenge_id VARCHAR(255) NOT NULL,
    -- Have to put on delete cascade
    FOREIGN KEY (contest_id) REFERENCES Contests(contest_id) ON DELETE CASCADE,
    FOREIGN KEY (challenge_id) REFERENCES Challenges(challenge_id)
);

CREATE TABLE Contest_Users (
    contest_id VARCHAR(255) NOT NULL,
    /* This could be a field that needs to be consistent in relation to Users*/
    user_id VARCHAR(255) NOT NULL
);
/* -------------------------CONTESTS SERVICE---------------------------- */


/* -------------------------CHALLENGES SERVICE---------------------------- */
CREATE TABLE Challenges (
    challenge_id VARCHAR(255) NOT NULL,
    title VARCHAR(255) NOT NULL,
    description VARCHAR(255) NOT NULL,
    /* testcase BLOB NOT NULL, */
    difficulty ENUM('EASY', 'MEDIUM', 'HARD') NOT NULL,
    testcase BLOB,
    PRIMARY KEY (challenge_id)
);
/* -------------------------CHALLENGES SERVICE---------------------------- */

/* -------------------------UPLOAD SERVICE---------------------------- */

CREATE TABLE Submissions (
    submissionId VARCHAR(255) NOT NULL,
    /* This could be a field that needs to be consistent in relation to Users*/
    userId VARCHAR(255) NOT NULL,
    /* This could be a field that needs to be consistent in relation to Contests*/
    contestId VARCHAR(255) NOT NULL,
    /* This could be a field that needs to be consistent in relation to Challenges*/
    challengeId VARCHAR(255) NOT NULL,
    -- submissionFile BLOB NOT NULL,
    submissionFile BLOB,
    submittedTime TIMESTAMP NOT NULL,
    /* Will be updated by challenge service */
    /* Do we have a separate DB for services? If so do we store the score in the same table or in a separate table so that in the event that we require the system to be divided into many services, we can store that table (the one with the score only) in the score service? */
    score INT,
    fileName VARCHAR(255),
    fileExtension VARCHAR(255),
    PRIMARY KEY (submissionId),
    FOREIGN KEY (userId) REFERENCES Users(asgardeo_user_id),
    FOREIGN KEY (contestId) REFERENCES Contests(contest_id),
    FOREIGN KEY (challengeId) REFERENCES Challenges(challenge_id)
);
/* -------------------------UPLOAD SERVICE---------------------------- */

/* These are some dummy values to be inserted into the database at the time of creation */
INSERT INTO Users VALUES ('asg_usr_01', 'haathim', 'Haathim Munas', 'NORMAL');
INSERT INTO Users VALUES ('asg_usr_02', 'ravin', 'Ravin Perera', 'NORMAL');
INSERT INTO Users VALUES ('asg_usr_03', 'john', 'John Doe', 'NORMAL');

INSERT INTO Contests (contest_id, name, start_time, end_time, moderator) VALUES ('contest_001','Contest One',CURRENT_TIMESTAMP(),CURRENT_TIMESTAMP(), 'asg_usr_01');
INSERT INTO Contests (contest_id, name, start_time, end_time, moderator) VALUES ('contest_002','Contest Two',CURRENT_TIMESTAMP(),CURRENT_TIMESTAMP(), 'asg_usr_02');
INSERT INTO Contests (contest_id, name, start_time, end_time, moderator) VALUES ('contest_003','Contest Three',CURRENT_TIMESTAMP(),CURRENT_TIMESTAMP(), 'asg_usr_03');
INSERT INTO Contests (contest_id, name, start_time, end_time, moderator) VALUES ('contest_004', "Contest Thousand", '2022-01-01 00:00:01', '2024-01-01 00:00:01', "asg_usr_001");
INSERT INTO Contests (contest_id, name, start_time, end_time, moderator) VALUES ('contest_004', "Contest Thousand", '2024-01-01 00:00:01', '2025-01-01 00:00:01', "asg_usr_001");

-- INSERT INTO Challenges (title, description, testcase)('Challenge 03', 'Challenge 03 Description....', FILE_READ('file.dat'));
INSERT INTO Challenges (challenge_id, title, description, difficulty, testcase) VALUES ('challenge_001','Challenge 03', 'Challenge 03 Description....', 'EASY',x'89504E47');
INSERT INTO Challenges (challenge_id, title, description, difficulty, testcase) VALUES ('challenge_002','Challenge 04', 'Challenge 04 Description....', 'HARD',x'89504E47');
INSERT INTO Challenges (challenge_id, title, description, difficulty, testcase) VALUES ('challenge_003','Challenge 05', 'Challenge 05 Description....', 'MEDIUM',x'89504E47');
INSERT INTO Challenges (challenge_id, title, description, difficulty, testcase) VALUES ('challenge_004','Challenge 06', 'Challenge 06 Description....', 'MEDIUM',x'89504E47');
INSERT INTO Challenges (challenge_id, title, description, difficulty, testcase) VALUES ('challenge_005','Challenge 06', 'Challenge 07 Description....', 'MEDIUM',x'89504E47');
INSERT INTO Challenges (challenge_id, title, description, difficulty, testcase) VALUES ('challenge_006','Challenge 06', 'Challenge 06 Description....', 'EASY',x'89504E47');
INSERT INTO Challenges (challenge_id, title, description, difficulty, testcase) VALUES ('challenge_007','Challenge 06', 'Challenge 07 Description....', 'HARD',x'89504E47');

SELECT * FROM Contest WHERE CURRENT_TIMESTAMP() BETWEEN start_time AND end_time;

INSERT INTO Contest_Challenge (contest_id, challenge_id) VALUES ('contest_001', 'challenge_001');
INSERT INTO Contest_Challenge (contest_id, challenge_id) VALUES ('contest_001', 'challenge_002');
INSERT INTO Contest_Challenge (contest_id, challenge_id) VALUES ('contest_001', 'challenge_003');

INSERT INTO Submissions (submissionId, userId, contestId, challengeId, submittedTime) VALUES ('sub001', 'asg_usr_001','contest_001' , 'challenge-01edb775-6280-185e-8a5d-5858d25422aa', CURRENT_TIMESTAMP());