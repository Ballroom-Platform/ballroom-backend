// Copyright (c) 2023 WSO2 LLC. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/time;
import ballerina/persist as _;

type User record {|
    readonly string id;
    string username;
    string fullname;
	Contest[] moderatedContests;
	Submission[] submissions;
	contestAccess[] contestaccess;
	ChallengeAccess[] challengeaccess;
	Challenge[] challenge;
	Registrants[] registrants;
|};

type Contest record {|
    readonly string id;
    string title;
    byte[] readmeFile;
    time:Civil startTime;
    time:Civil endTime;
    string imageUrl;
    User moderator;
	ChallengesOnContests[] challenges;
	Submission[] submissions;
	contestAccess[] contestaccess;
	Registrants[] registrants;
|};

type Challenge record {|
    readonly string id;
    string title;
    time:Civil createdTime;
    byte[] templateFile;
    byte[] readmeFile;
    string difficulty;
    byte[] testCasesFile;
	ChallengesOnContests[] contests;
	Submission[] submissions;
	ChallengeAccess[] challengeaccess;
    User author;
|};

// Many-to-many relations between Challenge and Contest
type ChallengesOnContests record {|
    readonly string id;
    Challenge challenge;
    Contest contest;
    time:Civil assignedTime;
|};

type Submission record {|
    readonly string id;
    time:Civil submittedTime;
    float score;
    User user;
    Challenge challenge;
    Contest contest;
	SubmittedFile submittedfile;
|};

type SubmittedFile record {|
    readonly string id;
    string fileName;
    string fileExtension;
    byte[] file;
    Submission? submission;
|};

// Many-to-many relations between user and Contest
type contestAccess record {|
    readonly string id;
    Contest contest;
    User user;
    string accessType;
|};


// Many-to-many relations between user and Challenge
type ChallengeAccess record {|
    readonly string id;
    Challenge challenge;
    User user;
|};

type Registrants record {|
    readonly string id;
    time:Civil registeredTime;
    User user;
    Contest contest;
|};