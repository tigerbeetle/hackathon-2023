# TigerBeetle Hackathon at Interledger Summit 2023

We're excited to announce our first hackathon! It's a one-day event that will take place during the [Interledger Summit](https://interledger.org/summit) on Wednesday, 8 November 2023.

<img src="assets/hackaton.png" width="480px"/>

## UPDATED: Winners! 

- 🥇 [TigerBeetle Schema Wizard](https://github.com/tigerbeetle/hackathon-2023/pull/3) by [Evan Schwartz](https://github.com/emschwartz).

- 🥈 [TigerSwarm](https://github.com/tigerbeetle/hackathon-2023/pull/2) by [Riccardo Binetti](https://github.com/rbino).

- 🥉 [Teaching the beetle to fly 💸](https://github.com/tigerbeetle/hackathon-2023/pull/4) by [Cairin Michie](https://github.com/cairin).

## How to participate

You can get together with colleagues or individually, **in person** or **remotely**, to deliver a small project.

### 1. Choose one of the three challenges you're most excited about:

- **Safety Beetle:** Use TigerBeetle to improve durability and availability.

    <table><tr valign="top">
    <td width="100px"><img src="assets/safety.gif"/></td>
    <td>
    <b>Example:</b> Run a TigerBeetle cluster and measure the availability when one or more replicas crash or are partitioned from the network. You can run it on the cloud or on your own laptop using anything you want (e.g. bare metal, Docker, Kubernetes, etc). For a little more fun, you could even run TigerBeetle on a cluster of RaspberryPi's!
    </td>
    </tr></table>

- **Performance Beetle:** Use TigerBeetle to improve throughput and latency.

    <table><tr valign="top">
    <td width="100px"><img src="assets/performance.gif"/></td>
    <td>
    <b>Example:</b> Showcase how to achieve low latency and high throughput by creating a simple application using TigerBeetle. Chef's kiss if you use TigerBeetle for online transactions processing (OLTP) in the data plane, together with an online general-purpose processing (OLGP) database in the control plane. The latter can be any SQL database, or NoSQL, in memory, or whatever you think of!
    </td>
    </tr></table>

- **Experience Beetle:** Use TigerBeetle to model business events as double-entry transfers between accounts.

    <table><tr valign="top">
    <td width="100px"><img src="assets/experience.gif"/></td>
    <td>
    <b>Example:</b> Use TigerBeetle's double-entry account schema to solve common business problems that would require too much boilerplate code to implement with a general-purpose database. For example, a problem involving financial transactions, inventory movements, rate limiting, or just counting things (especially as they move from one person, party or place to another—the <i>who, what, when, where, why, how much</i> of OLTP). There's no limit to your creativity!
    </td>
    </tr></table>

### 2. Create a proof of concept demonstrating what you hacked with TigerBeetle:

No matter your background, you can participate in different ways.

Examples:

- Write a simple application (or adapt an existing one) using any programming language of your choice, including other databases.

- Create infrastructure as code, manifests or scripts to manage TigerBeetle instances running on any supported platform.

- Use diagrams, charts, and writings to make your point.

### 3. Present your work:

Submit a pull request to this repository, including all source code and artifacts you produced. Remember to describe your project and identify yourself and your teammates.

Present a short demo (10 minutes max) of your work **in-person** if you're attending the Interledger Summit 2023, or **send a recorded video** if you're not in Costa Rica 🇨🇷!

## Prizes:

<table><tr><td width="120px">
<a href="https://www.steamdeck.com/hardware"><img src="assets/steam_deck_64G.png"/></a></td>
<td><h3>First place: <a href="https://www.steamdeck.com/hardware">Steam Deck 64GB</a> all-in-one portable PC gaming. 
</h3></td></tr>
<tr><td width="120px">
<a href="https://www.raspberrypi.com/products/raspberry-pi-400/"><img src="assets/raspberrypi_400.png"/></a></td>
<td><h3>Second place: <a href="https://www.raspberrypi.com/products/raspberry-pi-400/">Raspberry Pi 400</a> personal computer kit. 
</h3></td></tr>
<tr><td width="120px">
<a href="https://systemsdistributed.com/"><img src="assets/systems_distributed.png"/></a></td>
<td><h3>Third place: Ticket for the next <a href="https://systemsdistributed.com/">Systems Distributed 2024</a> and TigerBeetle swag.
</h3></td></tr></table>


## Evaluation criteria:

- All projects must be submitted by **November 8th, 2023 3pm CST (GMT-6)**.

- The TigerBeetle team, at their sole and final discretion, will award projects based on technical and subjective criteria (correctness, clarity, creativity, fun etc.).

- The prizes may be handed over **in person** at the Interledger Summit 2023 or **shipped worldwide** for remote participants.

- In the case of teams, they must assign one person to represent the project and receive the prize.

## Resources:

- TigerBeetle's [quickstart guide](https://docs.tigerbeetle.com/#quickstart) is a good place to start.

- Please refer to TigerBeetle's client libraries for [.Net](https://docs.tigerbeetle.com/clients/dotnet), [Go](https://docs.tigerbeetle.com/clients/go), [Java](https://docs.tigerbeetle.com/clients/java), [Node.js](https://docs.tigerbeetle.com/clients/node), and [C](https://github.com/tigerbeetledb/tigerbeetle/tree/main/src/clients/c). There are also great client libraries maintained by community members for [Elixir](https://github.com/rbino/tigerbeetlex), [Rust](https://github.com/ZetaNumbers/tigerbeetle-rs), and [C++](https://github.com/kassane/tigerbeetle-cpp).

- Join our [Slack channel](https://slack.tigerbeetle.com/invite) for help and to bounce ideas.

- Please find us at the Interledger Summit 2023 and come chat.

## License:

All source code provided must be licensed under the Apache License, Version 2.0.

https://www.apache.org/licenses/LICENSE-2.0


