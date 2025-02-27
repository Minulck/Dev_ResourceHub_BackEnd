import ballerina/http;
import ballerinax/mysql;

configurable string USER = "root";
configurable string PASSWORD ="Chathumal@12";
configurable string HOST = "localhost";
configurable int PORT =3306;
configurable string DATABASE = "company";

final mysql:Client dbClient = check new(
    host=HOST, user=USER, password=PASSWORD, port=PORT, database=DATABASE
);

listener http:Listener ln = new (9090);