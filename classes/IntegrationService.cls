public interface IntegrationService {
    /**
     * Runs the service, processing the integrations record passed in.
     */
    void execute(Integration__c[] records);

    /**
     * Returns the maximum number of records this service can process at one time.
     */
    integer getBatchSize();
}