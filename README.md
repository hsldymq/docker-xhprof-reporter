# hsldymq/xhprof-reporter

## xhprof GUI.

这个镜像不是为了单独使用的.而是需要跟其他php(php-fpm)镜像一起使用.

两者共享一个数据卷,后者运行时将采集的性能数据输出到数据卷的文件中. 前者读取这些性能文件进行显示.

假设现在有两个容器,一个跑官方php-fpm执行业务代码,一个跑docker-xhprof-reporter. 两个容器共享同一个数据卷v.

业务代码业务代码里插入开启xhprof的代码,并在结束是将其写入到数据卷的/var/xhprof里.

docker-xhprof-reporter需要做的仅仅是设置xhprof文件的输出目录(这里就是/var/xhprof).

通过在启动容器时向其传入XHPROFILE_DIR环境变量即可.

`假设数据卷名称为profile,并且挂载点为/var/xhprof`

#### docker run:
```
docker run -it -d -v profile:/var/xhprof -e "XHPROFILE_DIR=/var/xhprof" hsldymq/xhprof-reporter
```

#### docker-compose
```
services:
    ...
    xhprof-reporter:
        image: hsldymq/xhprof-reporter
        environment:
            XHPROFILE_DIR: "/var/xhprof"
        volumes:
            - profile:/var/xhprof
        ports:
            - 9527:9527
        ...
    ...
```