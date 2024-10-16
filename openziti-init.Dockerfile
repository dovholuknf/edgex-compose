FROM openziti/ziti-cli:1.1.8

COPY ./openziti-init-entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
 