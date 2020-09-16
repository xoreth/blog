---
layout: post
title: Debug ASA VPN site2site
author: Galuh D Wijatmiko
categories: [Networks]
tags: [asa,firewall]
draft: false
published: true
---



## ASA VPN Troubleshooting ##

Yesterday, I assisted with troubleshooting ASA VPN issues. A local ASA needed to build a site-to-site (aka L2L) IPSec VPN tunnel to a non-ASA third-party. The tunnel was not coming up.

The config all appeared to be there, and the third-party said their config was in place too.
It’s time to troubleshoot. Here are the steps I followed.

 
Check if SA’s are Forming
This is always my first step when troubleshooting. There should be phase-1 SA’s and phase-2 SA’s for the ASA VPN to work.

You can find phase-1 SA’s with:
```bash
show crypto isakmp sa
```
And phase-2 SA’s with:
```bash
show crypto ipsec sa
```
 

In my case, there were no phase-1 SA’s, so there was no point looking for phase-2 SA’s.
Perhaps the ASA hasn’t seen any interesting traffic yet and hasn’t tried to bring the tunnel up. We can try to do this with packet tracer:
```bash
packet-tracer input Inside tcp 10.0.0.1 http 172.16.0.1 http
```

This just simulates some http traffic from 10.0.0.1 to 172.16.0.1. These are hosts that should be able to communicate over the tunnel.
This doesn’t work, and no SA’s formed. So, phase-1 looks like a good place to focus on.

 

 
## Check IKE Proposals ##

The first step in troubleshooting phase-1 (IKEv2 in my case) is to confirm that there are matching proposals on both sides. The proposals include acceptable combinations of cyphers, hashes, and other crypto information.

This is easy if you control both ends of the ASA VPN tunnel. Just look at what’s configured. In my case, it’s a little harder, as a third-party manages the remote end of the tunnel.

Instead, I can find this with a debug command:
```bash
debug crypto ikev2 protocol 64
```
 
For Disable debug
```bash
no debug crypto isakmp 200
```

This will show us any errors with IKEv2 (you can substitute IKEv1 if you need to).

The ’64’ is the debugging level. This can be from 1 to 256. The higher the number, the more detail you get. Don’t go too high too quickly, as there may be too much information to search through.

The debug gave me this:
```bash
IKEv2-PROTO-1: (16): Received Policies:
Proposal 1: AES-CBC-256 SHA1 SHA96 DH_GROUP_1024_MODP/Group 2
Proposal 2: AES-CBC-256 SHA256 SHA256 DH_GROUP_1024_MODP/Group 2
Proposal 3: AES-CBC-128 SHA1 SHA96 DH_GROUP_1024_MODP/Group 2
Proposal 4: AES-CBC-128 SHA256 SHA256 DH_GROUP_1024_MODP/Group 2
Proposal 5: 3DES SHA1 SHA96 DH_GROUP_1024_MODP/Group 2
Proposal 6: 3DES SHA256 SHA256 DH_GROUP_1024_MODP/Group 2
IKEv2-PROTO-1: (16): Failed to find a matching policy
IKEv2-PROTO-1: (16): Expected Policies:
Proposal 1: AES-CBC-256 SHA384 SHA384 DH_GROUP_2048_MODP_256_PRIME/Group 24
```

We can see here that the remote endpoint is offering six proposals, and we are offering one.
Our proposal does not match any of theirs, so IKE will fail. There are two ways to address this:
```bash
    We change our proposal to match theirs
    They change their proposal to match ours
```
 
For testing, it’s simpler just to change our side. We can figure out better security algorithms later.
Once the proposal has been changed, these debug errors no longer show up. But we’re still not getting phase-1 SA’s.
Also, it looks like the ASA is not even trying to bring up the tunnel. The proposal errors were coming from the remote end.
Time to check the network path…


## Referance
[[https://www.thinknetsec.com/vpn-troubleshoot-ikev1-site-to-site/]]
