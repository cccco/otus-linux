FROM centos
ADD https://raw.githubusercontent.com/halaram/otus-linux/master/05-proc/ps-ax.sh /usr/bin/
ADD https://raw.githubusercontent.com/halaram/otus-linux/master/05-proc/lsof.sh /usr/bin/
RUN chmod +x /usr/bin/ps-ax.sh
RUN chmod +x /usr/bin/lsof.sh
CMD ps-ax.sh
