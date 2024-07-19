FROM openziti/ziti-cli:1.1.4

COPY ./openziti-init-entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
 
