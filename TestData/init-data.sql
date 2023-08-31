-- Insert data into User table
INSERT INTO User (id, username, fullname)
VALUES ('f72932f7-ddbe-4e1b-8632-40df8417de2e', 'admin@admin.com', 'Joe Dove'),
    ('e1f2d3c4-ba98-7654-3210-9876fedcba21', 'readuser2@example.com', 'Jane Smith'),
    ('a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d', 'writeuser@example.com', 'Alex Johnson');

-- Insert data into Challenge table
INSERT INTO Challenge (id, title, createdTime, templateFile, readmeFile, difficulty, testCasesFile, authorId)
VALUES ('challenge_id_1', 'Challenge 1', NOW(), 'template_file_data', 'readme_file_data_1', 'Easy', 'test_cases_file_data', 'f72932f7-ddbe-4e1b-8632-40df8417de2e'),
    ('challenge_id_2', 'Challenge 2', NOW(), 'template_file_data_2', 'readme_file_data_2', 'Medium', 'test_cases_file_adta_2', 'e1f2d3c4-ba98-7654-3210-9876fedcba21'),
    ('challenge_id_3', 'Challenge 3', NOW(), 'template_file_data_3', 'readme_file_data_3', 'Medium', 'test_cases_file_adta_3', 'a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d'),
    ('challenge_id_4', 'Challenge 4', NOW(), 'template_file_data_4', 'readme_file_data_4', 'Medium', 'test_cases_file_adta_4', 'f72932f7-ddbe-4e1b-8632-40df8417de2e'),
    ('challenge_id_5', 'Challenge 5', NOW(), 'template_file_data_5', 'readme_file_data_5', 'Medium', 'test_cases_file_adta_5', 'f72932f7-ddbe-4e1b-8632-40df8417de2e'),
    ('challenge_id_6', 'Challenge 6', NOW(), 'template_file_data_6', 'readme_file_data_6', 'Medium', 'test_cases_file_adta_6', 'f72932f7-ddbe-4e1b-8632-40df8417de2e');

-- Insert data into Contest table
INSERT INTO Contest (id, title, readmeFile, startTime, endTime, imageUrl, moderatorId)
VALUES ('contest_id_1', 'Contest 1', 'readme_file_data_1', NOW(), DATE_ADD(NOW(), INTERVAL 1 HOUR), 'image_url_1', 'f72932f7-ddbe-4e1b-8632-40df8417de2e'),
    ('contest_id_2', 'Contest 2', 'readme_file_data_2', NOW(), DATE_ADD(NOW(), INTERVAL 1 HOUR), 'image_url_2', 'f72932f7-ddbe-4e1b-8632-40df8417de2e'),
    ('contest_id_3', 'Contest 3', 'readme_file_data_3', DATE_ADD(NOW(), INTERVAL 6 HOUR), DATE_ADD(NOW(), INTERVAL 9 HOUR), 'image_url_3', 'f72932f7-ddbe-4e1b-8632-40df8417de2e'),
    ('contest_id_4', 'Contest 4', 'readme_file_data_4', DATE_ADD(NOW(), INTERVAL 9 HOUR), DATE_ADD(NOW(), INTERVAL 15 HOUR), 'image_url_4', 'f72932f7-ddbe-4e1b-8632-40df8417de2e');

-- Insert data into contestAccess table
INSERT INTO contestAccess (id, accessType, contestId, userId)
VALUES ('contest_access_id_1', 'Read', 'contest_id_1', 'f72932f7-ddbe-4e1b-8632-40df8417de2e'),
    ('contest_access_id_2', 'Read', 'contest_id_2', 'f72932f7-ddbe-4e1b-8632-40df8417de2e'),
    ('contest_access_id_3', 'Read', 'contest_id_2', 'a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d'),
    ('contest_access_id_4', 'Write', 'contest_id_2', 'e1f2d3c4-ba98-7654-3210-9876fedcba21'),
    ('contest_access_id_5', 'Read', 'contest_id_3', 'f72932f7-ddbe-4e1b-8632-40df8417de2e'),
    ('contest_access_id_6', 'Write', 'contest_id_3', 'f72932f7-ddbe-4e1b-8632-40df8417de2e'),
    ('contest_access_id_7', 'Read', 'contest_id_3', 'a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d'),
    ('contest_access_id_8', 'Write', 'contest_id_3', 'a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d'),
    ('contest_access_id_9', 'Read', 'contest_id_4', 'f72932f7-ddbe-4e1b-8632-40df8417de2e'),
    ('contest_access_id_10', 'Write', 'contest_id_4', 'f72932f7-ddbe-4e1b-8632-40df8417de2e'),
    ('contest_access_id_11', 'Read', 'contest_id_4', 'a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d'),
    ('contest_access_id_12', 'Write', 'contest_id_4', 'a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d');

