/*
**************************************************************************************
*** Created By:    Justin Hawkins
***
*** Created Date:  08/10/2017
***
*** Class Purpose: This class allows for a simple way to build test data for different
***                test scenarios in the Hub.  Class can be expanded by adding new
***                new data creation methods that return the class instance
***
**************************************************************************************
*/
@isTest
public class IntranetTestDataBuilder {
	
	public List<Intranet_Content__c> contentPages { get; set; }
	public List<Intranet_Content__c> contentConfig { get; set; }
	public Intranet_Content_Buckets__c contentBucket { get; set; }
	public Tags__c tag { get; set; }
	public CollaborationGroup chatterGroup { get; set; }
	public Map<Intranet_Content__c, List<Intranet_Content__c>> parentChildMap { get; set; }

	// Configuration Mappings
	private Map<String, String> portalConfigEntries = new Map<String, String>{ 'Allowed Preview' => 'PDF,JPG,PNG,WORD_X,WORD',
																				'Search Limit' => '100',
																				'Search Pagination' => '20' };

	private Map<String, String> searchConfigEntries = new Map<String, String>{ 'Articles' => 'Intranet_Content_Version__c',
																				'Chatter Posts' => 'FeedItem',
																				'Files' => 'ContentVersion' };

	private Map<String, String> langConfigEntries = new Map<String, String>{ 'en_Us' => 'English' };
	private Map<String, String> pollConfigEntries = new Map<String, String>{ 'Home Page Poll' => 'KAR Weekly Polls' };
	private Map<String, String> recogConfigEtnries = new Map<String, String>{ 'Config - Recognition' => 'Recognition' };
	private Map<String, String> stockConfigEntries = new Map<String, String>{ 'KAR Stock Symbol' => 'KAR' };


	private static final String CONTENT_NAME = 'Hub Testing';
	private static final String CONTENT_BUCKET_ADMINS = 'Intranet Content Admins';
	private static final String CONTENT_BUCKET_VIEWERS = 'All Internal Users - Default';
	private static final String CONTENT_RECORD_TYPE_CONFIG_LANGUAGE = 'Config - Language';
	private static final String CONTENT_RECORD_TYPE_CONFIG_PORTAL = 'Config - Portal';
	private static final String CONTENT_RECORD_TYPE_CONFIG_RECOGNITION = 'Config - Recognition';
	private static final String CONTENT_RECORD_TYPE_CONFIG_SEARCH = 'Config - Search';
	private static final String CONTENT_RECORD_TYPE_CONFIG_STOCK = 'Config - Stock Ticker';
	private static final String CONTENT_RECORD_TYPE_CONFIG_POLL = 'Intranet Poll';
	private static final String CONTENT_RECORD_TYPE_BANNER = 'Intranet Banner';
	private static final String CONTENT_RECORD_TYPE_ABOUT_US = 'About Us RT';
	private static final String CONTENT_RECORD_TYPE_TEAM = 'Team Page RT';
	private static final String CONTENT_RECORD_TYPE_SUB_TEAM = 'Sub Team RT';
	private static final String CONTENT_RECORD_TYPE_TEAM_MEMBER = 'Team Member RT';
	private static final String CONTENT_RECORD_TYPE_CMS_PAGE = 'Intranet CMS Pages';

	public IntranetTestDataBuilder()
	{
		this.contentPages = new List<Intranet_Content__c>();
		initializeDefaultData();
	}

	// BEGIN: Intranet Content Page Builders
	public IntranetTestDataBuilder withBanner()
	{
		Intranet_Content__c page = IntranetTestUtility.createIntranetContent(CONTENT_RECORD_TYPE_BANNER, '', 'Test Banner', false);
		this.contentPages.add(page);
		return this;
	}

	public IntranetTestDataBuilder withAboutUs()
	{
		Intranet_Content__c page = IntranetTestUtility.createIntranetContent(CONTENT_RECORD_TYPE_ABOUT_US, 'Content', 'Test About Us', false);
		this.contentPages.add(page);
		return this;
	}
	
