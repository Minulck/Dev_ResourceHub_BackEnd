import ballerina/http;
import ballerina/io;
import ballerina/sql;
import ballerina/email;

public type User record {| 
    int id?; 
    string username; 
    string profile_picture_url?; 
    string usertype; 
    string email; 
    string phone_number?; 
    string password?; 
    string additional_details?; 
    string created_at?; 
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

        // Generate a random password of length 8
        string randomPassword = check generateSimplePassword(8);
        

        sql:ExecutionResult result = check dbClient->execute(` 
            insert into 
            users (username,usertype,email,profile_picture_url,phone_number,password,additional_details,created_at) 
            values (${user.email},${user.usertype},${user.email},'https://uxwing.com/wp-content/themes/uxwing/download/peoples-avatars/man-user-circle-icon.png',NULL,${randomPassword},${user.additional_details},NOW())
        `); 

        if result.affectedRowCount != 0 { 
            // Send the *original* random password to the user, not the hash 
            email:Message emailMsg = { 
                to: [user.email], 
                subject: "Your Account Login Password", 
                body: string `Welcome to our platform! Your temporary password is: ${randomPassword}

Please change your password after logging in for security purposes.
You can log in here: http://localhost:5173/login

If you did not request this, please ignore this message.

Best regards,  
The Team`
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

    resource function PUT details/[int userid](@http:Payload User user) returns json|error{
        sql:ExecutionResult result = check dbClient->execute(`
            UPDATE users set usertype = ${user.usertype},additional_details = ${user.additional_details} WHERE id = ${userid}
        `);

        if result.affectedRowCount == 0 { 
            return { 
                message: "User not found" 
            }; 
        }

        return { 
            message: "User updated successfully" 
        }; 
    }

}

public function UserManagementService() returns error? {
    io:println("User management service started on port 9090");
}
