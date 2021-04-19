// Based on Unreal TcpLink class example by Michiel 'elmuerte' Hendriks
 
class Crowd_TcpLink_Client extends TcpLink
    AlwaysLoaded;

var string TargetHost;
var int TargetPort;

var byte buffer[1024];
var int bufferLength;

event PostBeginPlay()
{
    super.PostBeginPlay();
    // Start by resolving the hostname to an IP so we can connect to it
    class'Crowd_CrowdControl_Gamemod'.static.DebugLog("[TcpLinkClient] Resolving: "$TargetHost);
    resolve(TargetHost);
}

event Resolved( IpAddr Addr )
{
    // The hostname was resolved succefully
    class'Crowd_CrowdControl_Gamemod'.static.DebugLog("[TcpLinkClient] "$TargetHost$" resolved to "$ IpAddrToString(Addr));

    // Make sure the correct remote port is set, resolving doesn't set
    // the port value of the IpAddr structure
    Addr.Port = TargetPort;
    
    class'Crowd_CrowdControl_Gamemod'.static.DebugLog("[TcpLinkClient] Bound to port: "$ BindPort());

    if (!Open(Addr))
    {
        class'Crowd_CrowdControl_Gamemod'.static.DebugLog("[TcpLinkClient] Open failed");
    }
}

event ResolveFailed()
{
    class'Crowd_CrowdControl_Gamemod'.static.DebugLog("[TcpLinkClient] Unable to resolve "$TargetHost);

    // You could retry resolving here if you have an alternative
    // remote host.
}

event Opened()
{
    LinkMode = MODE_Binary;
}

event Closed()
{
    // In this case the remote client should have automatically closed
    // the connection, because we requested it in the HTTP request.

    class'Crowd_CrowdControl_Gamemod'.static.DebugLog("[TcpLinkClient] event closed");

    // After the connection was closed we could establish a new
    // connection using the same TcpLink instance.
}

event DestructCleanUp()
{
    Close();
    Super.DestructCleanUp();
}

event Destroyed(){
    Close();
    Super.Destroyed();
}

event ErrorQuit()
{
    local byte responseData[255];

    responseData[0] = 0;
    SendBinary(1, responseData);
}


event ReceivedBinary(int Count, byte B[255])
{
    local JsonObject ParsedJson;
    local JsonObject Result;
    local int responseCode;
    local string responseText;
    local byte responseData[255];
    local int i;

    local bool hitTerminator;
    local string ReceivedText;

    for (i = 0; i < Count; i++)
    {
        buffer[bufferLength + i] = B[i];
        if (b[i] == 0)
        {
            hitTerminator = true;
            break;
        }
    }
    bufferLength += Count;

    if (!hitTerminator) return;

    for (i = 0; i < bufferLength; i++)
    {
        ReceivedText $= Chr(buffer[i]);
    }
    bufferLength = 0;

    class'Crowd_CrowdControl_Gamemod'.static.DebugLog("[TcpLinkClient] ReceivedText:: "$ReceivedText);
    ParsedJson = class'JsonObject'.static.DecodeJson(ReceivedText);
    if (ParsedJson == None) return;
    class'Crowd_CrowdControl_Gamemod'.static.DebugLog("[TcpLinkClient] Received command: "$ParsedJson.GetStringValue("code"));
    responseCode = class'Crowd_CrowdControl_Gamemod'.static.GetGameMod().ProcessCode(ParsedJson.GetStringValue("code"));

    Result = new class'JsonObject';
    Result.SetIntValue("id", ParsedJson.GetIntValue("id"));
    Result.SetIntValue("status", responseCode);
    Result.SetStringValue("message", "");
    class'Crowd_CrowdControl_Gamemod'.static.DebugLog("[TcpLinkClient] Sending command: "$class'JsonObject'.static.EncodeJson(Result));

    //Unrealscript doesn't let you have null characters in strings, so to be able to work with the SimpleTCPConnector, We have to convert from a string to
    //a byte array, and send the data that way with a 0 character added at the end. There also isn't a simple way to convert from a string to a byte array, so
    //I have to build the byte array manually. This will also break if the response message is more than 256 characters, but currently that's not possible.
    responseText = class'JsonObject'.static.EncodeJson(Result);
    for(i = 0; i < Len(responseText); i++)
    {
        responseData[i] = Asc(Mid(responseText, i, 1));
    }
    responseData[Len(responseText)] = 0;
    SendBinary(Len(responseText) + 1, responseData);
}

defaultproperties
{
    TargetHost="127.0.0.1"
    TargetPort=1452
}
