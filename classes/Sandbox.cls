Public class Sandbox{
    public static Boolean IsSandbox() {
      return [SELECT Id, IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }
}