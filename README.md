# Lsky-Pro-X Docker镜像

Lsky Pro 是一个用于在线上传、管理图片的图床程序，中文名：兰空图床，你可以将它作为自己的云上相册，亦可以当作你的写作贴图库。

原项目：[Lsky Pro](https://github.com/lsky-org/lsky-pro)

本项目利用 `Github Action` 自动获取官方最新发布版本并更新至 `latest` 镜像

同时拉取每日最新代码构建 `nightly` 镜像

## 架构支持

本镜像支持以下架构：

| Architecture | Available | Tag |
| :----: | :----: | ---- |
| x86-64 | ✅ | amd64-\<version tag\> |
| arm64 | ✅ | arm64-\<version tag\> |
| armhf| ✅ | armv7-\<version tag\> |

## 版本标签

镜像 Tag 支持：

`latest` 跟随 lsky-pro 版本号自动编译上传

`nightly` 根据 lsky-pro 日常 commit 自动编译上传

| Tag | Available | Description |
| :----: | :----: |--- |
| latest | ✅ | Stable lsky-pro releases |
| nightly | ✅ | Nightly lsky-pro commits |


## 使用方法

以下为部分参考示例

### Docker-Compose （推荐）

使用`MySQL`来作为数据库的话可以参考原项目 [#256](https://github.com/lsky-org/lsky-pro/issues/256) 来创建`docker-compose.yaml`。

`mysql:5.7` 官方暂时只提供 `amd64` 架构镜像，`arm64` 与 `arm32` 架构请自行更换其他 `mysql` 镜像

`amd64` 架构参考配置文件如下：

```yaml
version: '3'
services:
  lsky-pro:
    image: tyroyal/lsky-pro-x:latest
    restart: unless-stopped
    hostname: lsky-pro
    container_name: lsky-pro
    volumes:
      - /path/to/lsky:/var/www/html/
    ports:
      - "8008:80"
    networks:
      - lsky-net

  mysql-lsky:
    # arm 架构请自行更换 mysql 镜像使用
    image: mysql:5.7
    restart: unless-stopped
    # 主机名，可作为子网域名填入安装引导当中
    hostname: mysql-lsky
    # 容器名称
    container_name: mysql-lsky
    # 修改加密规则
    command: --default-authentication-plugin=mysql_native_password
    # 修改数据位置
    volumes:
      - /path/to/mysql/data:/var/lib/mysql
      - /path/to/mysql/conf:/etc/mysql
      - /path/to/mysql/log:/var/log/mysql
    environment:
      MYSQL_ROOT_PASSWORD: enteryourpassword # 数据库root用户密码，自行修改
      MYSQL_DATABASE: lsky-data # 给lsky-pro用的数据库名称
    networks:
      - lsky-net

networks:
  lsky-net:
```

在安装的时的 `Install` 界面数据库连接地址填入数据库的 `hostname` 即 **`mysql-lsky`** 即可

### Docker Cli

```docker
docker run -d \
    --name lsky-pro \
    --restart unless-stopped \
    -p 8008:80 \
    -v /path-to-data:/var/www/html \
    tyroyal/lsky-pro-x:latest
```


## 反代HTTPS

如果使用了Nginx反代后，如果出现无法加载图片的问题，可以根据原项目 [#317](https://github.com/lsky-org/lsky-pro/issues/317) 执行以下指令来手动修改容器内`AppServiceProvider.php`文件对于HTTPS的支持

***Tips：将 `lsky-pro` 改为自己容器的名字***

```bash
docker exec -it lsky-pro sed -i '32 a \\\Illuminate\\Support\\Facades\\URL::forceScheme('"'"'https'"'"');' /var/www/html/app/Providers/AppServiceProvider.php
```

