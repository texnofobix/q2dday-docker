FROM ubuntu:latest as builder

LABEL Author texnofobix version:0.0.2

#Get Dist Dependencies
RUN apt-get update && apt-get install -y \ 
  gcc \
  make \
  unzip \
  wget \
  zlib1g-dev

WORKDIR  /usr/local/q2dday

# Q2 Binary
RUN cd /usr/local/src/ && \
  wget "https://github.com/Slipyx/r1q2/archive/master.zip" && \  
  unzip master.zip && rm master.zip 

RUN \ 
  cd /usr/local/src/r1q2-master/binaries/ && \
  mkdir -p /usr/local/src/r1q2-master/binaries/r1q2ded/.depends && \ 
  mkdir -p /usr/local/src/r1q2-master/binaries/client/.depends && \
  mkdir -p /usr/local/src/r1q2-master/binaries/game/.depends && \
  mkdir -p /usr/local/src/r1q2-master/binaries/ref_gl/.depends && \
  cd /usr/local/src/r1q2-master/binaries/r1q2ded && \
  make && \
  mkdir -p /usr/local/q2dday/ && \
  cp /usr/local/src/r1q2-master/binaries/r1q2ded/r1q2ded /usr/local/q2dday/

# DDay Binary + Res
RUN cd /usr/local/src/ && \
  wget https://github.com/PowaBanga/DDaynormandyFPS/archive/master.zip && \
  unzip master.zip "DDaynormandyFPS-master/dday*" && \ 
  mv /usr/local/src/DDaynormandyFPS-master/dday /usr/local/q2dday/ && \
  unzip master.zip "DDaynormandyFPS-master/src/*" && \
  rm master.zip 
# && \
RUN cd /usr/local/src/DDaynormandyFPS-master/src/dday && \
  ARCH=x86_64 make && \
  cp gamex86_64.real.so /usr/local/q2dday/dday/ 

# Q2Admin
RUN cd /usr/local/src/ && \ 
  wget https://github.com/tastyspleen/q2admin-tsmod/archive/master.zip && \
  unzip master.zip  && \
  rm master.zip && \
  cd q2admin-tsmod-master/ && \
  make && \
  cp gamex86_64.so /usr/local/q2dday/dday/ && \
  cp /usr/local/src/q2admin-tsmod-master/*.txt /usr/local/q2dday/dday/

# Clean up src
RUN rm -r /usr/local/src/*

FROM ubuntu:latest
WORKDIR  /usr/local/q2dday
COPY --from=builder /usr/local/q2dday .
RUN chown -R nobody /usr/local/q2dday
USER nobody
CMD ["./r1q2ded","+game dday","+map dday1"]
