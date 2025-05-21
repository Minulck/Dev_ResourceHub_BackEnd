import ballerina/http;
import ballerina/sql;
import ballerina/email;

// Profile data structure for user settings
public type Profile record {| 
    string username;
    string profile_picture_url;
    string bio?;
    string usertype?;
    string email?;
    string phone_number?;
|};

// Structure to carry email and verification code
public type Email record {| 
    string email;
    int code?;
|};

// Structure for phone number update
public type Phone record {| 
    string phone_number;
|};

// Structure for password update request
public type Password record {| 
    string current_password;
    string new_password;
|};

// CORS configuration for client access
@http:ServiceConfig {
    cors: {
        allowOrigins: ["http://localhost:5173", "*"],
        allowMethods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
        allowHeaders: ["Content-Type"]
    }
}

// Settings service for user profile, email, phone, and password management
service /settings on ln {

    // Fetch user profile details by user ID
    resource function Get details/[int userid]() returns Profile[]|error {
        stream<Profile, sql:Error?> resultStream = dbClient->query(`
                    SELECT username,
                    email,
                    phone_number, 
                    profile_picture_url, 
                    usertype,
                    bio 
                    FROM users
                    WHERE user_id = ${userid}`);

        Profile[] profiles = [];

        check resultStream.forEach(function(Profile profile) {
            profiles.push(profile);
        });

        return profiles;
    }

    // Update username, profile picture, and bio
    resource function PUT profile/[int userid](@http:Payload Profile profile) returns json|error {
        sql:ExecutionResult result = check dbClient->execute(`
            UPDATE users SET 
            username = ${profile.username}, 
            profile_picture_url = ${profile.profile_picture_url}, 
            bio = ${profile.bio} 
            WHERE user_id = ${userid}
        `);

        if result.affectedRowCount > 0 {
            return {message: "Profile updated successfully"};
        } else {
            return error("Failed to update profile");
        }
    }

    // Update email address
    resource function PUT email/[int userid](@http:Payload Email email) returns json|error {
        sql:ExecutionResult result = check dbClient->execute(`
            UPDATE users SET 
            email = ${email.email} 
            WHERE user_id = ${userid}
        `);

        if result.affectedRowCount > 0 {
            return {message: "Email updated successfully"};
        } else {
            return error("Failed to update email");
        }
    }

    // Send verification email with code
    resource function post sendEmail(@http:Payload Email email) returns json|error {
        email:Message resetEmail = {
            to: [email.email],
            subject: "Verify Your Email Address to Complete the Update",
            body: string `Your verification code is: ${email.code ?: "!!error!!"}

Enter this code in the app to verify your email address.

If you didn’t request this, you can safely ignore this message.
`
        };

        error? emailResult = emailClient->sendMessage(resetEmail);
        if emailResult is error {
            return error("Error sending Code to email: ");
        }

        return {
            message: "Code Send successfully. Check your email for the Verification Code."
        };
    }

    // Update phone number
    resource function PUT phone/[int userid](@http:Payload Phone phone) returns json|error {
        sql:ExecutionResult result = check dbClient->execute(`
            UPDATE users SET 
            phone_number = ${phone.phone_number} 
            WHERE user_id = ${userid}
        `);

        if result.affectedRowCount > 0 {
            return {message: "Phone number updated successfully"};
        } else {
            return error("Failed to update phone number");
        }
    }

    // Update password after validating current password
    resource function PUT password/[int userid](@http:Payload Password password) returns json|error {
        // Fetch the current password for validation
        stream<record {| string password; |}, sql:Error?> result = dbClient->query(`
            SELECT password FROM users WHERE user_id = ${userid}
        `);

        string? storedPassword = null;
        check result.forEach(function(record {| string password; |} rec) {
            storedPassword = rec.password;
        });

        // Validate current password before update
        if storedPassword != password.current_password {
            return error("Current password is incorrect");
        }

        if password.current_password == password.new_password {
            return error("New password cannot be the same as the current password");
        }

        // Update password in database
        sql:ExecutionResult updateResult = check dbClient->execute(`
            UPDATE users SET 
            password = ${password.new_password} 
            WHERE user_id = ${userid}
        `);

        if updateResult.affectedRowCount > 0 {
            return {message: "Password updated successfully"};
        } else {
            return error("Failed to update password");
        }
    }
}