-- Insert data into Registrants table
INSERT INTO Registrants (id, registeredTime, userId, contestId)
VALUES ('registrants_id_1', NOW(), 'f72932f7-ddbe-4e1b-8632-40df8417de2e', 'contest_id_1'),
    ('registrants_id_2', NOW(), 'f72932f7-ddbe-4e1b-8632-40df8417de2e', 'contest_id_2'),
    ('registrants_id_3', NOW(), 'f72932f7-ddbe-4e1b-8632-40df8417de2e', 'contest_id_3'),
    ('registrants_id_4', NOW(), 'f72932f7-ddbe-4e1b-8632-40df8417de2e', 'contest_id_4'),
    ('registrants_id_5', NOW(), 'e1f2d3c4-ba98-7654-3210-9876fedcba21', 'contest_id_1'),
    ('registrants_id_7', NOW(), 'e1f2d3c4-ba98-7654-3210-9876fedcba21', 'contest_id_2'),
    ('registrants_id_8', NOW(), 'e1f2d3c4-ba98-7654-3210-9876fedcba21', 'contest_id_4'),
    ('registrants_id_9', NOW(), 'a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d', 'contest_id_1'),
    ('registrants_id_6', NOW(), 'a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d', 'contest_id_2'),
    ('registrants_id_10', NOW(), 'a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d', 'contest_id_4');

-- Insert data into SubmittedFile table
INSERT INTO SubmittedFile (id, fileName, fileExtension, file)
VALUES ('submitted_file_id_1', 'submitted_file_name_1', '.zip', 'submitted_file_data_1'),
    ('submitted_file_id_2', 'submitted_file_name_2', '.zip', 'submitted_file_data_2'),
    ('submitted_file_id_3', 'submitted_file_name_3', '.zip', 'submitted_file_data_3'),
    ('submitted_file_id_4', 'submitted_file_name_4', '.zip', 'submitted_file_data_4'),
    ('submitted_file_id_5', 'submitted_file_name_5', '.zip', 'submitted_file_data_5'),
    ('submitted_file_id_6', 'submitted_file_name_6', '.zip', 'submitted_file_data_6'),
    ('submitted_file_id_7', 'submitted_file_name_7', '.zip', 'submitted_file_data_7'),
    ('submitted_file_id_8', 'submitted_file_name_8', '.zip', 'submitted_file_data_8'),
    ('submitted_file_id_9', 'submitted_file_name_9', '.zip', 'submitted_file_data_9'),
    ('submitted_file_id_10', 'submitted_file_name_10', '.zip', 'submitted_file_data_10'),
    ('submitted_file_id_11', 'submitted_file_name_11', '.zip', 'submitted_file_data_11'),
    ('submitted_file_id_12', 'submitted_file_name_12', '.zip', 'submitted_file_data_12');

-- Insert data into Submission table
INSERT INTO Submission (id, submittedTime, score, userId, challengeId, contestId, submittedfileId)
VALUES ('submission_id_1', NOW(), 90.5, 'f72932f7-ddbe-4e1b-8632-40df8417de2e', 'challenge_id_1', 'contest_id_1', 'submitted_file_id_1'),
    ('submission_id_2', NOW(), 85.0, 'f72932f7-ddbe-4e1b-8632-40df8417de2e', 'challenge_id_2', 'contest_id_1', 'submitted_file_id_2'),
    ('submission_id_3', NOW(), 60.0, 'f72932f7-ddbe-4e1b-8632-40df8417de2e', 'challenge_id_3', 'contest_id_2', 'submitted_file_id_3'),
    ('submission_id_4', NOW(), 55.0, 'f72932f7-ddbe-4e1b-8632-40df8417de2e', 'challenge_id_4', 'contest_id_2', 'submitted_file_id_4'),
    ('submission_id_5', NOW(), 50.0, 'e1f2d3c4-ba98-7654-3210-9876fedcba21', 'challenge_id_3', 'contest_id_2', 'submitted_file_id_5'),
    ('submission_id_6', NOW(), 45.0, 'e1f2d3c4-ba98-7654-3210-9876fedcba21', 'challenge_id_4', 'contest_id_2', 'submitted_file_id_6'),
    ('submission_id_7', NOW(), 80.0, 'e1f2d3c4-ba98-7654-3210-9876fedcba21', 'challenge_id_1', 'contest_id_1', 'submitted_file_id_7'),
    ('submission_id_8', NOW(), 75.0, 'e1f2d3c4-ba98-7654-3210-9876fedcba21', 'challenge_id_2', 'contest_id_1', 'submitted_file_id_8'),
    ('submission_id_9', NOW(), 40.0, 'a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d', 'challenge_id_3', 'contest_id_2', 'submitted_file_id_9'),
    ('submission_id_10', NOW(), 35.0, 'a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d', 'challenge_id_4', 'contest_id_2', 'submitted_file_id_10'),
    ('submission_id_11', NOW(), 70.0, 'a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d', 'challenge_id_1', 'contest_id_1', 'submitted_file_id_11'),
    ('submission_id_12', NOW(), 65.0, 'a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d', 'challenge_id_2', 'contest_id_1', 'submitted_file_id_12');

