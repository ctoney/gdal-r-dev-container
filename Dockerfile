FROM rocker/r-ver:latest

# Install build dependencies
RUN add-apt-repository ppa:ubuntugis/ubuntugis-unstable && \
  apt-get update && apt-get install -y \
  git \
  build-essential \
  cmake \
  libproj-dev \
  libgeos-dev \
  libsqlite3-dev \
  libspatialite-dev \
  libcurl4-openssl-dev \
  libxml2-dev \
  libtiff5-dev \
  libgeotiff-dev \
  libjpeg-dev \
  libpng-dev \
  libnetcdf-dev \
  libhdf5-dev \
  libopenjp2-7-dev \
  libblosc-dev \
  libzstd-dev \
  liblz4-dev \
  liblzma-dev \
  libwebp-dev \
  libexpat1-dev \
  libmuparser-dev \
  zlib1g-dev \
  python3-dev \
  python3-numpy \
  python3-pip \
  python3-setuptools \
  python3-pytest \
  python3-pytest-sugar \
  python3-pytest-benchmark \
  python3-lxml \
  python3-jsonschema \
  python3-filelock \
  swig \
  ca-certificates \
  lsb-release \
  wget \
  && rm -rf /var/lib/apt/lists/*

# https://arrow.apache.org/install/
RUN wget https://packages.apache.org/artifactory/arrow/$(lsb_release --id --short | tr 'A-Z' 'a-z')/apache-arrow-apt-source-latest-$(lsb_release --codename --short).deb
RUN apt-get install -y -V ./apache-arrow-apt-source-latest-$(lsb_release --codename --short).deb
RUN apt-get update && apt-get install -y -V \
  libarrow-dev \
  libarrow-glib-dev \
  libarrow-dataset-dev \
  libarrow-dataset-glib-dev \
  libarrow-acero-dev \
  libarrow-flight-dev \
  libarrow-flight-glib-dev \
  libarrow-flight-sql-dev \
  libarrow-flight-sql-glib-dev \
  libgandiva-dev \
  libgandiva-glib-dev \
  libparquet-dev \
  libparquet-glib-dev \
  && rm -rf /var/lib/apt/lists/*

# Clone and build GDAL from source
WORKDIR /tmp
RUN git clone https://github.com/OSGeo/gdal.git
WORKDIR /tmp/gdal

###  Enable for PR (pull/#/head:<local-branch-name>)
# RUN git fetch origin pull/13121/head:fix_13119
# RUN git checkout fix_13119
###  End enable for PR

RUN mkdir build
WORKDIR /tmp/gdal/build
RUN cmake .. \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=/usr/local
RUN cmake --build .
RUN cmake --build . --target install

# Update library path
RUN ldconfig

# Clean up
WORKDIR /
RUN rm -rf /tmp/gdal

# Install pak package from CRAN and gdalraster from GitHub
RUN R -e "install.packages('pak', repos='https://cloud.r-project.org/')" && \
  R -e "pak::pkg_install('devtools')" && \
  R -e "pak::pkg_install('USDAForestService/gdalraster')" 



# Set working directory back to root
WORKDIR /