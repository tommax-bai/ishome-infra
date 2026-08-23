-- 首次初始化数据卷时执行（postgres 官方镜像 /docker-entrypoint-initdb.d 机制）。
-- 业务库 ishome 由 POSTGRES_DB 创建；这里补 Temporal 持久化所需两库。
CREATE DATABASE temporal;
CREATE DATABASE temporal_visibility;
