/*

Created By        : Lovish Goyal
Created Date        : 13 April, 2016
===========================================

Description        : Controller class for the page KAR_Frame. Sets the variables to be passed to the page url.

*/

public class KAR_Frame_Controller {

    public String url{get;set;}        // url of the iframe
    public String height{get;set;}        // height of the iframe
    
    // Constructor
    public KAR_Frame_Controller() {
        height = ApexPages.currentPage().getParameters().get('height');    // Getting the height of the iframe from the page url
        url = ApexPages.currentPage().getParameters().get('url');          // Getting the of for the iframe from the page url
    }
}