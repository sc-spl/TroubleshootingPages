<%@ Page Language="C#" AutoEventWireup="true" %>
<%@ Import namespace="Sitecore.CES.DeviceDetection" %>

<!DOCTYPE html>
<script runat="server">

    protected void Button1_Click(object sender, EventArgs e)
    {
        var userAgent = TextBox1.Text;
        ProcessUserAgent(userAgent);
    }

    protected void Page_Load()
    {
        if (!IsPostBack)
        {
            var userAgent = Request.UserAgent;
            ProcessUserAgent(userAgent);
        }
    }

    private void ProcessUserAgent(string userAgent)
    {
        var isCrawler = Boolean.Parse(DeviceDetectionManager.GetExtendedProperty(userAgent, "IsCrawler"));
        var deviceInfo = DeviceDetectionManager.GetDeviceInformation(userAgent);
        
        ListBox1.Items.Clear();
        ListBox1.Items.Add("UserAgent: " + userAgent);
        ListBox1.Items.Add("Browser: " + deviceInfo.Browser);
        ListBox1.Items.Add("IsBot: " + isCrawler);
        ListBox1.Items.Add("BrowserCanJavaScript: " + deviceInfo.BrowserCanJavaScript);
        ListBox1.Items.Add("BrowserHtml5VideoCanVideo: " + deviceInfo.BrowserHtml5VideoCanVideo);
        ListBox1.Items.Add("BrowserHtml5AudioCanAudio: " + deviceInfo.BrowserHtml5AudioCanAudio);
        ListBox1.Items.Add("CanTouchScreen: " + deviceInfo.CanTouchScreen);
        ListBox1.Items.Add("DeviceType: " + deviceInfo.DeviceType);
        ListBox1.Items.Add("DeviceModelName: " + deviceInfo.DeviceModelName);
        ListBox1.Items.Add("DeviceOperatingSystemModel: " + deviceInfo.DeviceOperatingSystemModel);
        ListBox1.Items.Add("DeviceOperatingSystemVendor: " + deviceInfo.DeviceOperatingSystemVendor);
        ListBox1.Items.Add("DeviceVendor: " + deviceInfo.DeviceVendor);
        ListBox1.Items.Add("HardwareDisplayWidth: " + deviceInfo.HardwareDisplayWidth);
        ListBox1.Items.Add("HardwareDisplayHeight: " + deviceInfo.HardwareDisplayHeight);
        ListBox1.Items.Add("DeviceIsSmartphone: " + deviceInfo.DeviceIsSmartphone);
    }
</script>


<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        <div>
            <asp:TextBox ID="TextBox1" runat="server"></asp:TextBox>
        </div>
        <p>
            <asp:Button ID="Button1" runat="server" OnClick="Button1_Click" Text="Resolve" />
        </p>
        <asp:ListBox ID="ListBox1" runat="server" Height="298px" Width="685px"></asp:ListBox>
    </form>
</body>
</html>
