Support Articles Application
================

Functional Requirements:
ABC Corporation (client) is adopting Salesforce Service Cloud. Part of their adoption requires that users have the ability to search a custom database of knowledge articles about their products when a new support case is created. A support agent should have the ability to click on a button directly from a Case record in Salesforce and be taken to a new screen where a search across the companies customized "Support Articles" is performed and results are automatically returned based on key-words present in the Case.

Input fields should be provided on the new interface where the support agent could add or alter key words that are being searched. The interface should be very simple and clean. Support agents should not need to specify which fields they are searching across, the engine should be able to return a filtered, scored and ranked list of results easily.

Support agent should be able to click on the subject of a given "Support Article" to review its contents. From the review screen, support agent should be able to easily navigate back to the results panel. From the results panel, support agent should be able to select only one Support Article from the list, and then click "Associate to Case" button. Upon clicking the button the Support Article is then added to a related records listing on the Case. Multiple Support Articles can apply to multiple cases, so a junction object should be created.

User Story:
As a user, I want to be able to easily view a list of recommended Support Articles related to a case I am working on and then associate one of those Articles to that Case because, processing cases is a time consuming task and management has ascertained that this will increase productivity and reduce the average age of a case significantly.

Deliverables:
(1) Architecture and design document
> I'm just looking for something high level. Don't go crazy with BPMN or UML diagrams unless you really want to. Do a flowchart, some pictures, a relational entity diagram. Just something that conveys how you've approached the requirements. If you'd rather throw together a PPT deck really quick, go for it.

(2) Functional application
> This doesn't have to be something that is production ready! Functional – meaning you don't have to write test coverage, don't kill yourself writing unit tests and covering every edge case. Get a working prototype that has good underlying frameworks and clean code that is easily extensible and polymorphic where applicable. Use dynamic SOQL/SOSL, use dynamic DML, use custom settings if you need to.

(3) Demonstration
> Show me what you've built. If you need a developer environment, please let me know.
> Be creative. The requirements insinuate a simple search and grid display. If you have some tricks, or you want to do it differently because you think the user experience will benefit from it, go for it!


This should entail:

    Two custom objects
    At least one Apex Class
    At least one Visualforce Page
    A custom button or link

Optional:

    Any JavaScript you wish to write or any third party JS libraries you want to use is fine.
    You can use existing code from anywhere. No limits, Google is your friend :)
