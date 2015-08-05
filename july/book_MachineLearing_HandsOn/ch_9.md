# 实时机器学习－使用Spring XD框架

想象一下，我们在阅读本章时所大脑里所产生数据量。在大脑中，这些大量的阅读数据，不停经过生成、储存以及处理，
最后得到有用的解读和价值，这就是实时数据。类似的例子很多，比如房间里的温度传感器总是固定产生数据；
再比如，一个处理不同社交媒体的信息源（feed）。这些实时（Real time）产生的数据里面，拥有非常多潜在的价值。
完成获取、处理、保存以及学习这一整个过程，是有复杂很充满难度的。好在现在有一些现成的工具可以帮助我打通整个过程。

本章主要内容是：以Twitter信息流API为例子，说明如何使用Sprint XD框架，开发处理实时数据的机器学习应用。
这个应用例子，可以用来处理Twitter上的实时发帖，并且你可以定制你自己的处理算法。

---
## 获取消防水管式的数据

对那些提供连续的、流式的数据公司，我们经常称他们为消防水管（Firehose）公司。
首先数据就像消防管道的水流一样喷射而出，然后到了接收者这里，获取他们需要的数据，最后经过处理得到最终有用的内容。
当然，这些数据不是随便获取的，有时候数据消费者必须跟数据提供者签订协议。


### 使用实时数据的注意事项

在我们立刻着手开发实时数据应用，扫描Twitter的推文种子（Feed）的之前，我们首先要思考一下，我们的应用是否是真的实时应用？
不能因为我们手里拥有了实时处理工具，我们就一定要开发实时应用。

金融服务公司必须开发实时应用，因为他的客户使用公司提供的服务来决策股票的买卖；这个决策必须是实时的，股票的买卖必须在毫米级做出决定。
以股市为例子，一个滞后10秒或者20秒的数据都是“旧”的，没有处理价值，这是因为在短时间内回产生大量的交易。在这个短时间内，股票价格会发生
多次变动。（译者注：这是机器学习领域重要的应用领域，量化交易或者高频交易。）

相反，电子商务网站就不一定需要开发实时应用。这些网站会周期的（比如3，6，12甚至24小时）批量收集交易数据，
然后利用这些交易数据通过机器学习，形成消费者推荐内容。这些批量数据的处理，我们将在第10章详细介绍。

为了应对实时应用，一些新兴的处理系统，会使用内存数据库。为了得到更快的处理速度，他们不再使用传统的，使用二级存储（译者注：指硬盘）的，
基于ETL模式（Extrac, Transform and Load)的SQL关系数据库，来开发他们的商业智能应用。

另外一个问题就是存储：是否一定需要保存所有数据呢？仅保持处理过的数据能否满足需求？或者是否有保持原始数据，以备后来处理的需求？
尽管存储的成本是在下降的（满足摩尔定理），但是存储依然是你必须考虑的主要成本之一。怎么样保存数据？存储在什么地方？
假如数据保存在云端（比如Amazon S3 )，那么要不要考虑隐私问题呢？你必须思考清楚数据安全（备份、恢复服务水平）以及数据保密（隐私、安全以及访问权限）。

随着计算能力的增长，存储成本的直线下降，我们可以使用很多多高性能、低价格的数据库系统了，甚至无法阻住你同时使用两个或者三个数据库来应对将来的处理。
你可以考虑实现用传统的关系型数据库比如MySQL、基于列存储的数据库比如HBase，又或者图模式数据库比如Neo4J或者Apache Giraffe。
你必须思考清楚你的数据的生命周期、用例，你使用的每一个SQL活着NoSQL数据系统的优缺点（http://martinfowler.com/books /nosql.html）。

### 实时系统的使用范围

实时数据系统的应用非常广泛。随着有价值的社交媒体和手机数据的疯狂增长，实时数据系统变得越来越重要，特别是对那些必须保持即时连接，随时根据人们位置的的变化的推荐系统。
基于位置针对性的广告系统就是非常好的实时系统的例子，这样的系统必须根据消费者的手机位置结合实时场景信息（包括天气、交通、时间以及即时新闻）给出合适的判断。

前面提到的金融交易就是另外一个实时系统的例子。量化交易公司需要高速（微妙级）处理交易的实时计算能力，能够在一秒钟内完成几千次的交易。
有很多的算法能够胜任这样的计算任务。有些系统把财经新闻的头条以及Twitter的种子作为数据源，寻在那些特殊的时机进行交易。
这些实时交易系统取得不同程度的成功。诈骗支付检测算法还可以实时分析交易数据，当这些问题交易发生的时候给指出来。
随着处理能力的增长，这些金融服务公司开始将历史交易数据、位置信息以及在线购买行为都涵盖进来，进行软实时计算，取得更为精准的结果。

为了满足终端用户的交互式响应，系统需要考虑引入实时处理系统。在这样的场景中，总是保持数据在内存中可以提升响应速度。
二级存储只应该被用来加速系统恢复和重启内存，或者用来为深度训练提供大量的数据用。

## 使用 Spring XD
---
本章专门介绍为实时系统而设计的Spring XD框架，该框架大大简化了数据摄取、处理以及输出整个开发流畅。

**注意:** 所谓数据摄取，指的是获得多个源的数据，因此使用Sprint XD可以开发同时处理日志数据、Twitter推文以及RSS种子的应用。

Spring XD runs either on a single server or on a cluster of machines in dis- tributed mode. The examples in this chapter use a single server. The Spring XD software is released under the Apache 2 License and is completely open source, so you are free to download and use it with no restrictions. Spring has done a very good job of including the majority of common use cases in the base release; it’s a good starting point to show how real-time analytics can be built quickly and with minimum effort.
If you are aware how the UNIX pipe commands work, then you’ll have an easy time understanding how Spring XD functions. If you’re not familiar with UNIX pipe commands then please read on; I explain how the basic command pipeline and data streaming in UNIX and Spring XD work.


Spring XD可以运行在一台单一的服务器上，也支持以分布式的形式运行在集群上。本章的例子只使用单一的服务器。
Spring XD软件实在Apache 2许可证下发布的开源软件，因此你可以自由下载并且无限制的使用（译者注：必须符合Apache 2的权利申明）。