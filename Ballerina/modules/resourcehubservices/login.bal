import ballerina/http;
import ballerina/jwt;
import ballerina/io;
import ballerina/sql;
import ballerina/random;
import ballerina/email;

type ForgotPassword record {
    string email;
};


// JWT issuer configuration
jwt:IssuerConfig jwtIssuerConfig = {
    username: "ballerina",
    issuer: "ballerina",
    audience: ["ballerina.io"],
    signatureConfig: {
        config: {
            keyFile: "certificate.key"
        }
    },
    expTime: 3600 
};

// JWT validator configuration
jwt:ValidatorConfig jwtValidatorConfig = {
    issuer: "ballerina",
    audience: ["ballerina.io"],
    signatureConfig: {
        certFile: "certificate.crt"
    },
    clockSkew: 60
};

function generateSimplePassword(int length) returns string|error {
    final string LOWERCASE = "abcdefghijklmnopqrstuvwxyz";
    string[] chars = [];

    // Generate random lowercase characters
    foreach int _ in 0 ..< length {
        int randomIndex = check random:createIntInRange(0, LOWERCASE.length());
        chars.push(LOWERCASE[randomIndex]);
    }

    // Convert array to string
    return chars.reduce(function(string acc, string c) returns string => acc + c, "");
}

@http:ServiceConfig {
    cors: {
        allowOrigins: ["http://localhost:5173", "*"],
        allowMethods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
        allowHeaders: ["Content-Type"]
    }
}
service /auth on ln {

    resource function post login(@http:Payload record {string email; string password;} credentials) returns json|error {
        
        sql:ParameterizedQuery query = `SELECT username,id, email, password, usertype , profile_picture_url FROM users WHERE email = ${credentials.email}`;
        record {|string username;int id;string email; string password; string usertype;string profile_picture_url;|}|sql:Error result = dbClient->queryRow(query);

        if (result is sql:Error) {
            if (result is sql:NoRowsError) {
                io:println("Invalid email: " + credentials.email);
                return error("Invalid email");
            } else {
                io:println("Database error: " + result.message());
                return error("Database error");
            }
        }

        if (result.password == credentials.password) {
            jwt:IssuerConfig config = jwtIssuerConfig;
            config.username = credentials.email;
            config.customClaims = {"role": result.usertype};
            config.customClaims = {"username": result.username};
            config.customClaims = {"id": result.id};
            config.customClaims = {"profile_picture": result.profile_picture_url};
            string token = check jwt:issue(config);

            return {token: token, usertype: result.usertype , username: result.username,id: result.id, email: result.email , profile_picture_url: result.profile_picture_url};
        } else {
            io:println("Invalid password for user: " + credentials.email);
            return error("Invalid password");
        }
    }

    resource function get protected(http:Request req) returns string|error {
        io:println("Accessing protected resource");
        
        string|error authHeader = req.getHeader("Authorization");
        if (authHeader is error) {
            io:println("Authorization header not found");
            return error("Authorization header not found");
        }

        string token = authHeader.startsWith("Bearer ") ? authHeader.substring(7) : authHeader;
        
        jwt:Payload|error payload = check jwt:validate(token, jwtValidatorConfig);
        if (payload is jwt:Payload) {
            io:println("Protected data accessed successfully");
            return "Protected data accessed successfully";
        } else {
            io:println("Unauthorized access attempt");
            return error("Unauthorized");
        }
    }

    resource function post resetpassword(@http:Payload ForgotPassword password) returns json|error {
    // Validate email format (basic check)
    if !password.email.includes("@") || !password.email.includes(".") {
        return error("Invalid email format", statusCode = 400);
    }

    // Generate simple random password
    string randomPassword = check generateSimplePassword(8);

    // Update password in database
    sql:ParameterizedQuery updateQuery = `UPDATE users SET password = ${randomPassword} 
                                        WHERE email = ${password.email}`;
    sql:ExecutionResult updateResult = check dbClient->execute(updateQuery);

    if updateResult.affectedRowCount == 0 {
        return error("Failed to reset password", statusCode = 500);
    }

    // Send email
    email:Message resetEmail = {
        to: [password.email],
        subject: "Your Account Password Reset",
        body: string `Your temporary password is: ${randomPassword}
                     Please change your password after logging in.
                     Login here: http://localhost:5173/login`
    };

    error? emailResult = emailClient->sendMessage(resetEmail);
    if emailResult is error {
        io:println("Error sending password email: ", emailResult.message());
        // Don't fail the request if email fails, but log it
    }

    return {
        message: "Password reset successful. Check your email for the temporary password."
    };
    }
    
}
