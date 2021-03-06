FROM centos:7
## update packages and install dependencies
##    csh, tar, perl needed for cctbx
##    gcc, zlib-devel needed to build mp4ipy
##    bunch of things for psana
RUN yum --enablerepo=updates clean metadata && \
    yum upgrade -y && \
    yum install -y \
        wget \
        which \
        vim \
        git \
        bzip2 \
        gcc \
        bzip2 \
        tar \
        make 

WORKDIR /
ADD optcray_alva.tar /
RUN printf "/opt/cray/mpt/default/gni/mpich2-gnu/48/lib\n" >> /etc/ld.so.conf && \
    printf "/opt/cray/pmi/default/lib64\n" >> /etc/ld.so.conf && \
    printf "/opt/cray/ugni/default/lib64\n" >> /etc/ld.so.conf && \
    printf "/opt/cray/udreg/default/lib64\n" >> /etc/ld.so.conf && \
    printf "/opt/cray/xpmem/default/lib64\n" >> /etc/ld.so.conf && \
    printf "/opt/cray/alps/default/lib64\n" >> /etc/ld.so.conf && \
    printf "/opt/cray/wlm_detect/default/lib64\n" >> /etc/ld.so.conf && \
    printf "/opt/cray/wlm_detect/default/lib64/libwlm_detect.so.0" >> /etc/ld.so.preload && \
    ldconfig

ADD http://portal.nersc.gov/project/mlhub/Anaconda2-4.0.0-Linux-x86_64.sh /tmp
#ADD Anaconda2-4.0.0-Linux-x86_64.sh /tmp
RUN bash /tmp/Anaconda2-4.0.0-Linux-x86_64.sh -b -p /usr/anaconda
ENV PATH /usr/anaconda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

#RUN printf "/usr/anaconda/lib\n" >> /etc/ld.so.conf && \
#    ldconfig

# if additional additional requirements are needed
# python pkgs can be put in the repo under requirements.txt
#ADD requirements.txt /tmp
#RUN pip install -r /tmp/requirements.txt

RUN git clone git://github.com/PacificBiosciences/FALCON-integrate.git
WORKDIR /FALCON-integrate
ENV FC /FALCON-integrate/fc_env
RUN mkdir -p $FC/bin
RUN git submodule update --init
RUN cd pypeFLOW && python setup.py install
RUN cd FALCON && python setup.py install
RUN cd DAZZ_DB && make
RUN cd DAZZ_DB && cp DBrm DBshow DBsplit DBstats fasta2DB $FC/bin
RUN cd DALIGNER && make
RUN cd DALIGNER && cp daligner daligner_p DB2Falcon HPC.daligner LA4Falcon LAmerge LAsort $FC/bin
#CMD /mydata/do-assemble.sh


