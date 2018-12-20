trigger AttachmentTrigger on Attachment (after insert)
{
	if(Trigger.isAfter && Trigger.isInsert)
	{
		ChecklistItemServices.updateCLIItemStatusWhenAttachmentUploaded(Trigger.new);
	}
}