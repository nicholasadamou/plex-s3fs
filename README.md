# plex-s3fs 🎥🍿

A Plex Media Server install script that is backed by an Amazon S3 Bucket.

[![License](https://img.shields.io/github/license/nicholasadamou/stockflight.svg?label=License&maxAge=86400)](./LICENSE)
![Say Thanks](https://img.shields.io/badge/say-thanks-ff69b4.svg)

---

## Why create `plex-s3fs`?

A while back a good pal of mine introduced me to Plex. I started looking up stuff about it like its features, system requirements, and how it works, then before I know it, I had my own server set up to run 24/7! Having experience with Amazon AWS and Digital Ocean, I figured, it would be extremely simple to not only get a Plex Server up and running in the cloud, but also have my entire library of movies and TV shows backed up in the cloud as well through Amazon's S3 buckets. I choose Amazon S3 for my storage because of it's dirt cheap pricing and flexibility. Also, you don't have to use the root user, I did because I didn't know what I was doing with my first attempt and I just stuck with it. It is better if you create your own user with the sufficient privileges, but can be done however you desire. This doesn't have to be done through DigitalOcean. You can use any VPS you want, I used DigitalOcean because I was familiar with it.

⚠️ _**Note**_: Before I start, I'm going to say that this is better for people with small libraries (under 500gb) due to Amazon S3's pricing, and if your are curious about pricing, look [here](http://calculator.s3.amazonaws.com/index.html) for Amazons official AWS pricing calculator.

## Getting Started

In order to start, you must first create a VPS (Virtual Private Server) using Digital Ocean or one of its competitors. First, go to [Digital Ocean](https://m.do.co/c/6256ee0966d5) and create an account using my referral code to get yourself a \$10 credit to see if you want to stick with it.

After your account is created, log in and create a new **droplet**.

**It doesn't matter which pricing option you choose**, just be sure you choose one with enough transfer to upload all of your content because it all has to be uploaded through the server.

_When it asks you what distribution of Linux to install_, be sure to **choose the latest version of Ubuntu**.

After your droplet is created, I recommend using SSH instead of the web console. On PC, get [Putty](http://www.chiark.greenend.org.uk/~sgtatham/putty/), and for Mac, open terminal and type `ssh root@your-ip-here` and replace `youriphere` with the IP of your droplet. It will prompt you for your password, enter it and your in!

## Setup

[![xkcd: Automation](http://imgs.xkcd.com/comics/automation.png)](http://xkcd.com/1319/)

Now, to install `plex-s3fs`, just run the snippet in `terminal`:

(⚠️ **DO NOT** run the `install` snippet if you don't fully
understand [what it does](install.sh). Seriously, **DON'T**!)

```bash
bash <(curl -s -L https://raw.githubusercontent.com/nicholasadamou/plex-s3fs/master/install.sh)
```

That's it! ✨

### Running on a headless server

In order to properly configure our Plex server, we need to add the required claim token. To add the token, you will need to use ssh tunneling to gain access and setup the server for first run. During the first run, you setup the server to make it available and configurable. However, this setup option will only be triggered if you access it over http://localhost:32400/web, it will not be triggered if you access it over http://ip_of_server:32400/web. Since we are setting up PMS (Plex Media Server) on a headless server, you can use a SSH tunnel to link http://localhost:32400/web (on your current computer) to http://localhost:32400/web (on the headless server running PMS):

`ssh username@ip_of_server -L 32400:ip_of_server:32400 -N`

## Liability

The creator of this repo is _not responsible_ if your machine ends up in a state you are not happy with.

## License

Copyright 2019 Nicholas Adamou

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
