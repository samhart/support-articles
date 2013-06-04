/*
SupportArticleController.cls
Author: Sam Hart - schart@gmail.com
Controller for SupportArticles.page
*/

public with sharing class SupportArticleController 
{
	//List of ArticleWrapper objects relevant to the case
	public List<ArticleWrapper> articles {get;set;}
	//list of keywords which are extracted from the case text
	public List<KeyWord> keywords {get;set;}
	//for debugging
	public String debugText {get; set;}
	//flag to keep state of popup (article details) visibility
	public boolean displayPopup {get; set;}
	//flag to keep state of link to full article page visibility
	public boolean displayPopupLink {get;set;}
	//store the article text to display in popup
	public String popupText {get;set;} 
	//stores the article title
    public String popupTitle {get;set;}
    //stores a url to the full article
    public String popupHref {get;set;} 
    //the base case
    public case c {get;set;}
    
	//constructor
	public SupportArticleController()
	{
		//look up the case from the get variable
		String caseID = ApexPages.currentPage().getParameters().get('id');
		c = [SELECT subject, description, CaseNumber FROM case c WHERE c.Id = :caseID LIMIT 1];
		
		//extract keywords into List
		List<KeyWord> Candicatescores = Rake.getScoredKeyWords(c.subject +'\n'+c.description);
 		/*
		for(KeyWord kw: Candicatescores)
		{

				debugText = debugText + ' | ' + kw.text + ' = ' + kw.score;

		}
		*/
		runQuery(Candicatescores);
	}
	 
	 //method to search articles based on a list of keywords
	 //calulates the score and sets this.articles and sorts
	 //in descending order based on the calculated score
	 public void runQuery(List<KeyWord> keywords)
	 {
	 	this.keywords = keywords;
	 	try
		{
			//doing a 'left join' from Support_Article__c to Support_Article_Case_Junctions_r se we know which
			//articles are already related to the case so we can toggle the display of the associate to case button
			
			List<Support_Article__c> supportArticles = [SELECT Id, name, Article_Text__c, (SELECT Id, Case__c  FROM Support_Article_Case_Junctions__r WHERE Case__c = :this.c.Id LIMIT 1) FROM Support_Article__c];
			this.articles = new List<ArticleWrapper>();
			for(Support_Article__c article: supportArticles)
			{
				ArticleWrapper aw = new ArticleWrapper(article);
				aw.calculateScore(this.keywords);
				//we only want relevant articles (w/ kw score over 1)
				if(aw.score > 0)this.articles.add(aw);
				//if the Support_Article_Case_Juntion__c collection has an object then there is a relationship
				//between the case and the article and we don't want to display the associate to case button
				List<Support_Article_Case_Juntion__c> lc = article.Support_Article_Case_Junctions__r;
				aw.isRelated = lc.size() == 1 ? true : false;
				
			}
			//sort by kw score
			this.articles.sort();
			System.Debug('there are:'+this.articles.size() + ' articles');
		}
		catch(Exception e)
		{
			System.Debug('Error getting articles: '+e.getStackTraceString());
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error Getting Articles: '+e.getMessage()));
		}
	 }
	 
	//method run the search, called when the update button is pressed 
	public PageReference runSearch()
	{
		String kwinput = Apexpages.currentPage().getParameters().get('kwinput').trim().toLowerCase();
		String oldkwval = Apexpages.currentPage().getParameters().get('oldkwval').trim().toLowerCase();
		//if there's not an old kwval to update assume insertion of new keyword
		if(oldkwval.trim().equalsIgnoreCase('') || oldkwval == null)
		{
			for(KeyWord kw: this.keywords)
			{
				//ignore dups
				if(kw.text.equals(kwinput)) return null;
			}
			//score will be set to the highest score + 1
			//the logic here is that a user defined kw should have the highest score
			Double score = this.keywords.get(0).score + 1;
			//instantiate the new kw and add it to the list of keywords
			KeyWord k = new KeyWord(kwinput, score);
			this.keywords.add(k);
			this.keywords.sort();
		}
		else//update an existing kw
		{
			List<KeyWord> newkws = new List<KeyWord>();
			//find the keyword in the list that we are updating 
			//and update the text
			for(KeyWord kw: this.keywords)
			{
				if(kw.text.equals(oldkwval))
				{
					if(kwinput.equals('')) continue;
					kw.text = kwinput;
					
				}
				newkws.add(kw);
			}
			this.keywords = newkws;
		}
		//re-run the search with the updated keyword list
		runQuery(this.keywords);
		return null;  
	}
	
	//close the popup window
	public void closePopup() 
	{        
        displayPopup = false;    
    }     
    
    //associates an article to a support case by inserting a cross-reference object Support_Article_Case_Juntion__c(
    public void addToCase()
    {
    	try
    	{
	    	String ArticleID = Apexpages.currentPage().getParameters().get('articleID');
	    	Support_Article__c a = [SELECT Article_Text__c, name FROM Support_Article__c WHERE Id = :ArticleID LIMIT 1];
	    	Support_Article_Case_Juntion__c casearticlexref = new Support_Article_Case_Juntion__c();
	    	casearticlexref.Case__c = this.c.Id;
	    	casearticlexref.Support_Article__c = a.Id;
	    	//make a compound key which has a unique constraint so we can upsert and be assured that only 
	    	//one record for a given Support_Article__c/Case combo can be created
	    	casearticlexref.casearticlekey__c = '|'+c.Id+a.Id;
	    	upsert casearticlexref;
	    	//re-run the query to force a refresh of the results (w/o the associate button on this case)
	    	runQuery(this.keyWords);
    	}
    	catch(Exception e)
    	{
    	    System.Debug('Error sssociating article to case: '+e.getStackTraceString());
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error sssociating article to case: '+e.getMessage()));
    		
    	}
    	
    	
    }
    
    //makes Async call to get Article details and shows the popup with the details
    public void showPopup() {   
    	String ArticleID = Apexpages.currentPage().getParameters().get('articleID');
    	try
    	{
    		Support_Article__c article = [SELECT Article_Text__c, name FROM Support_Article__c WHERE Id = :ArticleID LIMIT 1];
    		
    		popupTitle = article.Name;
    		displayPopupLink = true;
    		popupHref = '/'+article.Id;
			debugText='';
    		popupText = article.Article_Text__c;
    	}
    	catch(Exception e)
    	{
    		popupText = e.getMessage();
    		popupTitle = 'Error retriving article: ';
    		displayPopupLink = false;
    		popupHref = '/';
    	}     
        displayPopup = true;    
    }

}