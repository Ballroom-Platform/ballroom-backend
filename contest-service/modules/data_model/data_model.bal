import ballerina/sql;
import ballerina/time;

// Copied from the data_model package 
public type Contest record {
    @sql:Column {name: "contest_id"}
    string contestId;
    string title;
    string? description;
    @sql:Column {name: "start_time"}
    time:Civil startTime;
    @sql:Column {name: "end_time"}
    time:Civil endTime;
    string moderator;
};