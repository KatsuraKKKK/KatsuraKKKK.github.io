---
layout: post
title: "Raft算法，从学习到忘记"
data: 2017-03-14 23:08:30 +0800
category: Distributed System
tags:
- Raft
- Distributed
- Algorithm
comments: true
---
	
## Raft算法，从学习到忘记
--Raft算法阅读笔记。

### 概述

说到分布式一致性算法，可能大多数人的第一反应是paxos算法。但是paxos算法一直以来都被认为是难以理解，难以实现。So...Stanford的Diego Ongaro和John Ousterhout提出了Raft算法，这是一个更容易理解的分布式一致性算法，在算法的论文中，不仅详细描述了算法，甚至给出了RPC接口定义和伪代码，这显然更加容易应用到工程实践中。这两个算法在一定程度上是相通的，个人觉得Raft是加了更多约束的Poxas衍生算法。

log entry：每个entry包含状态机的command
term：用来标示是那一轮选举，每次选举都会递增
index：log entry的标示，term和index唯一标示一个entry
commit：将log entry应用到状态机中

### 服务器状态

![server_implement.jpeg]({{ site.baseurl}}/images/2017/03/server_implement.jpeg)

图中是Raft中的Repliated status machine architecture，每个server维护一份log，在这些log中记录的是应用到state machine中的commands。各个服务器中的状态机被apply一致的log的命令，从而保持集群中服务器的最终的一致性。

如下图所示，在Raft算法中，服务器有三种状态：Follower, Candidate, Leader。

![server_status.jpeg]({{ site.baseurl}}/images/2017/03/server_status.jpeg)

1. 在服务器刚启动的时候，都属于Follower状态，它接收Leader的RPC请求。如果经过一定时间没有发现Leader，那么它转换到Candidate状态，进而开始Leader的选举。
2. Candidate发现集群中已经有Leader的时候便会转换到Follower状态，又或者它在选举中获得大多数节点（majority of servers）的选票变成Leader。
3. Leader只有在发现比自己高term的Leader的时候才会转换成Follower。

### RPC Interface

为了保证各个服务器的一致性，Raft算法有一些不变式是要保证的。

* **Election Safety**: 在每一个term中最多只有一个leader会被选举出来。
* **Leader Append-Only**: 每个leader只能append自己的log，而不能覆盖或者删除它。
* **Log Matching**: 如果两条log具有相同的index和term，那么它们之前的logs应该是一致的。
* **Leader Completeness**: 如果一个log在一个term中被committed，那么它会出现在所有更高term的leader的log中。
* **State Machine Safety**: 如果一个server已经把一个log entry应用到她的状态机，那么没有其他的server可以应用一个具有同样term和index的不同的log entry。
  
Raft算法给出了服务器状态的变量，以及所所用到的RPC接口的定义和伪代码：

**Status**

```
Persistent state on all servers
在RPC调用返回之前会被更新到稳定的存储中
currentTerm: 	server发现的最高的term
voteFor: 		在当前term中投票给了哪一个candidate
log[]: 			log entries，entry包含应用到状态机的命令和从leader得来的term和command

Volatile state on all servers
commitIndex: 	已尽被提交的log的最大log entry。
lastApplied: 	已经被应用到status的最大log entry。

Volatile state on leaders
在选举后重新初始化
nextIndex[]: 	要发给各个follower的下一个log entry的index。
matchIndex[]: 	各个服务器当前已被replicated的log entry的最大index。
```

**AppendEntriesRPC**

```
leader用于replicate log entries，也用作心跳。

Arguments
term: 			leader's term
leaderId: 		follower用于让client重定向
prevLogIndex: 	新log entry的前一个entry的index
preLogTerm: 	新log entry前一个entry的term
entries[]: 		需要同步的log entries，如果用作心跳，那么这个参数为空
leaderCommit: 	leader's commitIndex

Results
term: 			当前term
success: 		如果follower有entry符合preLogIndex和preLogTerm，则返回true，否则返回false。

被调用方的实现:
1. replay false if term < currentTerm
2. replay false 如果没有entry符合preLogIndex和preLogTerm
3. 如果存在与新entry冲突的entry，那么把现有的冲突entry和往后的entries删除
4. Append any new entries not already in the log
5. if leaderCommit > commitIndex, set commitIndex = min(leaderCommit, index of last new entry)

```

