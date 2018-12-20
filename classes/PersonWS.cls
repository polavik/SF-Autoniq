/**
* Copyright 2013 Forseva, LLC. All rights reserved.
*/
global class PersonWS {
    
    WebService String NamePrefix;  // Mr
    WebService String FirstName; // George
    WebService String MiddleName;  // Sebastian
    WebService String LastName;  // Smiley
    WebService String GenerationSuffix;  // Jr
    WebService String SalutationSuffix;  // MD
    
    WebService String UnparsedAddress;  // 1000 N. State Ave W.
    WebService String AddressNumber;  // 1000
    WebService String StreetName; // State
    WebService String StreetPreDirection;  // N
    WebService String StreetPostDirection;  // W
    WebService String StreetType;  // AV
    WebService String UnitNumber;  // #301
    
    WebService String Phone;
    
    WebService String City;  // Chicago
    WebService String State;  // IL
    WebService String PostalCode;  // 60606
    
    WebService String SSN; // 222334444
    WebService Date DateOfBirth;  // 07/24/1961
    WebService Integer Age;  // 49
    
    WebService ID personId;  // sf id of a record in salesforce where person data is stored.  This could be a contact or some other custom field.
}

// EOF