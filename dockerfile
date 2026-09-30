FROM postgres:17

WORKDIR /app

COPY . /app

RUN chmod +x /app/executa-sql.sh

ENTRYPOINT ["/app/executa-sql.sh"]