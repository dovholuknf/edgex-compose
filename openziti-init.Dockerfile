FROM openziti/ziti-cli:1.0.0

COPY ./openziti-init-entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
 
