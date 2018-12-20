public with sharing class ChecklistItemUploadContExt {

	private final Checklist_Item__c checkListItem;
	private Integer fileSize;
	public Blob fileData {get; set;}
	public String fileName {get; set;}
	public Attachment myFile {get;set;}
	public Boolean isSubmitted {get; set;}

	public ChecklistItemUploadContExt(ApexPages.StandardController stdController) {
	    this.checkListItem = (Checklist_Item__c)stdController.getRecord();
	    isSubmitted = false;
	}

	public void processUpload(){
		if(fileData == null || fileName == null){
			ApexPages.Message msgMissing = new ApexPages.Message(ApexPages.Severity.INFO, 'Please select a file.');
			ApexPages.addMessage(msgMissing);
		}else{
			try{
				Database.SaveResult result = ChecklistItemServices.insertAttachment(fileData,fileName,checkListItem.id);
				fileData = Blob.valueOf(' ');
				if (result == null || !result.isSuccess()){
					ApexPages.Message msgE = new ApexPages.Message(ApexPages.Severity.WARNING, 'Upload unsuccessful. Please Try Again.');
					ApexPages.addMessage(msgE);
				}else{
					ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Upload Successful.');
					ApexPages.addMessage(msg);
					isSubmitted = true;
				}
			}catch (Exception e){
				ControllerServices.displayExceptionAsMessage(e,true);
			}
		}

	}

}