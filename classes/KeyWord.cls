/*
KeyWord.cls
Author: Sam Hart - schart@gmail.com
Simple class for object representing keywords that are extracted from 
Support cases
*/

global class KeyWord implements Comparable
{
	//stores the individual keyword score
	public Double score{get;set;}
	//the actual keyword
	public String text{get;set;}
	
	//constructor
	public KeyWord(String text, Double score)
	{
		this.text = text;
		this.score = score;
	}
	
	// compareTo method for sorting on the score property
	global Integer compareTo(Object compareTo) 
	{
	    KeyWord compareToKW = (KeyWord)compareTo;
	    if (this.score == compareToKW.score) return 0;
	    if (this.score < compareToKW.score) return 1;
	    return -1;        
	}

}