/* -------------------------USERS SERVICE---------------------------- */
CREATE TABLE user (
    user_id VARCHAR(255) NOT NULL,
    username VARCHAR(255) NOT NULL,
    fullname VARCHAR(255) NOT NULL,
    role VARCHAR(255) NOT NULL,
    PRIMARY KEY (user_id),
    UNIQUE (username)
);

/* -------------------------CONTESTS SERVICE---------------------------- */

CREATE TABLE contest (
    contest_id VARCHAR(255) NOT NULL,
    title VARCHAR(255) NOT NULL,
    description VARCHAR(500),
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NOT NULL,
    moderator VARCHAR(255) NOT NULL,
    image_url VARCHAR(255),
    PRIMARY KEY (contest_id),
    FOREIGN KEY (moderator) REFERENCES user(user_id)
    CHECK (start_time < end_time)
);

CREATE TABLE contest_challenge (
    contest_id VARCHAR(255) NOT NULL,
    challenge_id VARCHAR(255) NOT NULL,
    FOREIGN KEY (contest_id) REFERENCES contest(contest_id) ON DELETE CASCADE,
    FOREIGN KEY (challenge_id) REFERENCES challenge(challenge_id),
    PRIMARY KEY (contest_id, challenge_id)
);

CREATE TABLE contest_user (
    contest_id VARCHAR(255) NOT NULL,
    user_id VARCHAR(255) NOT NULL,
    FOREIGN KEY (contest_id) REFERENCES contest(contest_id),
    FOREIGN KEY (user_id) REFERENCES user(user_id),
    PRIMARY KEY (contest_id, user_id)
);
/* -------------------------CONTESTS SERVICE---------------------------- */


/* -------------------------CHALLENGES SERVICE---------------------------- */
CREATE TABLE challenge (
    challenge_id VARCHAR(255) NOT NULL,
    title VARCHAR(255) NOT NULL,
    description VARCHAR(500) NOT NULL,
    constraints VARCHAR(500),
    challenge_template BLOB,
    difficulty ENUM('EASY', 'MEDIUM', 'HARD') NOT NULL,
    testcase BLOB NOT NULL,
    PRIMARY KEY (challenge_id)
);
/* -------------------------CHALLENGES SERVICE---------------------------- */

/* -------------------------UPLOAD SERVICE---------------------------- */

CREATE TABLE submission (
    submission_id VARCHAR(255) NOT NULL,
    user_id VARCHAR(255) NOT NULL,
    contest_id VARCHAR(255) NOT NULL,
    challenge_id VARCHAR(255) NOT NULL,
    submission_file BLOB,
    submitted_time TIMESTAMP NOT NULL,
    score FLOAT,
    file_name VARCHAR(255) NOT NULL,
    file_extension VARCHAR(255) NOT NULL,
    PRIMARY KEY (submission_id),
    FOREIGN KEY (user_id) REFERENCES user(user_id),
    FOREIGN KEY (contest_id) REFERENCES contest(contest_id),
    FOREIGN KEY (challenge_id) REFERENCES challenge(challenge_id)
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
