import ballerina/email;
import ballerina/http;
import ballerina/io;
import ballerina/sql;

public type User record {| 
    int user_id?; 
    string username; 
    string profile_picture_url?; 
    string usertype; 
    string email; 
    string phone_number?; 
    string password?; 
    string bio; 
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
            users (username,usertype,email,profile_picture_url,phone_number,password,bio,created_at) 
            values (${user.email},${user.usertype},${user.email},'https://img.freepik.com/free-vector/smiling-young-man-illustration_1308-174669.jpg?t=st=1746539771~exp=1746543371~hmac=66ec0b65bf0ae4d49922a69369cec4c0e3b3424613be723e0ca096a97d1039f1&w=740',NULL,${randomPassword},${user.bio},NOW()) 
        `); 

        if result.affectedRowCount != 0 { 

            email:Message emailMsg = { 
                to: [user.email], 
                subject: "Your Account Login Password", 
                body: string `Hello,

Welcome to ResourceHub ! We're excited to have you on board.

Your temporary login password is: ${randomPassword}

For security reasons, please log in using the link below and change your password immediately:

[ Log In to ResourceHub ] : (https://resourcehub-fivestackdev.vercel.app/)

If you did not request this account, please disregard this message.

Best regards,  
The ResourceHub Team` 
            }; 
            var emailResult = emailClient->sendMessage(emailMsg); 
            if emailResult is error { 
        
                io:println("Error sending password email: ", emailResult.message()); 
            } 

            return { 
                message: "User added successfully. Temporary password sent via email." 
            }; 
        } else { 
            return { 
                message: "Failed to add user." 
            }; 
        } 
    } 

    resource function delete details/[int id]() returns json|error { 
        sql:ExecutionResult result = check dbClient->execute(` 
            DELETE FROM users WHERE user_id = ${id} 
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

    resource function PUT details/[int userid](@http:Payload User user) returns json|error { 
        sql:ExecutionResult result = check dbClient->execute(` 
            UPDATE users set usertype = ${user.usertype},bio = ${user.bio} WHERE user_id = ${userid} 
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

public function startUserManagementService() returns error? {
    io:println("User management service started on port 9090");
}
