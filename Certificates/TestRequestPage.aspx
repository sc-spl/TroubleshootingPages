<%@ Page Async = "true" Language="C#" AutoEventWireup="true" %>
<%@ Import Namespace="System.Net.Http" %>
<%@ Import Namespace="System.Security.Cryptography.X509Certificates" %>
<%@ Assembly Name ="System.Net.Http, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
<form id="form1" runat="server">
    <p>
        <asp:Label ID="Label1" runat="server" Text="Label">Endpoint URL</asp:Label>
    </p>
    <p>
        <asp:TextBox ID="EndpoingTbx" runat="server"></asp:TextBox>
    </p>
   
    <p>
        <asp:Button ID="TestButton" runat="server" Text="Test Connection" OnClick="TestButton_Click"/>
    </p>
    <p>
        <asp:Label ID="ResultLbl" runat="server" Text=""></asp:Label>
    </p>
    <div>
        <script runat="server">
            
            protected async void TestButton_Click(object sender, EventArgs e)
            {
                
                var url = EndpoingTbx.Text;
                var client = new HttpClient();

                using (var requestMessage = new HttpRequestMessage(HttpMethod.Get, new Uri(url)))
                {
                    var result = await client.GetAsync(url).ConfigureAwait(false);
                    ResultLbl.Text = "Response status code: " + result.StatusCode;
                }
            }
        </script>
    </div>
</form>
</body>
</html>