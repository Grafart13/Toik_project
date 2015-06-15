package org.gradle;

import java.net.URI;
import java.util.LinkedList;
import com.atlassian.jira.rest.client.api.JiraRestClient;
import com.atlassian.jira.rest.client.api.JiraRestClientFactory;
import com.atlassian.jira.rest.client.api.domain.BasicIssue;
import com.atlassian.jira.rest.client.api.domain.Issue;
import com.atlassian.jira.rest.client.api.domain.IssueType;
import com.atlassian.jira.rest.client.api.domain.input.IssueInput;
import com.atlassian.jira.rest.client.api.domain.input.IssueInputBuilder;
import com.atlassian.jira.rest.client.internal.async.AsynchronousJiraRestClientFactory;

public aspect ExampleAspect {
	pointcut any_function(): execution(* *(..));
	
	LinkedList<Exception> exceptionList = new LinkedList<Exception>();
	
	before() : any_function() {
		System.out.println("ple");
	}
	after() throwing (Exception e): any_function(){
		//
		try {
			if(!alreadyThrown(e))
			{
			exceptionOccures(e);
			URI jiraServerUri = new URI("https://issues.age.agh.edu.pl");
			JiraRestClientFactory restClientFactory = new AsynchronousJiraRestClientFactory();
			JiraRestClient restClient = restClientFactory.createWithBasicHttpAuthentication(jiraServerUri, "ziewiec", "Sofobega");
			
			Iterable<IssueType> issueTypes = restClient.getMetadataClient().getIssueTypes().claim();
			IssueType chosenIssueType = null;
			for(IssueType issueType : issueTypes){
				chosenIssueType = issueType;
				if(issueType.getName().contains("Task") && !issueType.isSubtask()){
					break;
				}
			}
			
			//populate issue fields
			IssueInputBuilder issueBuilder = new IssueInputBuilder("TEST", chosenIssueType.getId());//IssueInputBuilder("TEST", 0);
			issueBuilder.setSummary("Exception occured : " + e.getMessage());
			
			String stackTraceString = new String();
			for(StackTraceElement stackTraceElem: e.getStackTrace()){
				//System.out.println(stackTraceElem.toString());
				stackTraceString += stackTraceElem.toString();
				stackTraceString += "\n";
			}
			issueBuilder.setDescription(stackTraceString);
			issueBuilder.setProjectKey("TEST");
			
			//System.out.println(stackTraceString);

			//create the issue
			//NullProgressMonitor pm = new NullProgressMonitor();
			IssueInput issueInput = issueBuilder.build();
			BasicIssue bIssue = restClient.getIssueClient().createIssue(issueInput).claim();

			//get the newly created issue
			Issue jIssue = restClient.getIssueClient().getIssue(bIssue.getKey()).claim();
			}
		} catch (Exception e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}
	}

	private void exceptionOccures(Exception e) {
		exceptionList.add(e);
		
	}

	private boolean alreadyThrown(Exception e) {
		return exceptionList.contains(e);
	}

}