**RequestVote RPC**

```
candidate用于收集选票
Arguments
term: candidate's term
candidateId: candidate requesting vote
lastLogIndex: index of candidate's last log entry
lastLogTerm: term of candidate's last log entry

Results
term: currentTerm, for candidate to update itself
voteGranted: true means candidate received vote

被调用方实现：
1. Reply false if term < currentTerm
2. If voitedFor is null or candidateId, and candidate's log is at least as up-to-date as receiver's log, grant vote.

```


**Rules for Servers**


All Servers

* If commitIndex > lastApplied: increment lastApplied, apply log[lastApplied] to state machine
* If RPC request or response contains term T > currentTerm: set currentTerm = T, convert to follower 

Followers

* Respond to RPCs from candidates and leaders
* If election timeout elapses without receiving AppendEntries RPC from current leader or granting vote to candidate: convert to candidate

Candidates

* On conversion to candidate, start election:
 * Increment currentTerm
 * Vote for self
 * Reset election timer
 * Send RequestVote RPCs to all other servers
* If votes received from majority of servers: become leader
* If AppendEntries RPC received from new leader: convert to follower
* If election timeout elapses: start new election

Leaders

* Upon election: send initial empty AppendEntries RPCs (heartbeat) to each server; repeat during idle periods to prevent election timeouts
* If command received from client: append entry to local log, respond after entry applied to state machine
* If last log index ≥ nextIndex for a follower: send AppendEntries RPC with log entries starting at nextIndex
 * If successful: update nextIndex and matchIndex for follower
 * If AppendEntries fails because of log inconsistency:decrement nextIndex and retry
 * If there exists an N such that N > commitIndex, a majority of matchIndex[i] ≥ N, and log[N].term == currentTerm: set commitIndex = N
 

### Leader Election

在一个server转换成candidate后就会++term，并且用RequestVoteRPC发起选举。对于一个server来说，一轮选举的结果有三种:

1. 赢得选举变成leader
2. 另一个server赢得选举，自己变成follower
3. 没有winner，开始新一轮选举。


在一轮选举中：

1. 选票是先到先得，也就是说一个server收到一个RequestVoteRPC，如果请求投票的server满足voitedFor is null or candidateId, and candidate's log is at least as up-to-date as receiver's log, 那么就将选票给它。
2. 当一个server获得大多数选票的时候，它成为leader，并向其他服务器发送心跳，告知新的leader已经产生。
3. 如果一个server收到不低于自己term的心跳，说明已经产生了leader，这个server转换成follwer。
4. 如果一轮选举没有winner，那么心跳超时以后在随机延时之后将发起新一轮的选举。以避免形成活锁

### Log Replicate

一个log entry由leader接收client的请求而产生，通过appendEntryRPC同步集群中的其他服务器，在多数节点返回以后，leader向client返回处理结果。并且commit已经完成replicated的log entry。

在leader对一个entry做commite操作的时候，同时也会将这个entry之前的entrise一并做commit。在AppendEntries RPC中，会带上leader已知被commite的entries的最大index，这样follower就根据这个index将自己的log entrise中在index之前的entrise应用到状态机中。

当AppendEntriesRPC中的preLog不存在于follower的log中，那么follower返回false,然后leader递减该follower的nextIndex,并重新发送AppendEntriesRRC直到找到leader跟follower共同拥有的log entry。如果follower中存在leader中没有的log entries，那么讲使用leader的log进行覆盖。

对于AppendEntriesRPC的实现，也有人提出一些优化的方案，比如说在返回false的时候附带follower的last entry的信息，但是论文作者认为在实践中失败并不是经常发生，并且增加这些优化机制会增加算法实现的复杂度，index递减的机制已经可以保证在实践中算法的性能，所以没有必要去使用更加复杂的机制。

对于上一个term的entries，如果它们没有被commite，那么新的leader也不会去计算它们备份的数量来判断它们是否应该commite，而是通过commite新leader自己提出的entry，从而把之前的entries也提交了，见`Log Matching`。

### Cluster membership

