using Entity;

var main = new Main();

await main.AttemptAddFriend(new Friend("123", "Lockley", "Graeme", "Lockers"));
await main.AttemptAddFriend(new Friend("124", "Lockley", "David", null));
await main.AttemptAddFriend(new Friend("124", "Lockley", "Amanda", "Mandy"));

var family = await main.FindFriendOnLastName("Lockley");
family.ForEach(family => {
    Console.WriteLine($"- {family.ToString()}");
});
