using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using Grpc.Core;
using Pj.Grpc.Sample;

public class Sample : MonoBehaviour
{
    public string ip = "127.0.0.1";
    public string port = "50051";

    public Text text;

    private void Start()
    {
        text.text = "wait reply...";
        Say();
    }

    public void Say()
    {
        Channel channel = new Channel(ip + ":" + port, ChannelCredentials.Insecure);
        var client = new Greeter.GreeterClient(channel);
        string name = Application.platform.ToString();

        var reply = client.SayHello(new HelloRequest { Name = name });
        Debug.Log("reply: " + reply.Message);
        text.text = "reply: " + reply.Message;

        channel.ShutdownAsync().Wait();
    }
}