-- Insert data into ChallengeAccess table
INSERT INTO ChallengeAccess (id, challengeId, userId)
VALUES ('challenge_access_id_1', 'challenge_id_1', 'f72932f7-ddbe-4e1b-8632-40df8417de2e'),
    ('challenge_access_id_2', 'challenge_id_2', 'f72932f7-ddbe-4e1b-8632-40df8417de2e'),
    ('challenge_access_id_3', 'challenge_id_3', 'f72932f7-ddbe-4e1b-8632-40df8417de2e'),
    ('challenge_access_id_4', 'challenge_id_4', 'f72932f7-ddbe-4e1b-8632-40df8417de2e'),
    ('challenge_access_id_5', 'challenge_id_5', 'f72932f7-ddbe-4e1b-8632-40df8417de2e'),
    ('challenge_access_id_6', 'challenge_id_6', 'f72932f7-ddbe-4e1b-8632-40df8417de2e'),
    ('challenge_access_id_7', 'challenge_id_3', 'e1f2d3c4-ba98-7654-3210-9876fedcba21'),
    ('challenge_access_id_8', 'challenge_id_4', 'e1f2d3c4-ba98-7654-3210-9876fedcba21'),
    ('challenge_access_id_9', 'challenge_id_5', 'e1f2d3c4-ba98-7654-3210-9876fedcba21'),
    ('challenge_access_id_10', 'challenge_id_6', 'e1f2d3c4-ba98-7654-3210-9876fedcba21'),
    ('challenge_access_id_11', 'challenge_id_5', 'a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d'),
    ('challenge_access_id_12', 'challenge_id_6', 'a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d'),
    ('challenge_access_id_13', 'challenge_id_3', 'a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d'),
    ('challenge_access_id_14', 'challenge_id_4', 'a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d');

-- Insert data into ChallengesOnContests table
INSERT INTO ChallengesOnContests (id, assignedTime, challengeId, contestId)
VALUES ('challenges_on_contests_id_1', NOW(), 'challenge_id_1', 'contest_id_1'),
    ('challenge_on_contests_id_2', NOW(), 'challenge_id_2', 'contest_id_1'),
    ('challenge_on_contests_id_7', NOW(), 'challenge_id_3', 'contest_id_2'),
    ('challenge_on_contests_id_8', NOW(), 'challenge_id_4', 'contest_id_2'),
    ('challenge_on_contests_id_9', NOW(), 'challenge_id_5', 'contest_id_2'),
    ('challenge_on_contests_id_10', NOW(), 'challenge_id_6', 'contest_id_2'),
    ('challenge_on_contests_id_11', NOW(), 'challenge_id_3', 'contest_id_3'),
    ('challenge_on_contests_id_12', NOW(), 'challenge_id_4', 'contest_id_3'),
    ('challenge_on_contests_id_13', NOW(), 'challenge_id_5', 'contest_id_3'),
    ('challenge_on_contests_id_14', NOW(), 'challenge_id_6', 'contest_id_3'),
    ('challenge_on_contests_id_15', NOW(), 'challenge_id_3', 'contest_id_4'),
    ('challenge_on_contests_id_16', NOW(), 'challenge_id_4', 'contest_id_4'),
    ('challenge_on_contests_id_17', NOW(), 'challenge_id_5', 'contest_id_4'),
    ('challenge_on_contests_id_18', NOW(), 'challenge_id_6', 'contest_id_4');
