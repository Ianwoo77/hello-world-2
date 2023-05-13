FROM diamol/golang as bulder

COPY main.go .
RUN go build -o /server

# app
# work?
# work again?
FROM diamol/base

ENV IMAGE_API URL="http://iotd/image" \
    ACCESS_API_URL="http://accesslog/access-log"

CMD ["/web/server"]

WORKDIR web
COPY index.html .
COPY --from=bulder /server .
RUN chmod +x server
