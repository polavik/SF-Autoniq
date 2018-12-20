@RestResource(urlMapping='/autoniq/updateuser/*')
global class ATNQUpdateUserService {    
    @HttpPost
    global static string updateUser() { 

        RestRequest req = RestContext.request;
        string userData = req.requestBody.toString().trim();
        Type resultType = Type.forName('UpdateUserDetail');
        UpdateUserDetail existingUser = (UpdateUserDetail)json.deserialize(userData,resultType);
        string responseMsg;
        List<Contact> contactList = [SELECT Id, FirstName, LastName, Phone, MailingCity FROM Contact WHERE Id = :existingUser.contactId];
        Contact c;
        If(!contactList.isEmpty()){
           c = contactList[0];
           c.FirstName = existingUser.firstName;
           c.LastName = existingUser.lastName;
           c.Phone = existingUser.phone;
           c.MailingCity = existingUser.city;
        }
        
        Update c;
        responseMsg = 'success';
        return responseMsg;
        
    }
}