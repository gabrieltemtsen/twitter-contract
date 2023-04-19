// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract Twitter {

    //Tweet struct that contains the types in a Tweet
    struct Tweet {
        uint tweetId;
        address author;
        string content;
        uint createdAt;
    }
    
     //Message struct that contains the types in a Message
    struct Message {
        uint messageId;
        string content;
        address from;
        address to;
    }
    //Poll struct that contains the types in a struct
    struct Poll {
        uint pollId;
        string content;
        bool[] results;
        address[] voters;
    }
    
     //User struct that contains the types and data of the User
    struct User {
        address wallet;
        string name;
        uint[] userTweets;
        address[] following;
        address[] followers;
        uint[] userPolls;
        mapping(address => Message[]) conversations; // stores and retrieves messages
    }
    mapping(uint => Poll) public polls; //stores and retrieve polls
    mapping(address => User) public users; // stores and retrieves users
    mapping(uint => Tweet) public tweets; // stores and retrieves tweets

    //idCounters
    uint256 public nextTweetId;
    uint256 public nextMessageId;
    uint256 public nextPollId;
   

    //create an account
    /// @param _name string containing the name of the user
    function registerAccount(string calldata _name) external alreadyRegistered(msg.sender) {
        require(bytes(_name).length > 0, "Name cannot be an empty string");
        User storage user = users[msg.sender];
        user.name = _name;
        user.wallet = msg.sender;
    }
    /// @param _content The body of the tweet
    function postTweet(string calldata _content) external accountExists(msg.sender) { 
        Tweet storage tweet = tweets[nextTweetId];
        tweet.tweetId = nextTweetId;
        tweet.author = msg.sender; 
        tweet.content = _content;
        tweet.createdAt = block.timestamp;
        User storage user = users[msg.sender];
        user.userTweets.push(nextTweetId);
        nextTweetId++;
    }
    /// @param _user An address of the user
    /// @return The Tweets of the user
    function readTweets(address _user) view external returns(Tweet[] memory) {
        uint[]memory userTweetIds = users[_user].userTweets;
        Tweet[] memory userTweets = new Tweet[](userTweetIds.length);
        for(uint i = 0; i < userTweetIds.length; i++) {
            userTweets[i] = tweets[userTweetIds[i]];
            
        }
        return userTweets;
    }
   
    /// @param _user An address of the user
    function followUser(address _user) external accountExists(msg.sender) onlyFollowOthers(_user) onlyFollowOnce(_user) {
        User storage user_followed = users[msg.sender];
        user_followed.following.push(_user);
        User storage user_gained_follower = users[_user];
        user_gained_follower.followers.push(msg.sender);

    }
    /// @param _user An address of the user
    //Function to unfollow user based on the parameter _address to be unfollowed
    function unFollowUser(address _user) external accountExists(msg.sender) returns(bool) {
        User storage currentUser = users[msg.sender];
        User storage user_looses_follower = users[_user];
        address[] storage following = currentUser.following;
        address[] storage followers = user_looses_follower.followers;

        for(uint i = 0; i < following.length; i++) {
            if(following[i] == _user){
                following[i] = following[following.length - 1];
                following.pop(); 
            }
        }
          for(uint i = 0; i < followers.length; i++) {
            if(followers[i] == msg.sender){
                followers[i] = followers[followers.length - 1];
                followers.pop();
            }
            
        }        
        return true;
    }
    /// @return The state of the function
    //This Function Unfollows all users the caller follows
    function unFollowAllUsers() external accountExists(msg.sender) returns(bool) { 
        User storage user = users[msg.sender];
        address[] storage followers = user.followers;
        for(uint i = 0; i < followers.length; i++) {
            address follower = followers[i];
            User storage followerUser = users[follower];
            address[] storage following = followerUser.following;
            for(uint j = 0; j < following.length; j++) {
                if(following[j] == msg.sender){
                    following[j] = following[following.length - 1];
                    following.pop();
                    break;
                }
            }
        }
    delete user.following;
    return true;
    }
    /// @return The Addresses of Users following the caller
    function getFollowing() external view returns(address[] memory)  {
        return users[msg.sender].following;
    }
    /// @return The Addresses of the caller's followers
    function getFollowers() external view returns(address[] memory) {
         return users[msg.sender].followers;

    }
    /// @return Array of all Tweets
    function getTweetFeed() view external returns(Tweet[] memory) {
        Tweet[] memory tweetFeed = new Tweet[](nextTweetId);
        for(uint i = 0; i < nextTweetId; i++) {
            tweetFeed[i] = tweets[i];
        }
        return tweetFeed;
    }

    
     /// @param _recipient An address of the user
     /// @param _content content of the message to be sent
    function sendMessage(address _recipient, string calldata _content) accountExists(msg.sender) external {
        User storage sender = users[msg.sender];
        User storage receiver = users[_recipient];
        Message memory newMessage = Message(nextMessageId, _content, msg.sender, _recipient);  
        sender.conversations[_recipient].push(newMessage); 
        receiver.conversations[msg.sender].push(newMessage);
        nextMessageId++;

    }
     /// @param _user An address of the user
    /// @return The Content of the conversation between users
    function getConversationWithUser(address _user) external accountExists(msg.sender) view returns(Message[] memory) {
        User storage user = users[msg.sender];
        Message[] memory convo = user.conversations[_user];
        return convo;
    }
     /// @param _content poll content
    /// @return The state of function(true if successful)
    function createBinaryPoll(string calldata _content) external accountExists(msg.sender) returns (bool) {
         require(bytes(_content).length > 0, "Content cannot be an empty string");
        User storage user = users[msg.sender];
        bool[] memory results;
        address[] memory voters;
        Poll memory newPoll = Poll(nextPollId, _content, results, voters);
        polls[nextPollId] = newPoll;
        user.userPolls.push(nextPollId);
        nextPollId++;
        return true;
    }
     /// @param _vote boolean value to vote on a pol
     /// @param _pollId The Id of the poll to vote on
    function voteOnPoll(bool _vote, uint _pollId) accountExists(msg.sender) external {
        Poll storage activePoll = polls[_pollId];
        require(activePoll.pollId == _pollId, "Poll does not exist");
        require(activePoll.voters.length == 0 || !contains(activePoll.voters, msg.sender), "User has already voted on this poll");
        activePoll.voters.push(msg.sender);
        activePoll.results.push(_vote);
    }
    //check if an element is in an array
    function contains(address[] storage array, address element) internal view returns (bool) {
        for (uint i = 0; i < array.length; i++) {
            if (array[i] == element) {
                return true;
            }
        }
       return false;
    }
    /// @param _pollId The uint PostId of the poll
    /// @return The results of the poll
    function getPollResults(uint _pollId) external view returns (Poll memory) {
        return polls[_pollId];
    }

     //check if user does not exist
    modifier accountExists(address _user) {
       User storage user = users[_user];
       require(bytes(user.name).length != 0, "This wallet does not belong to any account");
        _;
    }
    //check if user has registered
     modifier alreadyRegistered(address _user) {
       User storage user = users[_user];
       require(user.wallet != _user, "You have registered already");
        _;
    }
    //check if users wants to follow his/herself
    modifier onlyFollowOthers(address _user) {
        require(msg.sender != _user, "You cannot follow yourself");
        _;
    }
    //check if user has followed a particular user
     modifier onlyFollowOnce(address _user) {
        User storage currentUser = users[msg.sender];
        bool exists = false;
        address[] storage following = currentUser.following;
        for(uint i = 0; i < following.length; i++) {
            if(following[i] == _user){
                exists = true;
            }
        }
        require(!exists, "You are following the User already");
        _;  
        

        
    }
}