	public IntranetTestDataBuilder withTeamPage()
	{
		return withTeamPage(false, false, false);
	}

	public IntranetTestDataBuilder withTeamPage(Boolean hasCalendar, Boolean hasChatter, Boolean hasResourceLibrary)
	{
		Intranet_Content__c page = IntranetTestUtility.createIntranetContent(CONTENT_RECORD_TYPE_TEAM, 'Content', 'Test Team Page', false);
		page.Template__c = 'Team';
		Integer sequence = 0;
		if(hasCalendar)
		{
			page.Show_Calendar__c = true;
			page.Team_Calendar_Name__c = 'Test Team Calendar';
			++sequence;
			page.Calendar_Sequence__c = String.valueOf(sequence);
		}

		if(hasChatter)
		{
			page.Show_Chatter_Feed__c = true;
			++sequence;
			page.Chatter_Feed_Sequence__c = String.valueOf(sequence);
			this.chatterGroup = IntranetTestUtility.createGroup(false);
		}

		if(hasResourceLibrary)
		{
			page.Show_Resource_Library__c = true;
			++sequence;
			page.Resource_Library_Sequence__c = String.valueOf(sequence);
		}
		this.contentPages.add(page);
		return this;
	}

	public IntranetTestDataBuilder withSubTeamPage()
	{
		Intranet_Content__c page = IntranetTestUtility.createIntranetContent(CONTENT_RECORD_TYPE_SUB_TEAM, 'Content', 'Test Sub Team Page', false);
		this.contentPages.add(page);
		return this;
	}

	public IntranetTestDataBuilder withTeamMember()
	{
		Intranet_Content__c page = IntranetTestUtility.createIntranetContent(CONTENT_RECORD_TYPE_TEAM_MEMBER, 'Content', 'Test Team Member Page', false);
		this.contentPages.add(page);
		return this;
	}

	public IntranetTestDataBuilder withCMSPage(Boolean showInHeader, String template)
	{
		Intranet_Content__c page = IntranetTestUtility.createIntranetContent(CONTENT_RECORD_TYPE_CMS_PAGE, null, 'Test CMS Page', false);
		page.Show_In_Header_Menu__c  = showInHeader;
		page.Template__c = template;
		page.Status__c = 'Published';
		this.contentPages.add(page);
		return this;
	}
	// END: Intranet Content Page Builders

	// BEGIN: initializeDefaultData()
	private void initializeDefaultData()
	{
		this.contentBucket = IntranetTestUtility.createContentBucket('Test Bucket', CONTENT_BUCKET_VIEWERS, CONTENT_BUCKET_ADMINS, false);
		this.tag = IntranetTestUtility.createTag(CONTENT_NAME, false);

		// Build Configuration Data
		this.contentConfig = new List<Intranet_Content__c>();
		for(String name : portalConfigEntries.keySet())
		{
			Intranet_Content__c config = IntranetTestUtility.createIntranetConfig(false, name, portalConfigEntries.get(name), CONTENT_RECORD_TYPE_CONFIG_PORTAL);
			this.contentConfig.add(config);
		}

		for(String name : searchConfigEntries.keySet())
		{
			Intranet_Content__c config = IntranetTestUtility.createIntranetConfig(false, name, searchConfigEntries.get(name), CONTENT_RECORD_TYPE_CONFIG_SEARCH);
			this.contentConfig.add(config);
		}

		for(String name : langConfigEntries.keySet())
		{
			Intranet_Content__c config = IntranetTestUtility.createIntranetConfig(false, name, langConfigEntries.get(name), CONTENT_RECORD_TYPE_CONFIG_LANGUAGE);
			config.Language_Default__c = true;
			this.contentConfig.add(config);
		}

		for(String name : pollConfigEntries.keySet())
		{
			Intranet_Content__c config = IntranetTestUtility.createIntranetConfig(false, name, pollConfigEntries.get(name), CONTENT_RECORD_TYPE_CONFIG_POLL);
			this.contentConfig.add(config);
		}

		for(String name : recogConfigEtnries.keySet())
		{
			Intranet_Content__c config = IntranetTestUtility.createIntranetConfig(false, name, recogConfigEtnries.get(name), CONTENT_RECORD_TYPE_CONFIG_RECOGNITION);
			this.contentConfig.add(config);
		}

		for(String name : stockConfigEntries.keySet())
		{
			Intranet_Content__c config = IntranetTestUtility.createIntranetConfig(false, name, stockConfigEntries.get(name), CONTENT_RECORD_TYPE_CONFIG_STOCK);
			this.contentConfig.add(config);
		}
	}
	// END: initializeDefaultData()

