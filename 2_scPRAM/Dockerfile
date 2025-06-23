# miniforge image
FROM condaforge/miniforge3

# set up environment (reduce package overhead)
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=UTC \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    SCPRAM_HOME=/opt/scPRAM

# install dependencies
RUN apt-get update &&  apt-get install -y --no-install-recommends build-essential \
    adduser \
    git \
    wget \
    zlib1g-dev && \
    apt-get clean && apt-get purge && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Create a non-root user
ARG USERNAME=conda
ARG USERID=1001
RUN adduser --disabled-password --uid $USERID $USERNAME

# workspace
RUN mkdir -p $SCPRAM_HOME
WORKDIR $SCPRAM_HOME

# (always specify exact version for python packages)
COPY --chown=$USERNAME:$USERNAME . .

# create conda env
RUN conda create -n scpram python=3.8 && conda run -n scpram pip install scpram scanpy scvi-tools jupyter
#RUN conda env create -f envs/environment.yml

# jupyter notebook
EXPOSE 8888
#CMD ["jupyter", "notebook", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root"]
CMD ["jupyter", "notebook", "workdir/scPRAM_tutorial.ipynb" , "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root"]
