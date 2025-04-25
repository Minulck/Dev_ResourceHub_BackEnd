import ballerina/http;
import ballerina/io;
import ballerina/random;
import ballerina/sql;
import ballerina/email;

public type User record {| 
    int id?; 
    string username; 
    string profile_picture_url; 
    string usertype; 
    string email; 
    string phone_number; 
    string password?; 
    string additional_details?; 
    string created_at; 
|};

@http:ServiceConfig { 
    cors: { 
        allowOrigins: ["http://localhost:5173", "*"], 
        allowMethods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"], 
        allowHeaders: ["Content-Type"] 
    } 
}

service /user on ln {
    resource function get details() returns User[]|error {
        stream<User, sql:Error?> resultStream =
            dbClient->query(`SELECT * FROM users`);

        User[] users = []; 
        check resultStream.forEach(function(User user) { 
            users.push(user); 
        }); 

        return users; 
    }

    resource function post add(@http:Payload User user) returns json|error { 
        // Generate a more secure random password 
        final string LOWERCASE = "abcdefghijklmnopqrstuvwxyz"; 
        final string UPPERCASE = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"; 
        final string NUMBERS = "0123456789"; 
        final string SYMBOLS = "!@#$%^&*()-_=+[]{}|;:,.<>?"; 
        final string ALL_CHARS = LOWERCASE + UPPERCASE + NUMBERS + SYMBOLS; 
        final int PASSWORD_LENGTH = 12; 

        string randomPassword = ""; 
        // Corrected foreach loop syntax 
        foreach int _ in 0 ..< PASSWORD_LENGTH { 
            // Generate a random index within the bounds of ALL_CHARS 
            int randomIndex = check random:createIntInRange(0, ALL_CHARS.length()); 
            // Append the character at the random index to the password 
            randomPassword += ALL_CHARS.substring(randomIndex, randomIndex + 1); 
        }

        // Corrected SQL query string interpolation - Use randomPassword directly with ${} syntax
        sql:ExecutionResult result = check dbClient->execute(` 
            insert into 
            users (username,profile_picture_url,usertype,email,phone_number,password,additional_details,created_at) 
            values (${user.username},${user.profile_picture_url},${user.usertype},${user.email},${user.phone_number},${randomPassword},${user.additional_details},${user.created_at})
        `); // Parameters are interpolated directly in the query string

        if result.affectedRowCount != 0 { 
            // Send the *original* random password to the user, not the hash 
            email:Message emailMsg = { 
                to: [user.email], 
                subject: "Your Account Login Password", 
                body: string `Welcome! Your temporary password is: ${randomPassword} \n\n Please change your password after logging in.\n Login here: http://localhost:5173/login`
            }; 
            // Consider adding error handling for email sending 
            var emailResult = emailClient->sendMessage(emailMsg); 
            if emailResult is error { 
                // Log the error, but maybe don't fail the whole user creation? 
                io:println("Error sending password email: ", emailResult.message()); 
            }

            return { 
                message: "User added successfully. Temporary password sent via email." 
            }; 
        } else { 
             // Handle the case where the user was not added 
             return { 
                 message: "Failed to add user." 
             }; 
        } 
    }

    resource function delete  details/[int id]() returns json|error {
        sql:ExecutionResult result = check dbClient->execute(`
            DELETE FROM users WHERE id = ${id}
        `);

        if result.affectedRowCount == 0 { 
            return { 
                message: "User not found" 
            }; 
        }

        return { 
            message: "User deleted successfully" 
        }; 
        
    }

}

public function UserManagementService() returns error? {
    io:println("User management service started on port 9090");
}
