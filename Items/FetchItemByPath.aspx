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
            Response.Write("<p><b>Retrieving for user " + (Sitecore.Context.User.Domain + "/" + Sitecore.Context.User.LocalName) + "</b></p>");
            CheckItem(itemPath, databaseName);

            Response.Write("<p><b>Retrieving with security disabler</b></p>");
            Sitecore.Data.Items.Item item;
            using (new Sitecore.SecurityModel.SecurityDisabler())
            {
                item = CheckItem(itemPath, databaseName);
            }

            Response.Write("<p><b>Retrieving the security reason</b></p>");
            var accessResult = Sitecore.Security.AccessControl.AuthorizationManager.GetAccess(item, Sitecore.Context.User, Sitecore.Security.AccessControl.AccessRight.ItemRead);
            Response.Write("<p>Permission: " + accessResult.Permission + ", Explanation:  " + accessResult.Explanation.Text + "</p>");
        }

        private Sitecore.Data.Items.Item CheckItem(string itemPath, string databaseName)
        {
            var database = Sitecore.Data.Database.GetDatabase(databaseName);
            var item = database.GetItem(itemPath);

            Response.Write("<p>Item is null: " + (item == null) + "</p>");

            return item;
        }
    </script>
</body>
</html>
