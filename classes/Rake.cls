/*
Rake.cls
Author: Sam Hart - schart@gmail.com
An Apex implementation of the Rapid Automatic Keyword Extraction (RAKE) algorithm as described 
in: Rose, S., Engel, D., Cramer, N., & Cowley, W. (2010). 
Automatic Keyword Extraction from Individual Documents.
In M. W. Berry & J. Kogan (Eds.), Text Mining: Theory and Applications: John Wiley & Sons.
Based on the Python implementation by aneesha.
https://github.com/aneesha/RAKE
*/

public with sharing class Rake {


//stopword list
public static List<String> stopWords = new String[]{'a','a\'s','able','about','above','according','accordingly','across','actually','after','afterwards','again','against','ain\'t','all','allow','allows','almost','alone',
												'along','already','also','although','always','am','among','amongst','an','and','another','any','anybody','anyhow','anyone','anything','anyway','anyways','anywhere',
												'apart','appear','appreciate','appropriate','are','aren\'t','around','as','aside','ask','asking','associated','at','available','away','awfully','b','be','became',
												'because','become','becomes','becoming','been','before','beforehand','behind','being','believe','below','beside','besides','best','better','between','beyond','both',
												'brief','but','by','c','c\'mon','c\'s','came','can','can\'t','cannot','cant','cause','causes','certain','certainly','changes','clearly','co','com','come','comes',
												'concerning','consequently','consider','considering','contain','containing','contains','corresponding','could','couldn\'t','course','currently','d','definitely',
												'described','despite','did','didn\'t','different','do','does','doesn\'t','doing','don\'t','done','down','downwards','during','e','each','edu','eg','eight','either',
												'else','elsewhere','enough','entirely','especially','et','etc','even','ever','every','everybody','everyone','everything','everywhere','ex','exactly','example','except',
												'f','far','few','fifth','first','five','followed','following','follows','for','former','formerly','forth','four','from','further','furthermore','g','get','gets','getting',
												'given','gives','go','goes','going','gone','got','gotten','greetings','h','had','hadn\'t','happens','hardly','has','hasn\'t','have','haven\'t','having','he','he\'s','hello',
												'help','hence','her','here','here\'s','hereafter','hereby','herein','hereupon','hers','herself','hi','him','himself','his','hither','hopefully','how','howbeit','however'
												,'i','i\'d','i\'ll','i\'m','i\'ve','ie','if','ignored','immediate','in','inasmuch','inc','indeed','indicate','indicated','indicates','inner','insofar','instead','into'
												,'inward','is','isn\'t','it','it\'d','it\'ll','it\'s','its','itself','j','just','k','keep','keeps','kept','know','knows','known','l','last','lately','later','latter',
												'latterly','least','less','lest','let','let\'s','like','liked','likely','little','look','looking','looks','ltd','m','mainly','many','may','maybe','me','mean','meanwhile',
												'merely','might','more','moreover','most','mostly','much','must','my','myself','n','name','namely','nd','near','nearly','necessary','need','needs','neither','never',
												'nevertheless','new','next','nine','no','nobody','non','none','noone','nor','normally','not','nothing','novel','now','nowhere','o','obviously','of','off','often','oh',
												'ok','okay','old','on','once','one','ones','only','onto','or','other','others','otherwise','ought','our','ours','ourselves','out','outside','over','overall','own','p',
												'particular','particularly','per','perhaps','placed','please','plus','possible','presumably','probably','provides','q','que','quite','qv','r','rather','rd','re','really',
												'reasonably','regarding','regardless','regards','relatively','respectively','right','s','said','same','saw','say','saying','says','second','secondly','see','seeing','seem',
												'seemed','seeming','seems','seen','self','selves','sensible','sent','serious','seriously','seven','several','shall','she','should','shouldn\'t','since','six','so','some',
												'somebody','somehow','someone','something','sometime','sometimes','somewhat','somewhere','soon','sorry','specified','specify','specifying','still','sub','such','sup','sure',
												't','t\'s','take','taken','tell','tends','th','than','thank','thanks','thanx','that','that\'s','thats','the','their','theirs','them','themselves','then','thence','there',
												'there\'s','thereafter','thereby','therefore','therein','theres','thereupon','these','they','they\'d','they\'ll','they\'re','they\'ve','think','third','this','thorough',
												'thoroughly','those','though','three','through','throughout','thru','thus','to','together','too','took','toward','towards','tried','tries','truly','try','trying','twice',
												'two','u','un','under','unfortunately','unless','unlikely','until','unto','up','upon','us','use','used','useful','uses','using','usually','uucp','v','value','various',
												'very','via','viz','vs','w','want','wants','was','wasn\'t','way','we','we\'d','we\'ll','we\'re','we\'ve','welcome','well','went','were','weren\'t','what','what\'s',
												'whatever','when','whence','whenever','where','where\'s','whereafter','whereas','whereby','wherein','whereupon','wherever','whether','which','while','whither','who',
												'who\'s','whoever','whole','whom','whose','why','will','willing','wish','with','within','without','won\'t','wonder','would','would','wouldn\'t','x','y','yes','yet',
												'you','you\'d','you\'ll','you\'re','you\'ve','your','yours','yourself','yourselves','z','zero'};

// Utility function to return a list of sentences.
// @param text The text that must be split in to sentences.
public static List<String> splitSentences(String text)
{
	text = text.replaceAll('<[/a-zAZ0-9]*>','');//strip html tags
	Pattern sentenceDelimiters = Pattern.compile('\n|\\.(?!\\d)|(?<!\\d)\\.');
	List<String> sentenceList = sentenceDelimiters.split(text);
	return sentenceList;
}

public static Pattern getStopWordRegExPattern()
{
	List<String> stopwordRegexList = new List<String>();
	Integer ix = 0;
	String patternstr = '';
	for(String word: stopWords)
	{
		string pre = ix != 0 ? '|' : ''; 
		patternstr = patternstr+pre+'(?i)\\b'+word+'\\b';
		ix++;
	}
	Pattern p = Pattern.compile(patternstr);
	return p;
}


public static List<String> generateCandidateKeywords(List<String> sentenceList, Pattern stopWordPattern)
{
	List<String> phraseList = new List<String>();
	for(String sentence: sentenceList)
	{
		List<String> tmp = stopWordPattern.split(sentence);
		for(String myPhrase: tmp)
		{
			myPhrase = myPhrase.trim().toLowerCase();
			if(!myPhrase.equals('')) phraseList.add(myPhrase);
		}
		
	}
	return phraseList;
}
// Utility function to return a list of all words that are have a length greater than a specified number of characters.
// @param text The text that must be split in to words.
// @param minWordReturnSize The minimum no of characters a word must have to be included.

public static List<String> seperateWords(String text, Integer minWordSize)
{
	Pattern splitter = Pattern.compile('[^a-zA-Z0-9_\\+\\-/]');
	List<String> words = new List<String>();
	List<String> splitWords = splitter.split(text);
	for(String word: splitWords)
	{
		try
		{
			Integer x = Integer.valueOf(word);
			//leave numbers in phrase, but don't count as words, since they tend to invlate scores of their phrases
			continue;//if the string parses, we don't want to use it as a word
		}catch (Exception e)
		{
			//do nothing here :)
		}
		
		String currWord = word.trim().toLowerCase();
		if(currWord.length() > minWordSize && !currWord.equals('') && currWord != null)
		{
			words.add(currWord);
		}
		
	}
	return words;
}


public static Map<String, Double> calculateWordScores(List<String> phraselist)
{
	Map<String, Integer> wordFreq = new Map<String, Integer>();
	Map<String, Integer> wordDegree = new Map<String, Integer>();
	
	for(String phrse: phraselist)
	{
		List<String> wordlist = seperateWords(phrse, 3);
		Integer wordlistlength = wordlist.size();
		Integer wordlistdegree = wordlistlength - 1;
			for(String word: wordlist)
			{
				Integer fv = wordFreq.get(word);
				Integer fx = fv == null ? 1 : fv+1;
				wordFreq.put(word, fx);
				Integer dv = wordDegree.get(word);
				Integer dx = dv == null ? wordlistdegree : dv + wordlistdegree;
				wordDegree.put(word, dx);
				
			}
	}

	for(String word: wordFreq.keySet())
	{	
		Integer wd = wordDegree.get(word);
		Integer wf = wordFreq.get(word);
		wordDegree.put(word, wd+wf);
	}
	Map<String, Double> wordScores = new Map<String, Double>();
	
	for(String word: wordFreq.keySet())
	{
		Double score = (Double)wordDegree.get(word)/(Double)wordFreq.get(word);
		wordScores.put(word,score);
	}
	return wordScores;
}
	

public static List<KeyWord> generateCandidateKeywordScores(List<String> phraselist, Map<String, Double> wordScores)
{
	Map<String, Double> keywordcandidates = new Map<String, Double>();

	for(String phrs: phraselist)
	{
		List<String> wordlist = seperateWords(phrs, 3);
		Double candidatescore = 0.0;
		for(String word: wordlist)
		{
			Double score = wordScores.get(word);
			if(score == null) score = 0;
			candidatescore = candidatescore + score;
		}
		keywordcandidates.put(phrs, candidatescore);
	}
	List<KeyWord> scoredKeyWords = new List<KeyWord>();
	for(String kw: keywordcandidates.keySet())
	{
		 KeyWord temp = new KeyWord(kw, keywordcandidates.get(kw));
		 scoredKeyWords.add(temp);
	}
	return scoredKeyWords;
}

public static List<KeyWord> getScoredKeyWords(String text)
{
	Pattern p = Rake.getStopWordRegExPattern();
	//split into sentences
	List<String> sentences = Rake.splitSentences(text);
	List<String> phraseList = Rake.generateCandidateKeywords(sentences, p);
	Map<String, Double>wordscores = Rake.calculateWordScores(phraseList);
	List<KeyWord> templ = Rake.generateCandidateKeywordScores(phraseList, wordscores);
	Integer l = Math.min(phraselist.size()/3, 10);
	List<KeyWord> Candidatescores = new List<KeyWord>();
	Integer ix = 1;
	templ.sort();
	for(Keyword k: templ)
	{
		if(ix > l)break;
		Candidatescores.add(k);
		ix++;
	}
	return Candidatescores;
}

}