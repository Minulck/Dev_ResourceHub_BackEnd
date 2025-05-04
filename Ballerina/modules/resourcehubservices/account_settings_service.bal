import ballerina/http;
import ballerina/sql;
public type Profile record {|
    string username;
    string profile_picture_url;
    string additional_details?;
    string email?;
    string phone_number?;
|};

public type Email record {|
    string email;
|};

public type Phone record {|
    string phone_number;
|};

public type Password record {|
    string current_password;
    string new_password;
|};

@http:ServiceConfig {
    cors: {
        allowOrigins: ["http://localhost:5173", "*"],
        allowMethods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
        allowHeaders: ["Content-Type"]
    }
}
service /settings on ln {

    resource function Get details/[int userid]() returns Profile[]|error {
        stream<Profile, sql:Error?> resultStream = dbClient->query(`
                    SELECT username,
                    email,
                    phone_number, 
                    profile_picture_url, 
                    additional_details 
                    FROM users
                    WHERE id = ${userid}`);

        Profile[] profiles = [];

        check resultStream.forEach(function(Profile profile) {
            profiles.push(profile);
        });

        return profiles;
    }
    resource function PUT profile/[int userid](@http:Payload Profile profile) returns json|error {
        sql:ExecutionResult result = check dbClient->execute(`
            UPDATE users SET 
            username = ${profile.username}, 
            profile_picture_url = ${profile.profile_picture_url}, 
            additional_details = ${profile.additional_details} 
            WHERE id = ${userid}
        `);

        if result.affectedRowCount > 0 {
            return {message: "Profile updated successfully"};
        } else {
            return error("Failed to update profile");
        }
    }

    resource function PUT email/[int userid](@http:Payload Email email) returns json|error {
        sql:ExecutionResult result = check dbClient->execute(`
            UPDATE users SET 
            email = ${email.email} 
            WHERE id = ${userid}
        `);

        if result.affectedRowCount > 0 {
            return {message: "Email updated successfully"};
        } else {
            return error("Failed to update email");
        }
    }

    resource function PUT phone/[int userid](@http:Payload Phone phone) returns json|error {
        sql:ExecutionResult result = check dbClient->execute(`
            UPDATE users SET 
            phone_number = ${phone.phone_number} 
            WHERE id = ${userid}
        `);

        if result.affectedRowCount > 0 {
            return {message: "Phone number updated successfully"};
        } else {
            return error("Failed to update phone number");
        }
    }

    resource function PUT password/[int userid](@http:Payload Password password) returns json|error {
        // Query to fetch the current password
        stream<record {| string password; |}, sql:Error?> result = dbClient->query(`
            SELECT password FROM users WHERE id = ${userid}
        `);

        string? storedPassword = null;
        check result.forEach(function(record {| string password; |} rec) {
            storedPassword = rec.password;
        });

        if storedPassword != password.current_password {
            return error("Current password is incorrect");
        }

        if password.current_password == password.new_password {
            return error("New password cannot be the same as the current password");
        }

        sql:ExecutionResult updateResult = check dbClient->execute(`
            UPDATE users SET 
            password = ${password.new_password} 
            WHERE id = ${userid}
        `);

        if updateResult.affectedRowCount > 0 {
            return {message: "Password updated successfully"};
        } else {
            return error("Failed to update password");
        }
    }
}