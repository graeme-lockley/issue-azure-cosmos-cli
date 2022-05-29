namespace Entity;

using Azure.Identity;
using Microsoft.Azure.Cosmos;

public class Main
{
    Container container;

    public Main()
    {
        var cosmosClient = new CosmosClient("https://test2db.documents.azure.com:443/", new DefaultAzureCredential());
        Console.WriteLine("Created Cosmos Client");

        var database = cosmosClient.GetDatabase("TestDatabase");
        Console.WriteLine("Accessed TestDatabase");

        container = database.GetContainer("TestContainer");
        Console.WriteLine("Accessed TestContainer");
    }

    public Task<ItemResponse<Friend>> AttemptAddFriend(Friend friend) =>
        container.CreateItemAsync<Friend>(friend, new PartitionKey(friend.LastName));

    public Task<List<Friend>> FindFriendOnLastName(string lastName) =>
        Query($"SELECT * FROM c WHERE c.LastName = '{lastName}'");

    private async Task<List<Friend>> Query(string sqlQueryText)
    {
        QueryDefinition queryDefinition = new QueryDefinition(sqlQueryText);
        FeedIterator<Friend> queryResultSetIterator = container.GetItemQueryIterator<Friend>(queryDefinition);

        List<Friend> friends = new List<Friend>();

        while (queryResultSetIterator.HasMoreResults)
        {
            FeedResponse<Friend> currentResultSet = await queryResultSetIterator.ReadNextAsync();
            foreach (Friend friend in currentResultSet)
            {
                friends.Add(friend);
            }
        }

        return friends;
    }

}