	// BEGIN: buildParentChildMapping()
	private void buildParentChildMapping(Intranet_Content__c parent, Intranet_Content__c child)
	{

	}
	// END: buildParentChildMapping()

	// BEGIN: build()
	// All DML is peformed in this method
	public void build()
	{
		// Insert Content Config
		//insert this.contentConfig;

		// Insert Content Bucket
		insert this.contentBucket;

		// Insert Tag
		insert this.tag;

		// Assign Content Bucket to each Content Page
		for(Intranet_Content__c ic : this.contentPages)
		{
			ic.Content_Bucket__c = contentBucket.Id;
		}

		List<Intranet_Content__c> allContent = new List<Intranet_Content__c>();
		allContent.addAll(this.contentConfig);
		allContent.addAll(this.contentPages);
		insert allContent;

		// Create a version, attachment, and tag for each content page
		List<Intranet_Content_Version__c> versions = new List<Intranet_Content_Version__c>();
		List<Attachment> attachments = new List<Attachment>();
		List<Intranet_Content_Tags__c> contentTags = new List<Intranet_Content_Tags__c>();
		for(Intranet_Content__c ic : this.contentPages)
		{
			Intranet_Content_Version__c version = IntranetTestUtility.createContentVersion(ic.Id, false);
			version.Primary_Record__c = true;
			versions.add(version);

			Attachment attachment = IntranetTestUtility.createAttachment(false, ic.Id);
			attachments.add(attachment);

			Intranet_Content_Tags__c contentTag = IntranetTestUtility.createContentTag(ic.Id, this.tag.Id, false);
			contentTags.add(contentTag);
		}

		insert versions;
		insert attachments;
		insert contentTags;

		// begin inserting conditionals
		if(this.chatterGroup != null) insert this.chatterGroup;
	}
	// END: build()

