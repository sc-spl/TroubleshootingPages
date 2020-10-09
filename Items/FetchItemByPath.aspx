<%@ Page Language="c#" %>

<!DOCTYPE html>
<html>
<head>
    <title></title>
</head>
<body>
    <script runat="server">
        protected void Page_Load(object sender, EventArgs e)
        {
            string itemPath = "768507F9-6AAF-4FDE-B19C-352DF64C58DC";
            string databaseName = "master";
            Response.Write("<p>Retrieving for user " + (Sitecore.Context.User.LocalName) + "</p>");
            CheckItem(itemPath, databaseName);

            Response.Write("<p>Retrieving with security disabler </p>");
            using (new Sitecore.SecurityModel.SecurityDisabler())
            {
                CheckItem(itemPath, databaseName);
            }
        }

        private void CheckItem(string itemPath, string databaseName)
        {
            var database = Sitecore.Data.Database.GetDatabase(databaseName);
            var item = database.GetItem(itemPath);

            Response.Write("<p>Item is null: " + (item == null) + "</p>");
        }
    </script>
</body>
</html>
