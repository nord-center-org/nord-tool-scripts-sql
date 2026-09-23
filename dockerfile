FROM postgres:16

WORKDIR /app

COPY . /app

RUN chmod +x /app/executa-sql.sh

CMD ["/app/executa-sql.sh"]