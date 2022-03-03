FROM rocker/r-ver:4.0.0

# CertDS container metadata
ENV certds_name="census_block"
ENV certds_version="0.4.3"
ENV certds_description="census block and tract"
ENV certds_argument="census geography vintage [default: 2010]"

# add OCI labels based on environment variables too
LABEL "com.certds.name"="${certds_name}"
LABEL "com.certds.version"="${certds_version}"
LABEL "com.certds.description"="${certds_description}"
LABEL "com.certds.argument"="${certds_argument}"

RUN R --quiet -e "install.packages('remotes', repos = 'https://packagemanager.rstudio.com/all/__linux__/focal/latest')"
# make sure version matches what is used in the project: packageVersion('renv')
ENV RENV_VERSION 0.14.0
RUN R --quiet -e "remotes::install_github('rstudio/renv@${RENV_VERSION}')"

WORKDIR /app

RUN apt-get update \
  && apt-get install -yqq --no-install-recommends \
  libgdal-dev \
  libgeos-dev \
  libudunits2-dev \
  libproj-dev \
  libssl-dev \
  && apt-get clean

COPY renv.lock .
RUN R --quiet -e "renv::restore(repos = c(CRAN = 'https://packagemanager.rstudio.com/all/__linux__/focal/latest'))"

ADD https://cert-geo-buckets.s3.amazonaws.com/block_2020_5072.rds .
ADD https://cert-geo-buckets.s3.amazonaws.com/block_2010_5072.rds .

COPY census_block.R .

WORKDIR /tmp

ENTRYPOINT ["/app/census_block.R"]