这个小节讨论集群配置变化的情况。在实践中，集群的配置不可能完全没有变化，那么如何处理配置变化的情况就是一个需要解决的问题。最简单的方式莫过于停止所有的服务器，更改配置，然后重启。但是这样在实际的工程实践中一般是很难被接受的，因为需要完全停止服务。

为了配置变更的安全性，那么必须保证在任意的时间里在同一个term中不能有两个server同时被选举成为leader，否则就产生了分布式系统中所谓的脑裂。不幸的是任何直接将server从老的配置变更到新的配置的方式都是不安全的。因为在转变的过程中，集群又可能分化为两个（majorities）集群。

![two_disjiont_majorities.jpeg]({{ site.baseurl}}/images/2017/03/two_disjiont_majorities.jpeg)

如上图所示，由于每个服务器的转变时间不一样在某个时刻可能会有两个leader选出。在这个例子中就是集群中的服务器从三台增加到五台的情况，在同一个term中就有可能会出现以老的配置Cold的一个集群和使用新的配置的一个集群。

为了保证配置更新的安全性，配置的变化必须使用两段的策略。必入有一些系统使用第一阶段停止老的配置，使之不能响应客户端的请求，第二阶段使新的配置生效。

在Raft算法中，集群首先会进入一个过渡的配置，我们称之为joint consensus，在这个阶段新老配置同时存在。一旦joint consensus被committed，那么系统将转换到新的配置。

![two_disjoint_timeline.jpeg]({{ site.baseurl}}/images/2017/03/two_disjoint_timeline.jpeg)

在joint consensus中，新老配置同时存在：

1. Log entries are replicated to all servers in both con- figurations.
2. Any server from either configuration may serve as leader.
3. Agreement(forelectionsandentrycommitment)re- quires separate majorities from both the old and new configurations. 这个指的是一个agreement需要新老Configuration两个集群中的各自的大多数都同意。

集群的configuration使用一个特殊的entries来保存和传输，当leader收到configuration从Cold到Cnew的变更的请求，它将configuration保存成Cold,new，并且将它replicate到其他server中。当server将new configuration entry保存到它的log中，它将使用新的configuration来做将来的决策（server都会使用最新的configuration，不管它是否被提交）。也就是说leader使用Coldnew的规则来判断什么时候Cold,new被提交。如果这时候leader挂掉了，那么新的leader有可能具有Cold或者Cold,new，这要取决于它是否已经收到了Cold,new。在这种情况中，Cnew不能单方面的做出决定。

当Cold,new已经被提交，那么Cold和Cnew都不能在没有对方同意的情况下单方面的作决定。在这之后leader就可以产生一个描述Cnew的entry，并且将他replicate到集群中。当Cnew被commite，就可以将Cnew中没有包括的server安全的关闭了。

在任何时候Cold和Cnew都不能单方面的作出决定。这就保证了安全性。

不过还有3个延伸的问题：

1. 新的server可能没有任何日志，那么在与leader同步之前它可能并不能commite任何entry。Raft为这种情况添加了一个额外的phase，这个阶段让新加入的server与leader同步，但是它不被认为是majorities(non-voting members)。
2. 如果新选出的leader不是new configuration的一员，那么在它commite完Cnew，他将主动卸任，转换成follower。也就是说他要管理一个不包括它自己的集群，直到Cnew已经被commmite。
3. 被下限的机器会因为收不到机器而超时，他会增加自己的term，并向集群中的机器发起选举。因为它的term会比集群中的机器高，但是preLog却不够up－to－date，所以Cnew的机器总是会被选举成新的leader。但是下线的机器又回超时而重复触发选举，从而降低可用性。为了解决这个问题，Raft使用了一个简单而有效的策略，如果server确认leader还存活，也就是在心跳的超时时间之内，它将忽略RequestVoteRPC请求。这个策略既没有修改选举的核心策略，却能完美的解决了下线机器的困扰。

### Log compaction

Raft的log会随着时间的推移而越来越大，但是在实际的实践中并不能让日志没有限制的增长，这会使得占用空间和replay的时间增加。与Chubby和ZooKeeper等很多分布式系统一样，Raft也使用Snapshot来压缩自己的log。在Snapshot中，当前的系统状态会被记录并存储下来，而之前的log就可以删掉了。当然，使用log cleaning和LSM树也是可以的，log clean需要对Raft算法做一定的修改，当然也会给算法带来额外的复杂度；状态机可以实现LSM树并用相同的snapshot接口。


