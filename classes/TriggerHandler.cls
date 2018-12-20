public virtual class TriggerHandler {
	private static Map<String,TriggerHandler> handlerMap = null;
	private static boolean setupAlreadyRun = false;
	public class TriggerHandlerException extends Exception {}

	static {
		handlerMap = new Map<String,TriggerHandler>();
	}

	// The main execution method for all handlers
	public void runHandler(){
		if(!Trigger.isExecuting && !Test.isRunningTest()) {
			throw new TriggerHandlerException('Trigger handler called outside of Trigger execution');
		}

		//Check for KillSwitch flag
		Id profileId = Userinfo.getProfileId();
		Killswitch__c killSwitch = Killswitch__c.getInstance(profileId);

		if(killSwitch == null || !killSwitch.Killswitch_Enabled__c){
			// dispatch general before and after handler methods
			if(!setupAlreadyRun || !isSingleton()){
				setup();
				setupAlreadyRun = true;
			}
			if(Trigger.isBefore){
				doBefore();
			} else if(Trigger.isAfter){
				doAfter();
			}

			// dispatch specific (event-based) before and after handler methods
			if(Trigger.isBefore && Trigger.isInsert) {
				beforeInsert();
		    } else if(Trigger.isBefore && Trigger.isUpdate) {
				beforeUpdate();
		    } else if(Trigger.isBefore && Trigger.isDelete) {
				beforeDelete();
		    } else if(Trigger.isAfter && Trigger.isInsert) {
				afterInsert();
		    } else if(Trigger.isAfter && Trigger.isUpdate) {
				afterUpdate();
		    } else if(Trigger.isAfter && Trigger.isDelete) {
				afterDelete();
		    } else if(Trigger.isAfter && Trigger.isUndelete) {
				afterUndelete();
		    }
			System.debug(getHandlerName() + ': The Killswitch is enabled for this profile');
		}
	}

	// Instantiates a specific handler class and determines whether instances are reused across contexts (before and after)
	public static TriggerHandler getInstance(String handlerClass,boolean runAsSingleton){
		Type t = Type.forName(handlerClass);
		if(!runAsSingleton){
			return (TriggerHandler)t.newInstance();
		} else {
			if(handlerMap.get(handlerClass) == null){
				handlerMap.put(handlerClass,(TriggerHandler)t.newInstance());
			}
			return handlerMap.get(handlerClass);
		}
	}

	// Updates the internal handler instance.  This must be done when the trigger is created as a singleton
	// if instance variables have been initialized before calling the runHandler method.
	public void updateHandler(TriggerHandler handler){
		TriggerHandler.handlerMap.put(handler.getHandlerName(),handler);
		//TriggerHandler.handler = handler;
	}

	@TestVisible
	public String getHandlerName() {
		return String.valueOf(this).substring(0,String.valueOf(this).indexOf(':'));
	}

	@TestVisible
	public boolean isSingleton(){
		return handlerMap.get(this.getHandlerName()) != null;
	}


	// context-specific methods for override
	@TestVisible
	protected virtual void doBefore(){
	}
	@TestVisible
	protected virtual void doAfter(){
	}
	@TestVisible
	protected virtual void setup(){
	}
	@TestVisible
	protected virtual void beforeInsert(){
	}
	@TestVisible
	protected virtual void beforeUpdate(){
	}
	@TestVisible
	protected virtual void beforeDelete(){
	}
	@TestVisible
	protected virtual void afterInsert(){
	}
	@TestVisible
	protected virtual void afterUpdate(){
	}
	@TestVisible
	protected virtual void afterDelete(){
	}
	@TestVisible
	protected virtual void afterUndelete(){
	}
}