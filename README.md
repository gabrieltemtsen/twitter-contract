# Twitter Smart Contract
The Twitter contract is a solidity smart contract that offers the fundamental Twitter functions, such as signing up, posting tweets, following and unfollowing accounts, texting friends, and creating polls.
# Major Features of The Twitter Smart Contract
1. Unfollowing an account and Unfollowing All accounts
2. Creating Binary Polls and Voting on Binanry Polls

## Unfollowing Accounts
FI believe that, in addition to the ability to unfollow individual profiles on the Twittwer platform, providing the ability to unfollow all accounts simultaneously would be beneficial for some users who might want to resume using their social media accounts. Additionally, to backup this function so users don't unfollow all profiles by accident. A confirmation prompt for a total unfollow of all of his or her followers would be included in the user interface.


### How the Unfollowing Accounts Function works
1. From the function's caller, msg.sender, a User is created.
2. The user is instantiated and used to retrieve all of the followers and followings that are associated with him or her.
3. After calling the pop function to unfollow and remove the caller from the list of other users' followers, a for loop is used to repeatedly loop through each item in the following and followers array.
  The function produces a boolean value (True/false) that indicates if the transaction was successful or not and does not require any input.


## Creating and Voting on Binary Polls
I think this is a fantastic aspect of this decentralized Twitter idea since users can create votes whenever they want and can vote on the polls and articles they want to.

 ### How the Binary Polls work
 1. The Create Function takes ond parameter(the content ) of type string.
 2. The function returns a boolean value based on the transaction output, the function also uses a require statement to check if the content parameter is not an empty string.
 3. The function creates an instantiated user so that it can be added to the polls mapping. The poll's content and the state variable nextPollId, which will be incremented each time the function is called, are passed into the function when it is formed. The information is subsequently transferred to the polls mapping to be stored.
 4. The VoteOnPoll function takes 2 parameters (the vote boolean value & PollID). An instance of the Polls mapping is created so that the parameters can be pushed to the polls mapping
 5. The Contains Helper Function is used to check if an element exists in an array,  it was used to check if an array exists in the polls mapping so one user won't have to vote twice.
 6. The getPollResults function takes one parameter (uint _pollId) of the poll a user wants to check/see the the results of the poll and returns the array of the polls requested.
