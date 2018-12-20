global class CreateReportAsAttachmentPlugin implements Process.Plugin{
	public class CreateReportAsAttachmentException extends Exception{}
    private static final String ATTACHMENT_TYPE='xls';
    @TestVisible static final String APPLICATION_ID_PARAM='ApplicationID';
    @TestVisible static final String CONTRACT_ID_PARAM='ContractID';
    @TestVisible static final String UNDONE_DATE_PARAM='UndoneDate';
    @TestVisible static final String REPORT_ID_PARAM='ReportID';
    @TestVisible static final String ERROR_PARAM='Error';
    @TestVisible static final String ERROR_MESSAGE='Error getting report from server';
    private static final String ERROR_NO_REPORT='Please specify the report to attach. Contact your administrator';
    private static final String ERROR_NO_CONTRACT='Please specify the contract';

	global Process.PluginResult invoke(Process.PluginRequest request) {
		Map<String, Object> result = new Map<String, Object>();
		try{
			HttpRequest req = new HttpRequest();
            req.setEndpoint(getEndpoint((Id)request.inputParameters.get(REPORT_ID_PARAM),
                                        (String)request.inputParameters.get(CONTRACT_ID_PARAM),
                                        (Date)request.inputParameters.get(UNDONE_DATE_PARAM)));
            req.setMethod('GET');
            req.setHeader('Authorization', 'Bearer ' + userInfo.getSessionId());

            HttpResponse resp = new Http().send(req);

            if(resp.getStatusCode() == 200){
            	Attachment att = new Attachment(Body=resp.getBodyAsBlob(),
            									Name=Reports.ReportManager.describeReport((Id)request.inputParameters.get(REPORT_ID_PARAM)).
            											getReportMetadata().getName(),
            									ParentId=(Id) request.inputParameters.get(APPLICATION_ID_PARAM),
                                                ContentType=ATTACHMENT_TYPE);
            	insert att;
            } else{
            	throw new CreateReportAsAttachmentException(ERROR_MESSAGE);
            }
		} catch(Exception e){
			result.put(ERROR_PARAM, e.getMessage());
		}
		return new Process.PluginResult(result);
	}

    @TestVisible static String getEndpoint(Id reportId, String contractId, Date undoneDate){
        if(reportId==null){
            throw new CreateReportAsAttachmentException(ERROR_NO_REPORT);
        } else if(contractId==null){
            throw new CreateReportAsAttachmentException(ERROR_NO_CONTRACT);
        }

        String endpoint =  URL.getSalesforceBaseUrl().toExternalForm().replace('http:', 'https:') +
                '/' + reportId + '?' +
                'excel=1&' +
                'pv0=' + contractId;
        if(undoneDate!=null){
            endpoint+='&pv3' + EncodingUtil.urlEncode(String.valueOf(undoneDate), 'UTF-8');
        }

        return endpoint;
    }

	global Process.PluginDescribeResult describe() {
		Process.PluginDescribeResult result = new Process.PluginDescribeResult();
		result.inputParameters = new List<Process.PluginDescribeResult.InputParameter>{
			new Process.PluginDescribeResult.InputParameter(
                APPLICATION_ID_PARAM, 
                Process.PluginDescribeResult.ParameterType.ID, 
                true),
            new Process.PluginDescribeResult.InputParameter(
                CONTRACT_ID_PARAM, 
                Process.PluginDescribeResult.ParameterType.STRING, 
                true),
            new Process.PluginDescribeResult.InputParameter(
                UNDONE_DATE_PARAM, 
                Process.PluginDescribeResult.ParameterType.DATE, 
                true),
        	 new Process.PluginDescribeResult.InputParameter(
                REPORT_ID_PARAM, 
                Process.PluginDescribeResult.ParameterType.ID, 
                true)};
		result.outputParameters = new List<Process.PluginDescribeResult.OutputParameter>{
			new Process.PluginDescribeResult.OutputParameter(
                ERROR_PARAM, 
                Process.PluginDescribeResult.ParameterType.STRING)};

		return result;
	}
}