![snapshot.jpeg]({{ site.baseurl}}/images/2017/03/snapshot.jpeg)

如图，在snapshot中，会包括当前的状态机状态，并且会包括snapshot中的最后一个entry的index和term，这是为了让AppendEntriesRPC调用的时候能够检查到preLog的信息。snapshot中还会包涵最新的configuration。
虽然各个server是独立的进行snapshot的操作，但是当一个节点落后太多的时候leader还是需要向该节点发送snapshot来进行一致性的同步。这种情况发生在leader生成snapshot的时候把要发送给该节点的nextLog从log中删除掉了。
下面是Leader给其他节点发送snapshot的RPC接口:

**InstallSnapshot RPC**

```
Arguments
term: 		leader's term
leaderId: 	让follower能够重定向请求
lastIncludedIndex: 	the snapshot replaces all entries up through and including this index
lastIncludedTerm:	term of lastIncludedIndex
offset:		byte offset where chunk is positioned in the snapshot file
data[]:		raw bytes of the snapshot chunk, starting at offset
done:		true if this is the last chunk

Results
term:currentTerm, for leader to update itself

Receiver impleamentation
1. Reply immediately if term < currentTerm
2. Create new snapshot file if first chunk (offset is 0)
3. Write data into snapshot file at given offset
4. Reply and wait for more data chunks if done is false
5. Save snapshot file, discard any existing or partial snapshot with a smaller index
6. If existing log entry has same index and term as snapshot’s last included entry, retain log entries following it and reply
7. Discard the entire log
8. Reset state machine using snapshot contents (and load snapshot’s cluster configuration)
```

另外，如果server收到一个snapshot指向之前的entries，那么它将覆盖snapshot指向的entries，并且保留之后的log entries，这种情况发生在网络不稳定而重传的时候。

生成snapshot也是需要消耗io和时钟周期的，所以snapshot的时机也是需要考虑的。一个简单的策略就是文件达到一定的大小就进行snapshot的生成。而对于磁盘io性能的消耗，一般使用，一般使用copy-on-write的技术，使得在snapshot的时候还是可以接收客户端请求。例如把状态机以支持写时复制的数据结构实现。另外，一些操作系统的写时复制机制也可以加以利用(Alternatively, the operat- ing system’s copy-on-write support (e.g., fork on Linux) can be used to create an in-memory snapshot of the entire state machine (our implementation uses this approach))


### Client interaction

与其他主从结构的分布式系统一样，Raft算法中写请求的操作全都由leader来进行，如果follower接收到了写请求，那么它将拒绝请求，并且提供leader的地址，供client访问。在leader crash的时候有可能会使得client以为之前的请求没有执行而发起重复的请求，从而使得请求被执行两次，这个问题的解决办法是客户端在请求中附带一个线性递增的序列号，而状态机则追踪各个client的最新的序列号。

读请求可以不经过leader，但是如果不加额外限制读请求可能会读到过期的数据，这种情况发生在读请求由leader处理，并且这个leader是一个新的leader，它可能还不知道哪些entries已经被commite了，或者leader正好与集群断开了连接。对于第一种情况，Raft算法要求leader在自己成为leader之后先commite一个空的entries（no-op entry)这样它就拥有了哪些entries已经被commite的信息。对于第二种情况，Raft算法要求leader在处理只读请求的时候，需要先获得大多数节点的心跳成功。


### 小结

在读完Raft算法的论文以后，最大的感受就是Raft算法就如它提出的理由一样，简单、易于理解（KISS原则有没有），并且可以很好的指导工程实践。但是还是需要看一下Paxos，可以借助Raft去理解它，毕竟是用讲故事的方式描述的算法～

另外，突然觉得log就是分布式的核心啊。。（别问我为什么，我就是那么觉得的）


### 引用

* [Raft Paper](https://raft.github.io/raft.pdf)
* [Raft Github.IO](https://raft.github.io/)
* [Paxos](https://en.wikipedia.org/wiki/Paxos_(computer_science)) 
