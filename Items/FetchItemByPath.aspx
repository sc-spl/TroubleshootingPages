<%@ Page language="c#" %>
<!DOCTYPE html>
<html>
  <head>
    <title></title>
  </head>
  <body>
    <script runat="server">
        protected void Page_Load(object sender, EventArgs e){
            string itemPath = "768507F9-6AAF-4FDE-B19C-352DF64C58DC";
            string databaseName = "master";
            var database = Sitecore.Data.Database.GetDatabase(databaseName);
            var item = database.GetItem(itemPath);
            
            Response.Write("Item is null: " +(item == null));
        }
    </script>
  </body>
</html>
