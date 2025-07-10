import ballerina/http;
import ballerina/sql;
import ballerina/email;
import ballerina/jwt;

// Profile data structure for user settings
public type Profile record {|
    string username;
    string profile_picture_url;
    string? bio;
    string? usertype;
    string? email;
    string? phone_number;
|};

// Structure to carry email and verification code
public type Email record {|
    string email;
    int? code;
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

// Helper function to extract and validate JWT token and return payload
function getValidatedPayload(http:Request req) returns jwt:Payload|error {
    string|error authHeader = req.getHeader("Authorization");
    if (authHeader is error) {
        return error("Authorization header not found");
    }

    string token = authHeader.startsWith("Bearer ") ? authHeader.substring(7) : authHeader;
    jwt:Payload|error payload = jwt:validate(token, jwtValidatorConfig);
    if (payload is error) {
        return error("Invalid or expired token");
    }
    return payload;
}

// Helper function to check role from JWT payload
function hasRole(jwt:Payload payload, string requiredRole) returns boolean {
    anydata roleClaim = payload["role"];
    return roleClaim is string && roleClaim == requiredRole;
}

// Helper function to check if user has any of the allowed roles
function hasAnyRole(jwt:Payload payload, string[] allowedRoles) returns boolean {
    anydata roleClaim = payload["role"];
    if roleClaim is string {
        foreach string role in allowedRoles {
            if roleClaim == role {
                return true;
            }
        }
    }
    return false;
}

// CORS configuration for client access
@http:ServiceConfig {
    cors: {
        allowOrigins: ["http://localhost:5173", "*"],
        allowMethods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
        allowHeaders: ["Content-Type", "Authorization"]
    }
}
service /settings on ln {

    // Fetch user profile details by user ID - accessible by user themselves or admin
    resource function get details/[int userid](http:Request req) returns Profile[]|error {
        jwt:Payload payload = check getValidatedPayload(req);

        // Allow if user is admin, manager, or requesting own profile
        if (!hasAnyRole(payload, ["admin", "manager"]) && <int>payload["id"] != userid) {
            return error("Forbidden: You do not have permission to access this resource");
        }

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

    // Update username, profile picture, and bio - user can update own profile, admin can update any
    resource function put profile/[int userid](http:Request req, @http:Payload Profile profile) returns json|error {
        jwt:Payload payload = check getValidatedPayload(req);

        // Only admin or the user themselves can update profile
        if (!hasAnyRole(payload, ["admin"]) && <int>payload["id"] != userid) {
            return error("Forbidden: You do not have permission to update this profile");
        }

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

    // Update email address - user can update own email, admin can update any
    resource function put email/[int userid](http:Request req, @http:Payload Email email) returns json|error {
        jwt:Payload payload = check getValidatedPayload(req);

        // Only admin or the user themselves can update email
        if (!hasAnyRole(payload, ["admin"]) && <int>payload["id"] != userid) {
            return error("Forbidden: You do not have permission to update this email");
        }

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

    // Send verification email with code - open endpoint (no auth required)
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
            return error("Error sending Code to email");
        }

        return {
            message: "Code sent successfully. Check your email for the Verification Code."
        };
    }

    // Update phone number - user can update own phone, admin can update any
    resource function put phone/[int userid](http:Request req, @http:Payload Phone phone) returns json|error {
        jwt:Payload payload = check getValidatedPayload(req);

        // Only admin or the user themselves can update phone
        if (!hasAnyRole(payload, ["admin"]) && <int>payload["id"] != userid) {
            return error("Forbidden: You do not have permission to update this phone number");
        }

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

    // Update password after validating current password - user can update own password, admin can update any
    resource function put password/[int userid](http:Request req, @http:Payload Password password) returns json|error {
        jwt:Payload payload = check getValidatedPayload(req);

        // Only admin or the user themselves can update password
        if (!hasAnyRole(payload, ["admin"]) && <int>payload["id"] != userid) {
            return error("Forbidden: You do not have permission to update this password");
        }

        // Fetch the current password for validation
        stream<record {| string password; |}, sql:Error?> result = dbClient->query(`
            SELECT password FROM users WHERE user_id = ${userid}
        `);

        string? storedPassword = null;
        check result.forEach(function(record {| string password; |} rec) {
            storedPassword = rec.password;
        });

        // If admin is updating password, skip current password validation
        if (!hasAnyRole(payload, ["admin"])) {
            if storedPassword != password.current_password {
                return error("Current password is incorrect");
            }

            if password.current_password == password.new_password {
                return error("New password cannot be the same as the current password");
            }
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
