[< README](../README.md)

### 🙋🏼‍♀️ Welcome

Hello everybody! I’m glad to share great news with you.
<br>
Finally, I have almost finished working on the new version.
<br>
I called it 🏈 <b>Rugby: Remastered</b> 😀.
<br><br>
BTW, maybe you wonder why I needed to develop a new version.
<br>
What’s wrong with the previous one?
<br><br>
It has some fundamental drawbacks which make development pretty complicated.
<br>
It isn’t only my opinion. I had some feedback from the community.
<br><br>
I realized that I needed to reinvent almost everything. And I did it all in one go.
<br>
I thought it was better to make a one major version instead of a bunch of them.
<br>
But anyway, I tried to keep the known soul of Rugby and slightly embellish it.

### What makes the new version different?

1. <ins><b>Cache consistency</b></ins>. Sometimes Rugby didn’t rebuild modules after changes.\
At the same time, it used to rebuild modules too often even if it was unnecessary.\
The issue could be solved by calling command `rugby clean` or passing the flag\
`--ignore-checksums`. But it was not by design and led to user’s frustration. I challenged\
myself and tried to make a new better algorithm for calculating modules cache;
2. <ins><b>Cache distribution</b></ins>. The previous version keeps cache in each project directory.\
That choice bounds Rugby development. I decided to move the projects cache to one global directory.\
It allows reusing all binaries between any git branch or even any project. Also, it can be\
used as a remote cache between different macs, including CI runners;
3. <ins><b>W/o magic interfaces</b></ins>. I received a lot of questions about Rugby commands. Some of them\
have bad names. Names are repeated with different results. They are unclear and have unexpected\
magic under the hood. I read some CLT guides and tried to make everything a bit better. I’m still\
open to getting feedback during the pre-release period;
4. <ins><b>Optimizations</b></ins>. I always do experiments in my home projects. Now I’m learning async/await API,\
and this fact has already changed Rugby architecture. I tried to make all things targeted to concurrency.\
Also, I got carried away during refactoring and reinvented a lot of Rugby parts in favor of speed.

<br>

Welcome to 🏈 **Rugby: Remastered**!\
And learn [> How to Install](How%20to%20install.md) 📦 it.
