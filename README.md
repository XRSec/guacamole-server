# [Guacd_Docker](https://xrsec.vercel.app/Guacd_Docker.html)

![version](https://img.shields.io/badge/Version-Guacd%201.3.0-da282a) [![Docker Automated Build](https://img.shields.io/docker/automated/xrsec/code-server?label=Build&logo=docker&style=flat-square)](https://hub.docker.com/r/xrsec/guacd) [![Docker guacamole-server Build](https://github.com/XRSec/guacamole-server/actions/workflows/Docker%20guacamole-server%20Build.yml/badge.svg)](https://github.com/XRSec/guacamole-server/actions/workflows/Docker%20guacamole-server%20Build.yml)

[The official Github](https://github.com/apache/guacamole-server/)

## USE

```dockerfile
FROM xrsec/guacd:1.3.0

COPY ./fonts/Menlo-Regular.ttf /usr/share/fonts/
COPY ./fonts/SourceHanSansCN-Regular.otf /usr/share/fonts/

RUN mkfontscale && mkfontdir && fc-cache
```

> XRSec has the right to modify and interpret this article. If you want to reprint or disseminate this article, you must ensure the integrity of this article, including all contents such as copyright notice. Without the permission of the author, the content of this article shall not be modified or increased or decreased arbitrarily, and it shall not be used for commercial purposes in any way
