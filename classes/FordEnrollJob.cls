public with sharing class FordEnrollJob implements Schedulable {
  public void execute(SchedulableContext ctx) {
    FordEnrollHandler hdlr = new FordEnrollHandler();
    hdlr.purgeFordDoc();
  }
}