	// BEGIN: buildDefaultMenu()
	public static void buildDefaultMenu()
	{
		String HOME = 'Home';
		String OUR_BRANDS = 'Our Brands';
		String OUR_TEAMS = 'Our Teams';
		String OUR_COMMUNITY = 'Our Community';
		String CHATTER = 'Chatter';
		String THE_HUB_TEAM = 'The Hub Team';
		String DOCUMENT_DIRECTORY = 'Document Directory';
				
		// Buckets
		Intranet_Content_Buckets__c ourBrandsBucket = IntranetTestUtility.createContentBucket(OUR_BRANDS, 'All Internal Users - Default', 'ADESA Brand Admins;AFC Brand Admins;AutoVin Brand Admins;Enterprise Optimization Admins;IAA Brand Admins;Intranet Content Admins;Intranet System Admins', false);
		Intranet_Content_Buckets__c homeBucket = IntranetTestUtility.createContentBucket(HOME, 'All Internal Users - Default;Intranet All Users', 'Intranet Content Admins;Intranet System Admins', false);
		Intranet_Content_Buckets__c ourCommunityBucket = IntranetTestUtility.createContentBucket(OUR_COMMUNITY, 'All Internal Users - Default', 'Intranet Content Admins;Intranet System Admins', false);
		Intranet_Content_Buckets__c theHubBucket = IntranetTestUtility.createContentBucket(THE_HUB_TEAM, 'All Internal Users - Default', 'ADESA Brand Admins;Intranet Content Admins;Intranet System Admins', false);
		Intranet_Content_Buckets__c configBucket = IntranetTestUtility.createContentBucket('Config Content', 'Intranet All Users', 'Intranet Content Admins;Intranet System Admins', false);
		
		insert new List<Intranet_Content_Buckets__c>{ ourBrandsBucket, homeBucket, ourCommunityBucket, theHubBucket, configBucket };
		
		// Language Config
		Intranet_Content__c config = IntranetTestUtility.createIntranetConfig(false, 'en_US', 'English', CONTENT_RECORD_TYPE_CONFIG_LANGUAGE);
		config.Language_Default__c = true;
		config.Content_Bucket__c = configBucket.Id;

		// CMS Pages
		Intranet_Content__c homePage = IntranetTestUtility.createIntranetContent(CONTENT_RECORD_TYPE_CMS_PAGE, null, HOME, false);
		homePage.Show_In_Header_Menu__c  = true;
		homePage.Template__c = HOME;
		homePage.Status__c = 'Published';
		homePage.Sequence__c = '1';
		homePage.Content_Bucket__c = homeBucket.Id;

		Intranet_Content__c docPage = IntranetTestUtility.createIntranetContent(CONTENT_RECORD_TYPE_CMS_PAGE, null, DOCUMENT_DIRECTORY, false);
		docPage.Show_In_Header_Menu__c  = true;
		docPage.Template__c = DOCUMENT_DIRECTORY;
		docPage.Status__c = 'Published';
		docPage.Sequence__c = '4';
		docPage.Content_Bucket__c = configBucket.Id;

		Intranet_Content__c ourBrandsPage = IntranetTestUtility.createIntranetContent(CONTENT_RECORD_TYPE_CMS_PAGE, null, OUR_BRANDS, false);
		ourBrandsPage.Show_In_Header_Menu__c  = true;
		ourBrandsPage.Template__c = 'Brands Landing Page';
		ourBrandsPage.Status__c = 'Published';
		ourBrandsPage.Sequence__c = '1';
		ourBrandsPage.Content_Bucket__c = ourBrandsBucket.Id;

		Intranet_Content__c ourTeamsPage = IntranetTestUtility.createIntranetContent(CONTENT_RECORD_TYPE_CMS_PAGE, null, OUR_TEAMS, false);
		ourTeamsPage.Show_In_Header_Menu__c  = true;
		ourTeamsPage.Skip_Menu_Link__c = true;
		ourTeamsPage.Status__c = 'Published';
		ourTeamsPage.Sequence__c = '3';
		ourTeamsPage.Content_Bucket__c = homeBucket.Id;

		Intranet_Content__c ourCommunityPage = IntranetTestUtility.createIntranetContent(CONTENT_RECORD_TYPE_CMS_PAGE, null, OUR_COMMUNITY, false);
		ourCommunityPage.Show_In_Header_Menu__c  = true;
		ourCommunityPage.Template__c = 'Team';
		ourCommunityPage.Status__c = 'Published';
		ourCommunityPage.Sequence__c = '4';
		ourCommunityPage.Content_Bucket__c = ourCommunityBucket.Id;

		Intranet_Content__c chatterPage = IntranetTestUtility.createIntranetContent(CONTENT_RECORD_TYPE_CMS_PAGE, null, CHATTER, false);
		chatterPage.Show_In_Header_Menu__c  = true;
		chatterPage.Template__c = 'Chatter';
		chatterPage.Status__c = 'Published';
		chatterPage.Sequence__c = '5';
		chatterPage.Content_Bucket__c = theHubBucket.Id;

		Intranet_Content__c theHubCmsPage = IntranetTestUtility.createIntranetContent(CONTENT_RECORD_TYPE_CMS_PAGE, null, THE_HUB_TEAM, false);
		theHubCmsPage.Show_In_Header_Menu__c  = true;
		theHubCmsPage.Template__c = 'Team';
		theHubCmsPage.Status__c = 'Published';
		theHubCmsPage.Sequence__c = '10';
		theHubCmsPage.Content_Bucket__c = theHubBucket.Id;

		// Team Page
		Intranet_Content__c theHubTeamPage = IntranetTestUtility.createIntranetContent(CONTENT_RECORD_TYPE_TEAM, 'Content', THE_HUB_TEAM, false);
		theHubTeamPage.Template__c = 'Team';
		theHubTeamPage.Status__c = 'Published';
		theHubTeamPage.Sequence__c = '1';
		theHubTeamPage.Content_Bucket__c = theHubBucket.Id;

		insert new List<Intranet_Content__c>{ config, homePage, docPage, ourBrandsPage, ourTeamsPage, ourCommunityPage, chatterPage, theHubCmsPage, theHubTeamPage };

		// Versions
		Intranet_Content_Version__c homeVersion = IntranetTestUtility.createContentVersion(homePage.Id, false);
		homeVersion.isPublished__c = true;
		homeVersion.Primary_Record__c = true;
		homeVersion.Name = HOME;

		Intranet_Content_Version__c docVersion = IntranetTestUtility.createContentVersion(docPage.Id, false);
		docVersion.isPublished__c = true;
		docVersion.Primary_Record__c = true;
		docVersion.Name = DOCUMENT_DIRECTORY;

		Intranet_Content_Version__c ourBrandsVersion = IntranetTestUtility.createContentVersion(ourBrandsPage.Id, false);
		ourBrandsVersion.isPublished__c = true;
		ourBrandsVersion.Primary_Record__c = true;
		ourBrandsVersion.Name = OUR_BRANDS;

		Intranet_Content_Version__c ourTeamsVersion = IntranetTestUtility.createContentVersion(ourTeamsPage.Id, false);
		ourTeamsVersion.isPublished__c = true;
		ourTeamsVersion.Primary_Record__c = true;
		ourTeamsVersion.Name = OUR_TEAMS;

		Intranet_Content_Version__c ourCommunityVersion = IntranetTestUtility.createContentVersion(ourCommunityPage.Id, false);
		ourCommunityVersion.isPublished__c = true;
		ourCommunityVersion.Primary_Record__c = true;
		ourCommunityVersion.Name = OUR_COMMUNITY;

		Intranet_Content_Version__c chatterVersion = IntranetTestUtility.createContentVersion(chatterPage.Id, false);
		chatterVersion.isPublished__c = true;
		chatterVersion.Primary_Record__c = true;
		chatterVersion.Name = CHATTER;

		Intranet_Content_Version__c theHubCmsVersion = IntranetTestUtility.createContentVersion(theHubCmsPage.Id, false);
		theHubCmsVersion.isPublished__c = true;
		theHubCmsVersion.Primary_Record__c = true;
		theHubCmsVersion.Name = THE_HUB_TEAM;

		Intranet_Content_Version__c theHubPageVersion = IntranetTestUtility.createContentVersion(theHubTeamPage.Id, false);
		theHubPageVersion.isPublished__c = true;
		theHubPageVersion.Primary_Record__c = true;
		theHubPageVersion.Name = THE_HUB_TEAM;

		insert new List<Intranet_Content_Version__c>{ homeVersion, docVersion, ourBrandsVersion, ourTeamsVersion, ourCommunityVersion, chatterVersion, theHubCmsVersion, theHubPageVersion };

		// Create Parent/Child pages
		theHubTeamPage.Parent__c = theHubCmsPage.Id;
		theHubCmsPage.Parent__c = ourTeamsPage.Id;

		update new List<Intranet_Content__c>{ theHubTeamPage, theHubCmsPage };
	}
	// END: buildDefaultMenu()
	
}