<%@ Page Async="true" Language="C#" AutoEventWireup="true" %>

<%@ Import Namespace="System.Net.Http" %>
<%@ Import Namespace="System.Security.Cryptography.X509Certificates" %>
<%@ Import Namespace="Sitecore.Xdb.ReferenceData.Client.Xmgmt" %>
<%@ Assembly Name="System.Net.Http, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a" %>
<%@ Import Namespace="System.Threading.Tasks" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        <div style="border-style: solid; border-width: 2px; padding:5px 5px 5px 5px;">
            <asp:Label ID="CollectionResult" runat="server" Text=""></asp:Label>
        </div>
        <p>
            <asp:Label ID="Label1" runat="server" Text="Label">Is Azure</asp:Label>
        </p>
        <p>
            <asp:CheckBox ID="IsAzureCheckBox" runat="server"></asp:CheckBox>
        </p>
        <p>
            <asp:Label ID="Label2" runat="server" Text="Label">Endpoint URL</asp:Label>
        </p>
        <p>
            <asp:TextBox ID="EndpointTbx" Width="400px" runat="server"></asp:TextBox>
        </p>
        <p>
            <asp:Label ID="Label3" runat="server" Text="Label">Thumbprint</asp:Label>
        </p>
        <p>
            <asp:TextBox ID="ThumbprintTbx" Width="400px" runat="server"></asp:TextBox>
        </p>
        <p>
            <asp:Button ID="TestButton" runat="server" Text="Test Connection" OnClick="TestButton_Click" />
        </p>
        <p>
            <asp:Label ID="ResultLbl" runat="server" Text=""></asp:Label>
        </p>
        <div>
            <script runat="server">
                protected async void Page_Load()
                {
                    StringBuilder sb = new StringBuilder();

                    sb.Append("<p><b>Test for connection strings:</b></p>");

                    var appsettingValue = AppSettingsResolver.Resolve("AllowInvalidClientCertificates");
                    if (appsettingValue == null)
                    {
                        sb.Append("<p>AllowInvalidClientCertificates is not set</p>");
                    }
                    else
                    {
                        sb.Append("<p>AllowInvalidClientCertificates is ");
                        sb.Append(appsettingValue);
                        sb.Append("</p>");
                    }

                    var xConnectURLConnectionString = ConfigurationManager.ConnectionStrings["xdb.referencedata.client"];
                    var certificateConnectionString = ConfigurationManager.ConnectionStrings["xdb.referencedata.client.certificate"];

                    string xConnectURL;
                    string certificate;

                    if (xConnectURLConnectionString == null || xConnectURLConnectionString.ConnectionString == null)
                    {
                        sb.Append("<p>xConnectURL is null</p>");
                        return;
                    }
                    else
                    {
                        xConnectURL = xConnectURLConnectionString.ConnectionString;
                        sb.Append("<p>xConnect URL is ");
                        sb.Append(xConnectURL);
                        sb.Append("</p>");
                    }

                    if (certificateConnectionString == null || certificateConnectionString.ConnectionString == null)
                    {
                        sb.Append("<p>xConnect certificate is null</p>");
                        return;
                    }
                    else
                    {
                        certificate = certificateConnectionString.ConnectionString;
                        sb.Append("<p>xConnect certificate is ");
                        sb.Append(certificate);
                        sb.Append("</p>");
                    }

                    try
                    {
                        var modifier = new Sitecore.Xdb.Common.Web.CertificateHttpClientHandlerModifier(certificate, appsettingValue);
                        var handler = new HttpClientHandler();
                        modifier.Process(handler);
                        var result = await SendRequest(handler, xConnectURL).ConfigureAwait(false);
                        sb.Append("<p>Response status code: ");
                        sb.Append(result.StatusCode);
                        sb.Append("</p>");
                    }
                    catch (Exception e)
                    {
                        sb.Append("<p>Error happened:");
                        sb.Append(e.Message);
                        sb.Append("</p>");
                        sb.Append("<p>");
                        sb.Append(e.StackTrace);
                        sb.Append("</p>");
                    }

                    CollectionResult.Text = sb.ToString();
                }

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
                    var url = EndpointTbx.Text;
                    var isAzure = IsAzureCheckBox.Checked;

                    StoreLocation store = isAzure ? StoreLocation.CurrentUser : StoreLocation.LocalMachine;

                    var x509CertificateWithoutCheck = FindClientCertificate("My", store, X509FindType.FindByThumbprint, thumbprint, true);
                    var x509CertificateWithCheck = FindClientCertificate("My", store, X509FindType.FindByThumbprint, thumbprint, false);

                    if (x509CertificateWithoutCheck == null)
                    {
                        ResultLbl.Text = "<p>Certificate was not found even when AllowInvalidClientCertificates = true</p>";
                        return;
                    }

                    if (x509CertificateWithCheck == null)
                    {
                        ResultLbl.Text = "<p>Certificate was not found when AllowInvalidClientCertificates = false, however was found when AllowInvalidClientCertificates = true</p>";
                    }

                    var result = await SendRequest(x509CertificateWithoutCheck, url).ConfigureAwait(false);
                    ResultLbl.Text += "<p>Response status code: " + result.StatusCode + "</p>";
                }

                private async Task<HttpResponseMessage> SendRequest(X509Certificate certificate, string url)
                {
                    var handler = new HttpClientHandler();
                    handler.ClientCertificateOptions = ClientCertificateOption.Manual;
                    handler.ClientCertificates.Add(certificate);
                    return await SendRequest(handler, url).ConfigureAwait(false);
                }

                private async Task<HttpResponseMessage> SendRequest(HttpClientHandler clientHandler, string url)
                {
                    using (clientHandler)
                    {
                        var client = new HttpClient(clientHandler, true);

                        using (var requestMessage = new HttpRequestMessage(HttpMethod.Get, new Uri(url)))
                        {
                            return await client.SendAsync(requestMessage).ConfigureAwait(false);
                        }
                    }
                }
        </script>
        </div>
    </form>
</body>
</html>
