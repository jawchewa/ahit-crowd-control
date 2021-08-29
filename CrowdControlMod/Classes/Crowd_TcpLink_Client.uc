// This class handles all the TCP functionality for communicating with Crowd control.
// Based on Unreal TcpLink class example by Michiel 'elmuerte' Hendriks
// https://docs.unrealengine.com/udk/Three/TcpLink.html
class Crowd_TcpLink_Client extends TcpLink
    AlwaysLoaded;

var string TargetHost;
var int TargetPort;

var byte buffer[1024];
var int bufferLength;

event PostBeginPlay()
{
    super.PostBeginPlay();
    class'Crowd_CrowdControl_Gamemod'.static.DebugLog("[TcpLinkClient] Resolving: "$TargetHost);
    resolve(TargetHost);
}

event Resolved( IpAddr Addr )
{
    class'Crowd_CrowdControl_Gamemod'.static.DebugLog("[TcpLinkClient] "$TargetHost$" resolved to "$ IpAddrToString(Addr));

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
}

event Opened()
{
    LinkMode = MODE_Binary;
}

event Closed()
{
    local string responseText;
    local byte responseData[255];
    local int i;

    responseText = "Close";
    for(i = 0; i < Len(responseText); i++)
    {
        responseData[i] = Asc(Mid(responseText, i, 1));
    }
    responseData[Len(responseText)] = 0;
    SendBinary(Len(responseText) + 1, responseData);

    class'Crowd_CrowdControl_Gamemod'.static.DebugLog("[TcpLinkClient] event closed");
}

event Destroyed(){
    Close();
    Super.Destroyed();
}

// Main Logic to process incoming binary stream. Puts data into a buffer until we hit a null terminator. Then processes the incoming message and returns whether it was successful or not.
event ReceivedBinary(int Count, byte B[255])
{
    local JsonObject ParsedJson;
    local JsonObject Result;
    local int responseCode;
    local string responseText;
    local byte responseData[255];
    local int i;
    local float timeRemaining;

    local bool hitTerminator;
    local string ReceivedText;

    timeRemaining = -1;

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
    responseCode = class'Crowd_CrowdControl_Gamemod'.static.GetGameMod().ProcessCode(ParsedJson.GetStringValue("code"), ParsedJson.GetIntValue("id"), timeRemaining);

    Result = new class'JsonObject';
    Result.SetIntValue("id", ParsedJson.GetIntValue("id"));
    Result.SetIntValue("status", responseCode);
    Result.SetStringValue("message", "");
    if (timeRemaining > 0)
    {
        Result.SetIntValue("timeRemaining", timeRemaining * 1000);
    }

    //Unrealscript doesn't let you have null characters in strings, so to be able to work with the SimpleTCPConnector, We have to convert from a string to
    //a byte array, and send the data that way with a 0 character added at the end. There also isn't a simple way to convert from a string to a byte array, so
    //I have to build the byte array manually. This will also break if the response message is more than 256 characters, but currently that's not possible.
    responseText = class'JsonObject'.static.EncodeJson(Result);
    class'Crowd_CrowdControl_Gamemod'.static.DebugLog("[TcpLinkClient] Sending command: "$responseText);

    for(i = 0; i < Len(responseText); i++)
    {
        responseData[i] = Asc(Mid(responseText, i, 1));
    }
    responseData[Len(responseText)] = 0;
    SendBinary(Len(responseText) + 1, responseData);
}

event UpdateTimedEffect(int id, int status, float currentDuration)
{
    local JsonObject Result;
    local string responseText;
    local byte responseData[255];
    local int i;

    Result = new class'JsonObject';
    Result.SetIntValue("id", id);
    Result.SetIntValue("status", status);
    Result.SetIntValue("timeRemaining", currentDuration * 1000);

    responseText = class'JsonObject'.static.EncodeJson(Result);
    class'Crowd_CrowdControl_Gamemod'.static.DebugLog("[TcpLinkClient] Sending command: "$responseText);

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
