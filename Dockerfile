FROM ubuntu:14.04
RUN apt-get update
RUN apt-get install -y g++ make git zlib1g-dev python
RUN apt-get install -y python-pip
RUN pip install virtualenv
RUN apt-get install -y python-dev
RUN git clone git://github.com/PacificBiosciences/FALCON-integrate.git
WORKDIR /FALCON-integrate
ENV FC fc_env
RUN virtualenv --no-site-packages  --always-copy  $FC
RUN . $FC/bin/activate
RUN git submodule update --init
RUN cd pypeFLOW && python setup.py install
RUN cd FALCON && python setup.py install
RUN cd DAZZ_DB && make
RUN cd DAZZ_DB && cp DBrm DBshow DBsplit DBstats fasta2DB ../$FC/bin/
RUN cd DALIGNER && make
RUN cd DALIGNER && cp daligner daligner_p DB2Falcon HPCdaligner LA4Falcon LAmerge LAsort  ../$FC/bin
CMD /mydata/do-assemble.sh
