# miniforge image
FROM condaforge/miniforge3

# set up environment (reduce package overhead)
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=UTC \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    SCGEN_HOME=/opt/scgen \
    PATH=/opt/conda/bin:$PATH

# install dependencies
RUN apt-get update &&  apt-get install -y --no-install-recommends build-essential \
    adduser \
    git \
    wget \
        zlib1g-dev && \
    apt-get clean && apt-get purge && \
        rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Create a non-root user
ARG USERNAME=mamba
ARG USERID=1001
RUN adduser --disabled-password --uid $USERID $USERNAME

# workspace
RUN mkdir -p $SCGEN_HOME
WORKDIR $SCGEN_HOME

# (always specify exact version for python packages)
COPY --chown=$USERNAME:$USERNAME . .

# create conda env
RUN conda create -n scgen python=3.12 && conda run -n scgen pip install scgen
ENV PATH=/opt/conda/envs/scgen/bin:$PATH

# jupyter notebook
EXPOSE 8888
#CMD ["jupyter", "notebook", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root"]
CMD ["python", "tests/test_scgen.py"]
