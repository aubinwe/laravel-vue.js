FROM mysql:8.0

ENV MYSQL_DATABASE=gestion_notes
ENV MYSQL_ROOT_PASSWORD=root
ENV MYSQL_USER=laravel
ENV MYSQL_PASSWORD=password

HEALTHCHECK --interval=30s --timeout=3s --start-period=30s --retries=3 \
    CMD mysqladmin ping -h localhost -u root -p$MYSQL_ROOT_PASSWORD || exit 1

EXPOSE 3306