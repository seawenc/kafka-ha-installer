# docker build -t dockeropen.x/bitnami/zookeeper:3.9.4 . 
FROM bitnami/zookeeper:3.6.3

USER root
# 此镜像中没有curl指令，因此先在此目录执行
RUN rm -rf /opt/bitnami/zookeeper/lib
COPY 3.9.4.lib /opt/bitnami/zookeeper/lib
RUN chmod -R 777 /opt/bitnami/zookeeper/lib
# 切换回原来的用户
USER 1001
