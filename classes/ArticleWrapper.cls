/*
ArticleWrapper.cls
Author: Sam Hart - schart@gmail.com
Provides additional methods for the Support_Article__c custom object
*/


global class ArticleWrapper implements Comparable{
	
//base object that we are 'extending'
public Support_Article__c article {get; set;}
//keyword relavance score
public Double score {get; set;}
//same as above but formatted
public Decimal formattedScore {get; set;}
//flag, set when processing Support_Article__c search results, 
//true if related to the case, false if not. Used to display associate button on vf page
public Boolean isRelated {get; set;}

//constructor
public ArticleWrapper(Support_Article__c article)
{
	this.article = article;
}

//sums up the keyword score for the support article text and sets 
//this.score and this.formatted score
public void calculateScore(List<KeyWord> keyWords)
{
	String fullText = this.article.Name+'.\n'+this.article.Article_Text__c;
	Double articleScore = 0.0;
	for(KeyWord kw: keyWords)
	{
		Double kwScore = fullText.toLowerCase().countMatches(kw.text) * kw.score;
		articleScore = articleScore + kwScore;
		this.score = articleScore;
		this.formattedScore = (Decimal.valueOf(this.score)).setScale(2);
	}
}

// compareTo method to satisfy the comparable interface
//sorts article based on score
global Integer compareTo(Object compareTo) 
{
    ArticleWrapper compareToAW = (ArticleWrapper)compareTo;
    if (this.score == compareToAW.score) return 0;
    if (this.score < compareToAW.score) return 1;
    return -1;        
}


}