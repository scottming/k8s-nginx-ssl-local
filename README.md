# k8s 如何在本地调试 SSL

## 1. 本地搭建 k8s

macOS 本地搭建 k8s 请参考这个仓库：[maguowei/k8s-docker-for-mac: Docker for Mac开启 Kubernetes 集群](https://github.com/maguowei/k8s-docker-for-mac)

搭建好了之后，启动 Docker GUI 即可。

## 2. 克隆本仓库

注意：Dockerfile 和 default.conf.template 对环境变量有依赖，而环境变量和部分配置文件已加入到 .gitignore，所以仓库没有。

所以你还需要建一个 `envfiles` 的文件夹，生成 ssl 配置的时候会用到，另外构建镜像时需要一些环境变量，可以用 export 的方式，但更建议用 `.env` 并配合 `autoenv` 这个工具。

```bash
$ brew install autoenv
$ mkdir envfiles && touch .env
```

新建 `.env` 文件后，稍后往里面加一些内容。

## 3. 准备 ssl 证书文件并构建 Docker 镜像


参考此仓库 https://github.com/scottming/local-cert-generator 前3步可生成根证书，对根证书开启验证之后，针对某个域名生成 ssl 文件，用我新增的脚本[local-cert-generator/g_ssl_for_domain.sh at master · scottming/local-cert-generator · GitHub](https://github.com/scottming/local-cert-generator/blob/master/g_ssl_for_domain.sh) 。

```bash
$ j local-cert-generator
$ # ./g_ssl_for_domain.sh <domian> <path>
$ ./g_ssl_for_domain.sh mynginx.com  /Users/scottming/Documents/ExRepos/k8s-nginx-ssl/envfiles 
```

`<path>` 参数换成代码文件根目录下的 `envfiles`，运行完上述命令，如果没报错，本仓库目录的envfiles下应该多了3个文件

```
$ j k8s-nginx-ssl # 跳回教程仓库，autojump
$ echo "SSL_KEY=./envfiles/server.key\nSSL_CRT=./envfiles/server.crt\n" >> .env # 新增环境变量至 .env 文件
$ cd ../k8s-nginx-ssl-local # 让 .env 文件生效，依赖 autoenv 这个工具
$ docker build . -t k8s-nginx-ssl:v0.1.1 --build-arg SSL_CRT=$SSL_CRT --build-arg SSL_KEY=$SSL_KEY
```

## 4. k8s 运行 deploy 及 svc

yaml 文件请参考本仓库：https://github.com/scottming/k8s-nginx-ssl-local

```
$ kubectl apply -f nginx-deploy.yaml
$ kubectl apply -f nginx-svc.yaml
```

k8s 运行情况：

```bash
$ kubectl get po
NAME                                    READY     STATUS    RESTARTS   AGE
k8s-nginx-ssl-deploy-68bfc469f7-6k9g9   1/1       Running   0          14m
```

```bash
$ kubectl get svc
NAME                    TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE
k8s-nginx-ssl-service   LoadBalancer   10.103.206.38   localhost     80:31598/TCP,443:31009/TCP   14m
kubernetes              ClusterIP      10.96.0.1       <none>        443/TCP                      4d
```

推荐用 Gas Mask 工具修改 host，新增以下内容

```host
127.0.0.1	mynginx.com
```

最终效果：

![mynginx](img/mynginx.jpg)





