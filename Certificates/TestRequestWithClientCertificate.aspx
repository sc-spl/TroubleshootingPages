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
        <asp:Label ID="Label2" runat="server" Text="Label">Thumbprint</asp:Label>
    </p>
    <p>
        <asp:TextBox ID="ThumbprintTbx" runat="server"></asp:TextBox>
    </p>
    <p>
        <asp:Button ID="TestButton" runat="server" Text="Test Connection" OnClick="TestButton_Click"/>
    </p>
    <p>
        <asp:Label ID="ResultLbl" runat="server" Text=""></asp:Label>
    </p>
    <div>
        <script runat="server">
            private static X509Certificate FindClientCertificate(string storeName, StoreLocation storeLocation, X509FindType findType, object findValue, bool allowInvalidClientCertificates)
            {
                var x509Store = new X509Store(storeName, storeLocation);
                try
                {
                    x509Store.Open(OpenFlags.ReadOnly);
                    var x509Certificate2Collection = x509Store.Certificates.Find(findType, findValue, !allowInvalidClientCertificates);
                    return x509Certificate2Collection.Count > 0 ? x509Certificate2Collection[0] : null;
                }
                finally
                {
                    x509Store.Close();
                }
            }

            protected async void TestButton_Click(object sender, EventArgs e)
            {
                var thumbprint = ThumbprintTbx.Text;
                var url = EndpoingTbx.Text;

                using (var clientHandler = new HttpClientHandler())
                {
                    var x509Certificate = FindClientCertificate("My", StoreLocation.LocalMachine, X509FindType.FindByThumbprint, thumbprint, true);

                    if (x509Certificate == null)
                    {
                        ResultLbl.Text = "Certificate was not found";
                        return;
                    }

                    clientHandler.ClientCertificateOptions = ClientCertificateOption.Manual;
                    clientHandler.ClientCertificates.Add(x509Certificate);

                    var client = new HttpClient(clientHandler, true);

                    using (var requestMessage = new HttpRequestMessage(HttpMethod.Get, new Uri(url)))
                    {
                        var result = await client.SendAsync(requestMessage).ConfigureAwait(false);
                        ResultLbl.Text = "Response status code: " + result.StatusCode;
                    }
                }
            }
        </script>
    </div>
</form>
</body>
</html>